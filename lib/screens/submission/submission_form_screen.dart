import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/models/priority.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/widgets/tray_type_picker.dart';
import 'package:shukla_pps/widgets/priority_toggle.dart';

/// Remembers whether the user prefers wizard or single-page mode.
final formModeProvider = StateProvider<bool>((ref) => true); // true = wizard

class SubmissionFormScreen extends ConsumerStatefulWidget {
  const SubmissionFormScreen({super.key, required this.requestType});

  final RequestType requestType;

  @override
  ConsumerState<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends ConsumerState<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  Priority _priority = Priority.normal;

  // Field controllers
  final _surgeonController = TextEditingController();
  final _facilityController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedTrayType;
  DateTime? _selectedDate;

  List<String> get _fields => widget.requestType.requiredFields;

  @override
  void dispose() {
    _surgeonController.dispose();
    _facilityController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collectData() {
    final user = ref.read(currentUserProvider).valueOrNull;
    return {
      'rep_id': user?.id,
      'request_type': widget.requestType.toJson(),
      'surgeon': _surgeonController.text.isNotEmpty ? _surgeonController.text : null,
      'facility': _facilityController.text.isNotEmpty ? _facilityController.text : null,
      'tray_type': _selectedTrayType,
      'surgery_date': _selectedDate?.toIso8601String().split('T').first,
      'details': _detailsController.text.isNotEmpty ? _detailsController.text : null,
      'priority': _priority.toJson(),
      'source': 'app',
      // Include display values for confirmation screen
      '_request_type_label': widget.requestType.label,
      '_priority_label': _priority.label,
    };
  }

  Widget _buildField(String field) {
    final rtJson = widget.requestType.jsonValue;
    final hint = fieldHints[rtJson]?[field];

    switch (field) {
      case 'surgeon':
        return TextFormField(
          controller: _surgeonController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint,
          ),
          validator: (v) => v == null || v.isEmpty ? '${fieldLabels[field]} is required' : null,
        );
      case 'facility':
        return TextFormField(
          controller: _facilityController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint ?? 'Facility / Hospital name',
          ),
          validator: (v) => v == null || v.isEmpty ? '${fieldLabels[field]} is required' : null,
        );
      case 'tray_type':
        return TrayTypePicker(
          initialValue: _selectedTrayType,
          onSelected: (val) => _selectedTrayType = val,
        );
      case 'surgery_date':
        return TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint ?? 'Select a date',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: _selectedDate != null
                ? _selectedDate!.toIso8601String().split('T').first
                : '',
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          validator: (v) => v == null || v.isEmpty ? '${fieldLabels[field]} is required' : null,
        );
      case 'details':
        return TextFormField(
          controller: _detailsController,
          decoration: InputDecoration(
            labelText: fieldLabels[field],
            hintText: hint ?? 'Additional details',
          ),
          maxLines: 3,
          validator: widget.requestType == RequestType.other
              ? (v) => v == null || v.isEmpty ? 'Details are required' : null
              : null,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _goToConfirmation() {
    if (_formKey.currentState!.validate()) {
      context.push('/submission/confirm', extra: _collectData());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWizard = ref.watch(formModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestType.label),
        actions: [
          TextButton(
            onPressed: () => ref.read(formModeProvider.notifier).state = !isWizard,
            child: Text(isWizard ? 'Show all fields' : 'Wizard mode'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: isWizard ? _buildWizard() : _buildSinglePage(),
      ),
    );
  }

  Widget _buildSinglePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._fields.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildField(f),
        )),
        PriorityToggle(value: _priority, onChanged: (p) => setState(() => _priority = p)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _goToConfirmation, child: const Text('Review & Submit')),
      ],
    );
  }

  Widget _buildWizard() {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / (_fields.length + 1),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${_currentStep + 1} of ${_fields.length + 1}: ${_currentStep < _fields.length ? (fieldLabels[_fields[_currentStep]] ?? _fields[_currentStep]) : 'Priority'}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _currentStep < _fields.length
                ? _buildField(_fields[_currentStep])
                : PriorityToggle(value: _priority, onChanged: (p) => setState(() => _priority = p)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _fields.length) {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _currentStep++);
                      }
                    } else {
                      _goToConfirmation();
                    }
                  },
                  child: Text(_currentStep < _fields.length ? 'Next' : 'Review & Submit'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

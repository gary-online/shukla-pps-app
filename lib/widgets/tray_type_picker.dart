import 'package:flutter/material.dart';
import 'package:shukla_pps/config/constants.dart';

class TrayTypePicker extends StatefulWidget {
  const TrayTypePicker({super.key, required this.onSelected, this.initialValue});

  final ValueChanged<String> onSelected;
  final String? initialValue;

  @override
  State<TrayTypePicker> createState() => _TrayTypePickerState();
}

class _TrayTypePickerState extends State<TrayTypePicker> {
  late TextEditingController _controller;
  List<String> _filtered = trayCatalog;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = trayCatalog.where((tray) {
        return tray.toLowerCase().contains(q) ||
            _fuzzyMatch(tray.toLowerCase(), q);
      }).toList();
      _showDropdown = query.isNotEmpty;
    });
  }

  bool _fuzzyMatch(String source, String query) {
    int si = 0;
    for (int qi = 0; qi < query.length && si < source.length; si++) {
      if (source[si] == query[qi]) qi++;
    }
    return si <= source.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Tray Type',
            prefixIcon: Icon(Icons.search),
            hintText: 'Search tray types...',
          ),
          onChanged: _filter,
          onTap: () => setState(() => _showDropdown = true),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Tray type is required';
            if (!trayCatalog.contains(value)) return 'Select a valid tray type';
            return null;
          },
        ),
        if (_showDropdown && _filtered.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final tray = _filtered[index];
                return ListTile(
                  title: Text(tray),
                  dense: true,
                  onTap: () {
                    _controller.text = tray;
                    setState(() => _showDropdown = false);
                    widget.onSelected(tray);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

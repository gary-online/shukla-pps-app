import 'package:flutter/material.dart';

enum RequestType {
  ppsCaseReport(
    label: 'PPS Case Report',
    icon: Icons.medical_services,
    jsonValue: 'pps_case_report',
    requiredFields: ['surgeon', 'facility', 'tray_type', 'surgery_date', 'details'],
  ),
  fedexLabelRequest(
    label: 'FedEx Label Request',
    icon: Icons.local_shipping,
    jsonValue: 'fedex_label_request',
    requiredFields: ['facility', 'tray_type', 'details'],
  ),
  billOnlyRequest(
    label: 'Bill Only Request',
    icon: Icons.receipt_long,
    jsonValue: 'bill_only_request',
    requiredFields: ['surgeon', 'facility', 'tray_type', 'surgery_date', 'details'],
  ),
  trayAvailability(
    label: 'Tray Availability',
    icon: Icons.inventory_2,
    jsonValue: 'tray_availability',
    requiredFields: ['tray_type', 'surgery_date', 'facility'],
  ),
  deliveryStatus(
    label: 'Delivery Status',
    icon: Icons.track_changes,
    jsonValue: 'delivery_status',
    requiredFields: ['tray_type', 'facility', 'details'],
  ),
  other(
    label: 'Other',
    icon: Icons.more_horiz,
    jsonValue: 'other',
    requiredFields: ['details'],
  );

  const RequestType({
    required this.label,
    required this.icon,
    required this.jsonValue,
    required this.requiredFields,
  });

  final String label;
  final IconData icon;
  final String jsonValue;
  final List<String> requiredFields;

  String toJson() => jsonValue;

  static RequestType fromJson(String value) {
    return RequestType.values.firstWhere((e) => e.jsonValue == value);
  }
}

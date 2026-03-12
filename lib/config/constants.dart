/// The 22 surgical implant extraction tray types manufactured by Shukla Medical.
/// Source: shukla-phone-automation/src/types.py
const List<String> trayCatalog = [
  'Mini',
  'Maxi',
  'Blade',
  'Shoulder-Blade',
  'Modular Hip',
  'Copter',
  'Broken Nail',
  'Lag',
  'Screw-Flex',
  'Anterior Hip',
  'Vise',
  'Screw',
  'Hip',
  'Knee',
  'Nail',
  'Spine-Cervical',
  'Spine-Thoracic & Lumbar',
  'Spine-Instruments',
  'Shoulder',
  'Trephine',
  'Cup',
  'Cement',
];

/// Field labels for the submission form.
const Map<String, String> fieldLabels = {
  'surgeon': 'Surgeon / Doctor',
  'facility': 'Facility / Hospital',
  'tray_type': 'Tray Type',
  'surgery_date': 'Surgery Date',
  'details': 'Details',
};

/// Placeholder hints per field, per request type where they differ from default.
const Map<String, Map<String, String>> fieldHints = {
  'fedex_label_request': {
    'facility': 'Destination facility name and city/state',
    'details': 'PO number or Shukla account number',
  },
  'tray_availability': {
    'surgery_date': 'Date needed',
  },
  'delivery_status': {
    'facility': 'Destination facility',
    'details': 'Tracking number (if available)',
  },
  'other': {
    'details': 'Describe your request',
  },
};

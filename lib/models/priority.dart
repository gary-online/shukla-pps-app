enum Priority {
  normal(label: 'Normal', jsonValue: 'normal'),
  urgent(label: 'Urgent', jsonValue: 'urgent');

  const Priority({required this.label, required this.jsonValue});

  final String label;
  final String jsonValue;

  String toJson() => jsonValue;

  static Priority fromJson(String value) {
    return Priority.values.firstWhere((e) => e.jsonValue == value);
  }
}

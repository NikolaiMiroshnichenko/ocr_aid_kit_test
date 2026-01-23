class Medicine {
  final String name;
  final String dosage;
  final String date;
  final String category;

  Medicine({required this.name, required this.dosage, required this.date, required this.category});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? 'Неизвестно',
      dosage: json['dosage'] ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? 'Общее',
    );
  }
}
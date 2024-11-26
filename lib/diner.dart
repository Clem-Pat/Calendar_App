class Diner {
  final int? id;
  final String name;
  final String date;

  Diner({this.id, required this.name, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'date': date};
  }

  factory Diner.fromMap(Map<String, dynamic> map) {
    return Diner(
      id: map['id'],
      name: map['name'],
      date: map['date'],
    );
  }
}
 

class Invite {
  final int? id;
  final String first_name;
  final String name;

  Invite({this.id, required this.first_name, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'first_name': first_name, 'name': name};
  }

  factory Invite.fromMap(Map<String, dynamic> map) {
    return Invite(
      id: map['id'],
      first_name: map['first_name'],
      name: map['name'],
    );
  }

}

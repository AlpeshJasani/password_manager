class Password {
  int? id;
  String name;
  String username;
  String password;
  String note;

  Password({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'note': note,
    };
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
      note: map['note'],
    );
  }
}

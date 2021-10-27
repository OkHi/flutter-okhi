import 'dart:convert';

class OkHiUser {
  String? firstName;
  String? lastName;
  String? id;
  String phone;

  OkHiUser({required this.phone, this.firstName, this.lastName, this.id});

  OkHiUser.fromMap({required this.phone, required Map<String, String> data}) {
    id = data["id"];
    firstName = data["firstName"] ?? data["first_name"];
    lastName = data["lastName"] ?? data["last_name"];
  }

  @override
  String toString() {
    return jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "id": id,
      "phone": phone,
    });
  }
}

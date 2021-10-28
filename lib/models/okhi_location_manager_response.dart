import '../okhi.dart';

class OkHiLocationManagerResponse {
  late OkHiUser user;
  late OkHiLocation location;

  OkHiLocationManagerResponse(Map<String, dynamic> data) {
    location = OkHiLocation.fromMap(data["location"]);
    user = OkHiUser(
      phone: data["user"]["phone"],
      firstName: data["user"]["firstName"] ?? data["user"]["first_name"],
      lastName: data["user"]["lastName"] ?? data["user"]["last_name"],
      id: data["user"]["id"],
    );
  }

  @override
  String toString() {
    return '{"user": ${user.toString()}, "location": ${location.toString()}}';
  }

  Future<String> startVerification(OkHiVerificationConfiguration? configuration) {
    return OkHi.startVerification(user, location, configuration);
  }
}

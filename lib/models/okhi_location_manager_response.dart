import '../okhi.dart';

class OkHiLocationManagerResponse {
  late OkHiUser user;
  late OkHiLocation location;

  OkHiLocationManagerResponse(Map<String, dynamic> data) {
    location = OkHiLocation.fromMap(data["location"]);
    user = OkHiUser.fromMap(phone: data["user"]["phone"], data: data);
  }

  @override
  String toString() {
    return '{"user": ${user.toString()}, "location": ${location.toString()}}';
  }

  Future<String> startVerification(
      OkHiVerificationConfiguration? configuration) {
    return OkHi.startVerification(user, location, configuration);
  }
}

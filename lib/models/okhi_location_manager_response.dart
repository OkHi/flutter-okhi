import '../models/okhi_user.dart';
import '../models/okhi_location.dart';

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
}

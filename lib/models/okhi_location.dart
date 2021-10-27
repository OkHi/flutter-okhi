import 'dart:convert';

class OkHiLocation {
  String? id;
  double? lat;
  double? lon;
  String? city;
  String? country;
  String? directions;
  String? displayTitle;
  String? otherInformation;
  String? photoUrl;
  String? placeId;
  String? plusCode;
  String? propertyName;
  String? propertyNumber;
  String? state;
  String? streetName;
  String? streetViewPanoId;
  String? streetViewPanoUrl;
  String? subtitle;
  String? title;
  String? url;
  String? userId;

  OkHiLocation({
    this.id,
    this.lat,
    this.lon,
    this.city,
    this.country,
    this.directions,
    this.displayTitle,
    this.otherInformation,
    this.photoUrl,
    this.placeId,
    this.plusCode,
    this.propertyName,
    this.propertyNumber,
    this.state,
    this.streetName,
    this.streetViewPanoId,
    this.streetViewPanoUrl,
    this.subtitle,
    this.title,
    this.url,
    this.userId,
  });

  OkHiLocation.fromMap(Map<String, dynamic> data) {
    id = data["id"];
    lat = data["geo_point"] != null ? data["geo_point"]["lat"] : null;
    lon = data["geo_point"] != null ? data["geo_point"]["lon"] : null;
    city = data["city"];
    country = data["country"];
    directions = data["directions"];
    displayTitle = data["display_title"];
    otherInformation = data["other_information"];
    photoUrl = data["photo"];
    placeId = data["place_id"];
    plusCode = data["plus_code"];
    propertyName = data["property_name"];
    propertyNumber = data["property_number"];
    state = data["state"];
    streetName = data["street_name"];
    streetViewPanoId = data["street_view"]["pano_id"];
    streetViewPanoUrl = data["street_view"]["url"];
    subtitle = data["subtitle"];
    title = data["title"];
    url = data["url"];
    userId = data["user_id"];
  }

  @override
  String toString() {
    return jsonEncode({
      "id": id,
      "lat": lat,
      "lon": lon,
      "city": city,
      "country": country,
      "directions": directions,
      "displayTitle": displayTitle,
      "otherInformation": otherInformation,
      "photoUrl": photoUrl,
      "placeId": placeId,
      "plusCode": plusCode,
      "propertyName": propertyName,
      "propertyNumber": propertyNumber,
      "state": state,
      "streetName": streetName,
      "streetViewPanoId": streetViewPanoId,
      "streetViewPanoUrl": streetViewPanoUrl,
      "subtitle": subtitle,
      "title": title,
      "url": url,
      "userId": userId,
    });
  }
}

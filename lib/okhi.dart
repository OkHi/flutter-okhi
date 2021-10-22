import 'dart:async';

import 'package:flutter/services.dart';

class OkHi {
  static const MethodChannel _channel = MethodChannel('okhi');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> isLocationServicesEnabled() async {
    final bool result =
        await _channel.invokeMethod("isLocationServicesEnabled");
    return result;
  }

  static Future<bool> isLocationPermissionGranted() async {
    final bool result =
        await _channel.invokeMethod("isLocationPermissionGranted");
    return result;
  }

  static Future<bool> isBackgroundLocationPermissionGranted() async {
    final bool result =
        await _channel.invokeMethod("isBackgroundLocationPermissionGranted");
    return result;
  }

  static Future<bool> isGooglePlayServicesAvailable() async {
    final bool result =
        await _channel.invokeMethod("isGooglePlayServicesAvailable");
    return result;
  }
}

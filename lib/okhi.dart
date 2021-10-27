import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import './models/okhi_app_configuration.dart';

// models export
export './okcollect/okhi_location_manager.dart';
export './models/okhi_app_configuration.dart';
export './models/okhi_env.dart';
export './models/okhi_user.dart';

class OkHi {
  static const MethodChannel _channel = MethodChannel('okhi');
  static OkHiAppConfiguration? _configuration;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
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
    if (Platform.isAndroid) {
      final bool result =
          await _channel.invokeMethod("isGooglePlayServicesAvailable");
      return result;
    } else {
      // ignore: todo
      // TODO: work on OkHiException class
      throw Exception('Platform not supported');
    }
  }

  static Future<bool> requestLocationPermission() async {
    final bool result =
        await _channel.invokeMethod("requestLocationPermission");
    return result;
  }

  static Future<bool> requestBackgroundLocationPermission() async {
    final bool result =
        await _channel.invokeMethod("requestBackgroundLocationPermission");
    return result;
  }

  static Future<bool> requestEnableLocationServices() async {
    if (Platform.isAndroid) {
      final bool result =
          await _channel.invokeMethod("requestEnableLocationServices");
      return result;
    } else {
      // ignore: todo
      throw Exception('Platform not supported');
    }
  }

  static Future<bool> requestEnableGooglePlayServices() async {
    if (Platform.isAndroid) {
      final bool result =
          await _channel.invokeMethod("requestEnableGooglePlayServices");
      return result;
    } else {
      // ignore: todo
      throw Exception('Platform not supported');
    }
  }

  static configure(OkHiAppConfiguration configuration) {
    _configuration = configuration;
  }

  static OkHiAppConfiguration? getConfiguration() {
    return _configuration;
  }
}

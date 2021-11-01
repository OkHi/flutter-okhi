import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:okhi/models/okhi_location.dart';
import 'package:okhi/models/okhi_user.dart';
import './models/okhi_app_configuration.dart';
import './models/okhi_native_methods.dart';
import './models/okhi_verification_configuration.dart';
import './models/okhi_exception.dart';

// models export
export './okcollect/okhi_location_manager.dart';
export './models/okhi_app_configuration.dart';
export './models/okhi_env.dart';
export './models/okhi_user.dart';
export './models/okhi_location_manager_response.dart';
export './models/okhi_location_manager_configuration.dart';
export './models/okhi_notification.dart';
export './models/okhi_verification_configuration.dart';
export './models/okhi_location.dart';
export './models/okhi_exception.dart';

class OkHi {
  static const MethodChannel _channel = MethodChannel('okhi');
  static OkHiAppConfiguration? _configuration;

  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod(OkHiNativeMethod.getPlatformVersion);
    return version;
  }

  static Future<bool> isLocationServicesEnabled() async {
    final bool result =
        await _channel.invokeMethod(OkHiNativeMethod.isLocationServicesEnabled);
    return result;
  }

  static Future<bool> isLocationPermissionGranted() async {
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.isLocationPermissionGranted);
    return result;
  }

  static Future<bool> isBackgroundLocationPermissionGranted() async {
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.isBackgroundLocationPermissionGranted);
    return result;
  }

  static Future<bool> isGooglePlayServicesAvailable() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.isBackgroundLocationPermissionGranted);
      return result;
    } else {
      throw OkHiException(
          code: OkHiException.unsupportedPlatformCode,
          message: OkHiException.unsupportedPlatformMessage);
    }
  }

  static Future<bool> requestLocationPermission() async {
    final bool result =
        await _channel.invokeMethod(OkHiNativeMethod.requestLocationPermission);
    return result;
  }

  static Future<bool> requestBackgroundLocationPermission() async {
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.requestBackgroundLocationPermission);
    return result;
  }

  static Future<bool> requestEnableLocationServices() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.requestEnableLocationServices);
      return result;
    } else {
      // ignore: todo
      throw Exception('Platform not supported');
    }
  }

  static Future<bool> requestEnableGooglePlayServices() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.requestEnableGooglePlayServices);
      return result;
    } else {
      throw OkHiException(
        code: OkHiException.unsupportedPlatformCode,
        message: OkHiException.unsupportedPlatformMessage,
      );
    }
  }

  static Future<bool> initialize(OkHiAppConfiguration configuration) async {
    _configuration = configuration;
    final credentials = {
      "branchId": configuration.branchId,
      "clientKey": configuration.clientKey,
      "environment": configuration.environmentRawValue,
      "notification": configuration.notification.toMap()
    };
    return await _channel.invokeMethod(
        OkHiNativeMethod.initialize, credentials);
  }

  static OkHiAppConfiguration? getConfiguration() {
    return _configuration;
  }

  static Future<String> startVerification(OkHiUser user, OkHiLocation location,
      OkHiVerificationConfiguration? configuration) async {
    if (location.id == null || location.lat == null || location.lon == null) {
      throw OkHiException(
        code: OkHiException.badRequestCode,
        message: "Invalid arguments provided for starting verification",
      );
    }

    final config = configuration ?? OkHiVerificationConfiguration();
    return await _channel.invokeMethod(OkHiNativeMethod.startVerification, {
      "phoneNumber": user.phone,
      "locationId": location.id,
      "lat": location.lat,
      "lon": location.lon,
      "withForegroundService": config.withForegroundService,
    });
  }

  static Future<String> stopVerification(
      OkHiUser user, OkHiLocation location) async {
    if (location.id == null) {
      throw OkHiException(
        code: OkHiException.badRequestCode,
        message: "Invalid arguments provided for stopping verification",
      );
    } else {
      return await _channel.invokeMethod(OkHiNativeMethod.stopVerification, {
        "phoneNumber": user.phone,
        "locationId": location.id,
      });
    }
  }

  static Future<bool> isForegroundServiceRunning() async {
    return await _channel
        .invokeMethod(OkHiNativeMethod.isForegroundServiceRunning);
  }

  static Future<bool> startForegroundService() async {
    return await _channel.invokeMethod(OkHiNativeMethod.startForegroundService);
  }

  static Future<bool> stopForegroundService() async {
    return await _channel.invokeMethod(OkHiNativeMethod.stopForegroundService);
  }

  static Future<bool> canStartVerification(bool requestServices) async {
    if (Platform.isIOS && !(await OkHi.isLocationServicesEnabled())) {
      throw OkHiException(
        code: OkHiException.serviceUnavailableCode,
        message: "Location services disabled",
      );
    }
    var hasLocationServices = Platform.isIOS ? true : await OkHi.isLocationServicesEnabled();
    var hasLocationPermission =
        await OkHi.isBackgroundLocationPermissionGranted();
    var hasGooglePlayService =
        Platform.isIOS ? true : await OkHi.isGooglePlayServicesAvailable();
    if (!requestServices) {
      return hasLocationServices &&
          hasLocationPermission &&
          hasGooglePlayService;
    }
    hasLocationServices = await OkHi.requestEnableLocationServices();
    hasLocationPermission = await OkHi.requestBackgroundLocationPermission();
    hasGooglePlayService =
        Platform.isIOS ? true : await OkHi.requestEnableGooglePlayServices();
    return hasLocationServices && hasLocationPermission && hasGooglePlayService;
  }
}

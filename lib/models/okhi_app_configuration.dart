import './okhi_notification.dart';

import './okhi_env.dart';

class OkHiAppConfiguration {
  final String branchId;
  final String clientKey;
  OkHiEnv env = OkHiEnv.sandbox;
  String environmentRawValue = "sandbox";
  OkHiAndroidNotification notification = OkHiAndroidNotification.withDefaults();

  OkHiAppConfiguration({
    required this.branchId,
    required this.clientKey,
    required this.env,
    OkHiAndroidNotification? notification,
  }) {
    if (env == OkHiEnv.prod) {
      environmentRawValue = "prod";
    }
    this.notification = notification ?? OkHiAndroidNotification.withDefaults();
  }

  OkHiAppConfiguration.withRawValue({
    required this.branchId,
    required this.clientKey,
    required this.environmentRawValue,
    OkHiAndroidNotification? notification
  }) {
    this.notification = notification ?? OkHiAndroidNotification.withDefaults();
  }
}

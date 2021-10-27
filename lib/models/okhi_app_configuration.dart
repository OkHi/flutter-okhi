import './okhi_env.dart';

class OkHiAppConfiguration {
  final String branchId;
  final String clientKey;
  OkHiEnv env = OkHiEnv.sandbox;
  String environmentRawValue = "sandbox";

  OkHiAppConfiguration({
    required this.branchId,
    required this.clientKey,
    required this.env,
  }) {
    if (env == OkHiEnv.prod) {
      environmentRawValue = "prod";
    }
  }
  OkHiAppConfiguration.withRawValue(
      {required this.branchId,
      required this.clientKey,
      required this.environmentRawValue});
}

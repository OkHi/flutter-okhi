import 'okhi_env.dart';

class OkHiAppConfiguration {
  final String branchId;
  final String clientKey;
  OkHiEnv env = OkHiEnv.sandbox;
  String environmentValue = "sandbox";

  OkHiAppConfiguration(
      {required this.branchId, required this.clientKey, required this.env});
  OkHiAppConfiguration.withRawValue(
      {required this.branchId,
      required this.clientKey,
      required this.environmentValue});
}
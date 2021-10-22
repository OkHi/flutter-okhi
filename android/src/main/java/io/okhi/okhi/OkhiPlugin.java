package io.okhi.okhi;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.okhi.android_core.OkHi;

/** OkhiPlugin */
public class OkhiPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private OkHi okHi;
  private final static String TAG = "OkHi";
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "okhi");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        handleGetPlatformVersion(call, result);
        break;
      case "isLocationServicesEnabled":
        handleIsLocationServicesEnabled(call, result);
      case "isLocationPermissionGranted":
        handleIsLocationPermissionGranted(call, result);
        break;
      case "isBackgroundLocationPermissionGranted":
        handleIsBackgroundLocationPermissionGranted(call, result);
        break;
      case "isGooglePlayServicesAvailable":
        handleIsGooglePlayServicesAvailable(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Log.v(TAG, "Attached");
    try {
      okHi = new OkHi(binding.getActivity());
      Log.v(TAG, "OkHi initialised");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  private void handleGetPlatformVersion(MethodCall call, Result result) {
    result.success("Android " + android.os.Build.VERSION.SDK_INT);
  }

  private void handleIsLocationServicesEnabled(MethodCall call, Result result) {
    result.success(OkHi.isLocationServicesEnabled(context));
  }

  private void handleIsLocationPermissionGranted(MethodCall call, Result result) {
    result.success(OkHi.isLocationPermissionGranted(context));
  }

  private void handleIsBackgroundLocationPermissionGranted(MethodCall call, Result result) {
    result.success(OkHi.isBackgroundLocationPermissionGranted(context));
  }

  private void handleIsGooglePlayServicesAvailable(MethodCall call, Result result) {
    result.success(OkHi.isGooglePlayServicesAvailable(context));
  }
}

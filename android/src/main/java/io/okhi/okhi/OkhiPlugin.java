package io.okhi.okhi;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.okhi.android_core.OkHi;
import io.okhi.android_core.interfaces.OkHiRequestHandler;
import io.okhi.android_core.models.OkHiException;

/** OkhiPlugin */
public class OkhiPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private OkHi okHi;
  private Context context;
  private final static String TAG = "OkHi";
  private final PluginRegistry.ActivityResultListener activityResultListener = new PluginRegistry.ActivityResultListener() {
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
      if (okHi != null) {
        okHi.onActivityResult(requestCode, resultCode, data);
      }
      return false;
    }
  };
  private final PluginRegistry.RequestPermissionsResultListener requestPermissionsResultListener = new PluginRegistry.RequestPermissionsResultListener() {
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
      if (okHi != null) {
        okHi.onRequestPermissionsResult(requestCode, permissions, grantResults);
      }
      return false;
    }
  };

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
      case "requestLocationPermission":
        handleRequestLocationPermission(call, result);
        break;
      case "requestBackgroundLocationPermission":
        handleRequestBackgroundLocationPermission(call, result);
        break;
      case "requestEnableLocationServices":
        handleRequestEnableLocationServices(call, result);
        break;
      case "requestEnableGooglePlayServices":
        handleRequestEnableGooglePlayServices(call, result);
        break;
      case "getAppIdentifier":
        handleGetAppIdentifier(call, result);
        break;
      case "getAppVersion":
        handleGetAppVersion(call, result);
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
    try {
      okHi = new OkHi(binding.getActivity());
      binding.addActivityResultListener(activityResultListener);
      binding.addRequestPermissionsResultListener(requestPermissionsResultListener);
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

  private void handleGetAppIdentifier(MethodCall call, Result result) {
    result.success(context.getPackageName());
  }

  private void handleGetAppVersion(MethodCall call, Result result) {
    try {
      String versionName = context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionName;
      result.success(versionName);
    } catch (Exception e) {
      e.printStackTrace();
      result.success("-1");
    }
  }

  private void handleRequestLocationPermission(MethodCall call, final Result result) {
    okHi.requestLocationPermission(null, null, new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean permission) {
        result.success(permission);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestBackgroundLocationPermission(MethodCall call, Result result) {
    okHi.requestBackgroundLocationPermission(null, null, new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean permission) {
        result.success(permission);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestEnableLocationServices(MethodCall call, Result result) {
    okHi.requestEnableLocationServices(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean service) {
        result.success(service);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }

  private void handleRequestEnableGooglePlayServices(MethodCall call, Result result) {
    okHi.requestEnableGooglePlayServices(new OkHiRequestHandler<Boolean>() {
      @Override
      public void onResult(Boolean service) {
        result.success(service);
      }
      @Override
      public void onError(OkHiException exception) {
        result.error(exception.getCode(), exception.getMessage(), exception.getStackTrace());
      }
    });
  }
}

import Flutter
import UIKit
import OkCore
import CoreLocation

public class SwiftOkhiPlugin: NSObject, FlutterPlugin {
  private enum LocationPermissionRequestType: String {
    case whenInUse = "whenInUse"
    case always = "always"
  }
  private let okhiLocationService = OkHiLocationService()
  private var flutterResult: FlutterResult?
  private var locationPermissionRequestType: LocationPermissionRequestType = .always
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "okhi", binaryMessenger: registrar.messenger())
    let instance = SwiftOkhiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "getPlatformVersion":
      handlePlatformVersion(call, result)
      break
    case "isLocationServicesEnabled":
      handleIsLocationServicesEnabled(call, result)
      break
    case "isLocationPermissionGranted":
      handleIsLocationPermissionGranted(call, result)
      break
    case "isBackgroundLocationPermissionGranted":
      handleIsBackgroundLocationPermissionGranted(call, result)
      break
    case "requestLocationPermission":
      handleRequestLocationPermission(call, result)
      break
    case "requestBackgroundLocationPermission":
      handleRequestBackgroundLocationPermission(call, result)
      break
    case "getAppIdentifier":
      handleGetAppIdentifier(call, result)
      break
    case "getAppVersion":
      handleGetAppVersion(call, result)
      break
    default:
      result(FlutterMethodNotImplemented)
      break
    }
  }
  
  private func handlePlatformVersion(_ call: FlutterMethodCall, _ result: FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
  
  private func handleIsLocationServicesEnabled(_ call: FlutterMethodCall, _ result: FlutterResult) {
    result(okhiLocationService.isLocationServicesAvailable())
  }
  
  private func handleIsLocationPermissionGranted(_ call: FlutterMethodCall, _ result: FlutterResult) {
    result(okhiLocationService.isLocationPermissionGranted())
  }
  
  private func handleIsBackgroundLocationPermissionGranted(_ call: FlutterMethodCall, _ result: FlutterResult) {
    result(isBackgroundLocationPermissionGranted())
  }
  
  private func handleRequestLocationPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if okhiLocationService.isLocationPermissionGranted() {
      result(true)
      return
    }
    self.flutterResult = result
    okhiLocationService.delegate = self
    okhiLocationService.requestLocationPermission(withBackgroundLocationPermission: false)
    locationPermissionRequestType = .whenInUse
  }
  
  private func handleRequestBackgroundLocationPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if isBackgroundLocationPermissionGranted() {
      result(true)
      return
    }
    okhiLocationService.delegate = self
    self.flutterResult = result
    locationPermissionRequestType = .always
    okhiLocationService.requestLocationPermission(withBackgroundLocationPermission: true)
  }
  
  private func handleGetAppIdentifier(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let bundleID = Bundle.main.bundleIdentifier
    result(bundleID ?? "")
  }
  
  private func handleGetAppVersion(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    result(appVersion ?? "")
  }
  
  private func isBackgroundLocationPermissionGranted() -> Bool {
    if okhiLocationService.isLocationServicesAvailable() {
      return CLLocationManager.authorizationStatus() == .authorizedAlways
    } else {
      return false
    }
  }
}

extension SwiftOkhiPlugin: OkHiLocationServiceDelegate {
  public func okHiLocationService(locationService: OkHiLocationService, didChangeLocationPermissionStatus locationPermissionType: LocationPermissionType, result: Bool) {
    guard let flutterResult = flutterResult else { return }
    if locationPermissionRequestType == .whenInUse {
      if locationPermissionType == .whenInUse {
        flutterResult(result)
      }
    } else if locationPermissionRequestType == .always {
      if locationPermissionType == .always {
        flutterResult(result)
      }
    }
  }
}

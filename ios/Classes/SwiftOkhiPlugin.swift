import Flutter
import UIKit
import OkCore
import CoreLocation
import OkVerify

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
    case "initialize":
      handleInitialize(call, result)
      break
    case "startVerification":
      handleStartVerification(call, result)
      break
    case "stopVerification":
      handleStopVerification(call, result)
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
  
  private func handleInitialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let branchId = arguments["branchId"] as? String
    let clientKey = arguments["clientKey"] as? String
    let appBundleID = Bundle.main.bundleIdentifier ?? ""
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-1"
    let okHiAppContext = OkHiAppContext().withAppMeta(name: appBundleID, version: appVersion, build: appVersion)
    let envRaw = arguments["environment"] as? String ?? "sandbox"
    let env = envRaw == "prod" ? Environment.prod : Environment.sandbox
    if let branchId = branchId, let clientKey = clientKey {
      if envRaw == "dev" {
        let okHiAuth = OkHiAuth(
          branchId: branchId,
          clientKey: clientKey,
          environment: "https://dev-api.okhi.io",
          appContext: okHiAppContext
        )
        OkHiVerify.initialize(with: okHiAuth)
      } else {
        let okHiAuth = OkHiAuth(
          branchId: branchId,
          clientKey: clientKey,
          environment: env,
          appContext: okHiAppContext
        )
        OkHiVerify.initialize(with: okHiAuth)
      }
      result(true)
    } else {
      result(FlutterError(code: "unauthorized", message: "invalid initialization credentials provided", details: nil))
    }
  }
  
  private func handleStartVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let phoneNumber = arguments["phoneNumber"] as? String
    let locationId = arguments["locationId"] as? String
    let lat = arguments["lat"] as? Double
    let lon = arguments["lon"] as? Double
    if let locationId = locationId, let lat = lat, let lon = lon, let phoneNumber = phoneNumber {
      self.flutterResult = result
      let user = OkHiUser(phoneNumber: phoneNumber)
      let location = OkHiLocation(identifier: locationId, lat: lat, lon: lon)
      let okVerify = OkHiVerify(user: user)
      okVerify.delegate = self
      okVerify.start(location: location)
    } else {
      result(FlutterError(code: "bad_request", message: "invalid arguments provided for verification", details: nil))
    }
  }
  
  private func handleStopVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let phoneNumber = arguments["phoneNumber"] as? String
    let locationId = arguments["locationId"] as? String
    if let locationId = locationId, let phoneNumber = phoneNumber {
      self.flutterResult = result
      let user = OkHiUser(phoneNumber: phoneNumber)
      let okVerify = OkHiVerify(user: user)
      okVerify.delegate = self
      okVerify.stop(locationId: locationId)
    }
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

extension SwiftOkhiPlugin: OkVerifyDelegate {
  public func verify(_ okVerify: OkHiVerify, didEncounterError error: OkHiError) {
    if let flutterResult = flutterResult {
      flutterResult(FlutterError(code: error.code, message: error.message, details: nil))
    }
  }
  
  public func verify(_ okVerify: OkHiVerify, didStart locationId: String) {
    if let flutterResult = flutterResult {
      flutterResult(locationId)
    }
  }
  
  public func verify(_ okVerify: OkHiVerify, didEnd locationId: String) {
    if let flutterResult = flutterResult {
      flutterResult(locationId)
    }
  }
}

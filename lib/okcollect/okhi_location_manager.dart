import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../okhi.dart';
import '../models/okhi_user.dart';
import '../models/okhi_constant.dart';
import '../models/okhi_location_manager_configuration.dart';
import '../models/okhi_location_manager_response.dart';
import '../models/okhi_native_methods.dart';

class OkHiLocationManager extends StatefulWidget {
  final OkHiUser user;
  late final OkHiLocationManagerConfiguration locationManagerConfiguration;
  final Function(OkHiLocationManagerResponse response)? onSucess;
  final Function()? onError;
  final Function()? onCloseRequest;

  OkHiLocationManager({
    Key? key,
    required this.user,
    OkHiLocationManagerConfiguration? configuration,
    this.onSucess,
    this.onError,
    this.onCloseRequest,
  })  : locationManagerConfiguration =
            configuration ?? OkHiLocationManagerConfiguration(),
        super(key: key);

  @override
  _OkHiLocationManagerState createState() => _OkHiLocationManagerState();

  static setUser(OkHiUser user) {}
}

class _OkHiLocationManagerState extends State<OkHiLocationManager> {
  WebViewController? _controller;
  String? _accessToken;
  String? _authorizationToken;
  String? _appIdentifier;
  String? _appVersion;
  String _signInUrl = OkHiConstant.sandboxSignInUrl;
  String _locationManagerUrl = OkHiConstant.sandboxLocationManagerUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleInitState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return WillPopScope(
      onWillPop: _handleWillPopScope,
      child: WebView(
        initialUrl: _locationManagerUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
            name: 'FlutterOkHi',
            onMessageReceived: _handleMessageReceived,
          )
        },
        onWebViewCreated: _handleOnWebViewCreated,
        onPageFinished: _handlePageLoaded,
      ),
    );
  }

  Future<bool> _handleWillPopScope() async {
    bool canGoBack = await _controller?.canGoBack() ?? false;
    if (canGoBack) {
      await _controller?.goBack();
    }
    return !canGoBack;
  }

  _handleInitState() async {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    final configuration = OkHi.getConfiguration();
    if (configuration != null) {
      if (configuration.environmentRawValue == "dev") {
        _signInUrl = OkHiConstant.devSignInUrl;
        _locationManagerUrl = OkHiConstant.devLocationManagerUrl;
      } else if (configuration.environmentRawValue == "prod") {
        _signInUrl = OkHiConstant.prodSignInUrl;
        _locationManagerUrl = OkHiConstant.prodLocationManagerUrl;
      }
      final bytes =
          utf8.encode("${configuration.branchId}:${configuration.clientKey}");
      _accessToken = 'Token ${base64.encode(bytes)}';
      await _signInUser();
      await _getAppInformation();
      setState(() {
        _isLoading = false;
      });
    } else {
      //..TODO: throw unuthorised
    }
  }

  _handleOnWebViewCreated(WebViewController controller) {
    _controller = controller;
  }

  _handlePageLoaded(String page) {
    final payload = jsonEncode({
      "message": "select_location",
      "payload": {
        "style": {
          "base": {
            "color": widget.locationManagerConfiguration.color,
            "logo": widget.locationManagerConfiguration.logoUrl,
            "name": "OkHi"
          }
        },
        "user": {"phone": widget.user.phone},
        "auth": {"authToken": _authorizationToken},
        "context": {
          "container": {"name": _appIdentifier, "version": _appVersion},
          "developer": {"name": "external"},
          "library": {
            "name": "okhiFlutter",
            "version": OkHiConstant.libraryVersion
          },
          "platform": {"name": "flutter"}
        },
        "config": {
          "streetView": widget.locationManagerConfiguration.withStreetView,
          "appBar": {
            "color": widget.locationManagerConfiguration.color,
            "visible": widget.locationManagerConfiguration.withAppBar
          }
        }
      }
    });
    _controller?.evaluateJavascript("""
    function receiveMessage (data) {
      if (FlutterOkHi && FlutterOkHi.postMessage) {
        FlutterOkHi.postMessage(data);
      }
    }
    var bridge = { receiveMessage: receiveMessage };
    window.startOkHiLocationManager(bridge, $payload);
    """);
  }

  _handleMessageReceived(JavascriptMessage jsMessage) {
    final Map<String, dynamic> data = jsonDecode(jsMessage.message);
    final String message = data["message"];
    switch (message) {
      case "location_created":
      case "location_updated":
      case "location_selected":
        _handleMessageSuccess(data["payload"]);
        break;
      case "fatal_exit":
        _handleMessageError(data["payload"]);
        break;
      case "exit_app":
        _handleMessageExit();
        break;
      default:
    }
  }

  _handleMessageError(String data) {
    // ignore: todo
    // TODO: handle error
    final cb = widget.onError;
    if (cb != null) {
      cb();
    }
  }

  _handleMessageSuccess(Map<String, dynamic> data) {
    final cb = widget.onSucess;
    if (cb != null) {
      cb(OkHiLocationManagerResponse(data));
    }
  }

  _handleMessageExit() {
    final cb = widget.onCloseRequest;
    if (cb != null) {
      cb();
    }
  }

  _getAppInformation() async {
    const MethodChannel _channel = MethodChannel('okhi');
    _appIdentifier =
        await _channel.invokeMethod(OkHiNativeMethod.getAppIdentifier);
    _appVersion = await _channel.invokeMethod(OkHiNativeMethod.getAppVersion);
    print(_appIdentifier);
    print(_appVersion);
  }

  _signInUser() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': _accessToken ?? ''
    };
    final body = jsonEncode({
      "phone": widget.user.phone,
      "scopes": ["address"]
    });
    final parsedUrl = Uri.parse(_signInUrl);
    final response = await http.post(
      parsedUrl,
      headers: headers,
      body: body,
    );
    // ignore: todo
    //TODO: network error handling, response code handling
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      _authorizationToken = body["authorization_token"];
    }
  }
}

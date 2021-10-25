import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:okhi/models/okhi_constant.dart';
import 'package:okhi/models/okhi_user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../okhi.dart';

class OkHiLocationManagerConfiguration {
  late String color;
  late String logoUrl;
  late bool withAppBar;
  late bool withStreetView;

  OkHiLocationManagerConfiguration({
    String? color,
    String? logoUrl,
    bool? withAppBar,
    bool? withStreetView,
  }) {
    this.color = color ?? "#005d67";
    this.logoUrl = logoUrl ??
        "https://storage.googleapis.com/okhi-cdn/images/logos/okhi-logo-white.png";
    this.withAppBar = withAppBar ?? true;
    this.withStreetView = withStreetView ?? true;
  }
}

class OkHiLocationManager extends StatefulWidget {
  final OkHiUser user;
  late final OkHiLocationManagerConfiguration locationManagerConfiguration;

  OkHiLocationManager(
      {Key? key,
      required this.user,
      OkHiLocationManagerConfiguration? configuration})
      : locationManagerConfiguration =
            configuration ?? OkHiLocationManagerConfiguration(),
        super(key: key);

  @override
  _OkHiLocationManagerState createState() => _OkHiLocationManagerState();

  static setUser(OkHiUser user) {}
}

class _OkHiLocationManagerState extends State<OkHiLocationManager> {
  String? _authorizationToken;
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _signInUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_authorizationToken == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return WebView(
      initialUrl: 'https://dev-manager-v5.okhi.io',
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: {
        JavascriptChannel(
          name: 'FlutterOkHi',
          onMessageReceived: _handleMessageReceived,
        )
      },
      onWebViewCreated: _handleOnWebViewCreated,
      onPageFinished: _handlePageLoaded,
    );
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
          "container": {"name": "My Awesome App", "version": "1.0.0"},
          "developer": {"name": "external"},
          "library": {"name": "okhiFlutter", "version": "1.0.0"},
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
    print(jsMessage.message);
  }

  _signInUser() async {
    final config = OkHi.getConfiguration();
    // ignore: todo
    // TODO: throw unauthoirised error
    if (config == null) return;
    var url = OkHiConstant.SANDBOX_SIGN_IN_URL;
    if (config.environmentValue == "prod") {
      url = OkHiConstant.PROD_SIGN_IN_URL;
    } else if (config.environmentValue == "dev") {
      url = OkHiConstant.DEV_SIGN_IN_URL;
    }
    final bytes = utf8.encode("${config.branchId}:${config.clientKey}");
    final parsedUrl = Uri.parse(url);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token ${base64.encode(bytes)}'
    };
    final body = jsonEncode({
      "phone": widget.user.phone,
      "scopes": ["address"]
    });
    final response = await http.post(
      parsedUrl,
      headers: headers,
      body: body,
    );
    // ignore: todo
    // TODO: network error handling
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      setState(() {
        _authorizationToken = body["authorization_token"];
      });
    }
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../okhi.dart';
import '../models/okhi_user.dart';
import '../models/okhi_constant.dart';
import '../models/okhi_location_manager_configuration.dart';

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
  WebViewController? _controller;
  late String _accessToken;
  String? _authorizationToken;
  String _signInUrl = OkHiConstant.sandboxSignInUrl;
  String _locationManagerUrl = OkHiConstant.sandboxLocationManagerUrl;

  @override
  void initState() {
    super.initState();
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
      _signInUser();
    } else {
      //..
    }
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
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': _accessToken
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
    print(_signInUrl);
    print(response.body.toString());
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      setState(() {
        _authorizationToken = body["authorization_token"];
      });
    }
  }
}

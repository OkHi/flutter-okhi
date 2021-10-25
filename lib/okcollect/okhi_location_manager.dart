import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OkHiLocationManager extends StatefulWidget {
  const OkHiLocationManager({Key? key}) : super(key: key);

  @override
  _OkHiLocationManagerState createState() => _OkHiLocationManagerState();
}

class _OkHiLocationManagerState extends State<OkHiLocationManager> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'https://okhi.com',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

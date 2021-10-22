import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:okhi/okhi.dart';

void main() {
  runApp(const MyApp());
}

class FullButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const FullButton({Key? key, this.onPressed, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          35,
        ), // double.infinity is the width and 30 is the height
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  final String message;
  const MessageBox({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.shade400,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(message),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String message = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("OkHi"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FullButton(
                title: "Location Services Check",
                onPressed: _handleIsLocationServicesEnabled,
              ),
              FullButton(
                title: "Location Permission Check",
                onPressed: _handleIsLocationPermissionGranted,
              ),
              FullButton(
                title: "Background Location Permission Check",
                onPressed: _handleIsBackgroundLocationPermissionGranted,
              ),
              FullButton(
                title: "Google Play Services Permission Check",
                onPressed: _handleIsGooglePlayServicesAvailable,
              ),
              MessageBox(message: message)
            ],
          ),
        ),
      ),
    );
  }

  _handleIsLocationServicesEnabled() async {
    final result = await OkHi.isLocationServicesEnabled();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsLocationPermissionGranted() async {
    final result = await OkHi.isLocationPermissionGranted();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsBackgroundLocationPermissionGranted() async {
    final result = await OkHi.isBackgroundLocationPermissionGranted();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsGooglePlayServicesAvailable() async {
    final result = await OkHi.isGooglePlayServicesAvailable();
    setState(() {
      message = result.toString();
    });
  }
}

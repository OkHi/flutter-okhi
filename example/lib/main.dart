import 'package:flutter/material.dart';
import 'package:okhi/okhi.dart';
import 'package:okhi_example/screens/home.dart';

void main() {
  final config = OkHiAppConfiguration.withRawValue(
    branchId: "",
    clientKey: "",
    environmentRawValue: ""
  );
  OkHi.configure(config);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

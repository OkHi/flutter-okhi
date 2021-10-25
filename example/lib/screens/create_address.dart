import 'package:flutter/material.dart';
import 'package:okhi/okhi.dart';
import 'package:okhi_example/widgets/full_button.dart';

class CreateAddress extends StatelessWidget {
  const CreateAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create an address"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: OkHiLocationManager()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: FullButton(
                title: "Go back",
                onPressed: () {
                  _handleOnButtonPress(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleOnButtonPress(BuildContext context) {
    Navigator.pop(context, 'Woah');
  }
}

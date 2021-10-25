import 'package:flutter/material.dart';

class FullButton extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const FullButton({Key? key, this.onPressed, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(
          width,
          35,
        ), // double.infinity is the width and 30 is the height
      ),
    );
  }
}

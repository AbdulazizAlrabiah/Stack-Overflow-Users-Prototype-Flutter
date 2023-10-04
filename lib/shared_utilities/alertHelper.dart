import 'package:flutter/material.dart';

class AlertHelper {
  static final shared = AlertHelper._();

  AlertHelper._();

  showAlert(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    Widget okButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

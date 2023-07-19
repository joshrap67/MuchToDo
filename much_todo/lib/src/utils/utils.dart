import 'package:flutter/material.dart';

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void showSnackbar(String message, BuildContext context, {int milliseconds = 1500}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: milliseconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

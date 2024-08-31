import 'package:flutter/material.dart';

void showSnackbar(context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Center(child: Text(message))));
}

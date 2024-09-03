import 'package:flutter/material.dart';

TextStyle getTitleStyle(context) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(
        fontWeight: FontWeight.bold,
      );
}

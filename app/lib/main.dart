import 'package:facet/spash_page.dart';
import 'package:facet/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Facet",
      theme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        textTheme:
            GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          displayColor: darkColorScheme.primary,
          bodyColor: darkColorScheme.onBackground,
          decorationColor: darkColorScheme.tertiary,
        ),
      ),
      home: const StartPage(),
    );
  }
}

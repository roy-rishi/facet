import 'package:facet/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:facet/routes.dart';

void main() {
  usePathUrlStrategy(); // remove # in web url path
  runApp(MaterialApp.router(
    routerConfig: router,
  ));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.page});

  final Widget page;

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
      home: page,
    );
  }
}

import 'package:facet/spash_page.dart';
import 'package:facet/strava_connect_callback.dart';
import 'package:facet/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

void main() {
  // runApp(const AppRoot());
  runApp(MaterialApp.router(
    routerConfig: router,
  ));
}

class AppRoot extends StatelessWidget {
  AppRoot({super.key, required this.page});

  Widget page;

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

Widget stravaAuthCallbackHandler(state) {
  Map<String, String> params = state.uri.queryParameters;
  if (params["error"] == "access_denied") {
    throw UnimplementedError("User did not grant permission");
  }
  if (params["code"] == null || params["scope"] == null) {
    throw UnimplementedError(
        "Expected additional query params in Strava callback");
  }
  return StravaConnectCallback(
    code: params["code"]!,
    scope: params["scope"]!,
  );
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (_, __) => AppRoot(page: const StartPage()),
      routes: [
        GoRoute(
          path: "strava-auth",
          builder: (context, state) {
            return AppRoot(page: stravaAuthCallbackHandler(state));
          },
        ),
      ],
    ),
  ],
);

import 'package:facet/email_token_verification.dart';
import 'package:facet/splash_page.dart';
import 'package:facet/strava_connect_callback.dart';
import 'package:facet/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy(); // remove # in web url path
  runApp(MaterialApp.router(
    routerConfig: _router,
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

Widget _stravaAuthCallbackHandler(Map<String, String> params) {
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

abstract class Routes {
  static const email = "email";
  static const strava = "strava";
}

GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: "/",
      builder: (_, __) => AppRoot(page: const StartPage()),
      routes: [
        GoRoute(
          path: Routes.strava,
          builder: (_, state) =>
              _stravaAuthCallbackHandler(state.uri.queryParameters),
        ),
        GoRoute(
          path: Routes.email,
          builder: (_, state) => AppRoot(
            page: EmailTokenVerification(
              token: state.uri.queryParameters["t"]!,
            ),
          ),
        ),
      ],
    ),
  ],
);

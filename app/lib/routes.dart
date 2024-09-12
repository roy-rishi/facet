import 'package:facet/strava_login.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:facet/strava_callback.dart';
import 'package:facet/splash.dart';
import 'package:facet/main.dart';

Widget _stravaCallbackHandler(Map<String, String> params) {
  if (params["error"] == "access_denied") {
    throw UnimplementedError("User did not grant permission");
  }
  if (params["code"] == null || params["scope"] == null) {
    throw UnimplementedError(
        "Expected additional query params in Strava callback");
  }
  return AppRoot(
    page: StravaConnectCallback(
      code: params["code"]!,
      scope: params["scope"]!,
    ),
  );
}

abstract class Routes {
  static const login = "login";
  static const stravaCallback = "callback";
  static const home = "home";
}

GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: "/",
      builder: (_, __) => AppRoot(page: const StartPage()),
      routes: [
        GoRoute(
          path: Routes.stravaCallback,
          builder: (_, state) =>
              _stravaCallbackHandler(state.uri.queryParameters),
        ),
        GoRoute(
          path: Routes.login,
          builder: (_, state) => AppRoot(page: StravaConnectPage()),
        ),
        GoRoute(
          path: Routes.home,
          builder: (_, __) => const Scaffold(
              body: SafeArea(child: Center(child: Text("Home")))),
        ),
      ],
    ),
  ],
);

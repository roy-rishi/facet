import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:facet/routes.dart';
import 'package:facet/storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<bool> _exchangeCodeForTokenServerside(String code, String scope) async {
  // get fcm token and check for null
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) {
    throw ErrorDescription("Error: FCM token null");
  }
  final response = await http.post(
    Uri.parse("https://facet.rishiroy.com/strava/exchange-code"),
    headers: <String, String>{
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, String>{
      "code": code,
      "scope": scope,
      "FCMtoken": fcmToken,
    }),
  );
  if (response.statusCode == 200) {
    setAccessToken(response.body); // store token
  }
  return response.statusCode == 200;
}

class StravaConnectCallback extends StatefulWidget {
  StravaConnectCallback({super.key, required this.code, required this.scope});

  String code;
  String scope;

  @override
  State<StravaConnectCallback> createState() => _StravaConnectCallbackState();
}

class _StravaConnectCallbackState extends State<StravaConnectCallback> {
  final String titleMsg = "Completing Login";

  @override
  Widget build(BuildContext context) {
    final msgStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _exchangeCodeForTokenServerside(widget.code, widget.scope),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // check if successfully connected to strava
                if (snapshot.data!) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go("/" + Routes.home);
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Center(child: Text("Try Again")),
                          content: Text(
                              "Could not connect to Strava.\n\nCommon Issues:\nPermissions not granted: ensure all permissions are granted by checking every box on Strava's page.\nStale request: Your request may have timed out.\n\nPlease try again."),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  context.go("/" + Routes.login);
                                },
                                child: const Text("OK"))
                          ],
                        );
                      },
                    );
                  });
                }
              }
              return const CupertinoActivityIndicator(radius: 13);
            },
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(titleMsg, style: msgStyle),
          )),
        ],
      ),
    ));
  }
}

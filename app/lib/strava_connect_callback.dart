import 'package:facet/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> _exchangeCodeForTokenServerside(String code, String scope) async {
  final response = await http.post(
    Uri.parse("https://facet.rishiroy.com/strava/exchange-code"),
    headers: <String, String>{
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, String>{
      "code": code,
      "scope": scope,
      // TODO: use actual email and Facet access token
      "email": "test@rishiroy.com",
      "token": "test_token",
    }),
  );
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
  final String titleMsg = "Connecting...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child: Text(titleMsg, style: getTitleStyle(context))),
          SizedBox(
            height: 60,
            child: FutureBuilder(
              future:
                  _exchangeCodeForTokenServerside(widget.code, widget.scope),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                body: SafeArea(
                                    child: Text(snapshot.data!
                                        ? "Connected to Strava!"
                                        : "Try Again")))));
                  });
                }
                return const UnconstrainedBox(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}

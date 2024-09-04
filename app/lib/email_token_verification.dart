import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailTokenVerification extends StatefulWidget {
  const EmailTokenVerification({super.key, required this.token});

  final String token;

  @override
  State<EmailTokenVerification> createState() => _EmailTokenVerificationState();
}

class _EmailTokenVerificationState extends State<EmailTokenVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CupertinoActivityIndicator(
              radius: 13,
            ),
          ),
          Center(
              child: Text("Verifying Email",
                  style: Theme.of(context).textTheme.bodyLarge))
        ],
      ),
    ));
  }
}

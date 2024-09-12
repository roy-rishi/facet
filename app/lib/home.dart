import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:facet/storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder(
        future: getAccessToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
          }
          return const CupertinoActivityIndicator();
        },
      ),
    ));
  }
}

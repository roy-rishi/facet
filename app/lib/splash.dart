import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:facet/routes.dart';

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    // TODO: determine how to open, and conditionally form the url per strava guidelines:
    // https://developers.strava.com/docs/authentication/#oauthoverview
    mode: LaunchMode.platformDefault,
  )) {
    throw Exception("Could not launch $url");
  }
}

Future<int> verifyAuth() async {
  final response =
      await http.get(Uri.parse("https://facet.rishiroy.com/verify"));
  print(response.body);
  if (response.statusCode == 200) {
    return 200;
  }
  if (response.statusCode == 401) {
    return 401;
  }
  throw Exception(response.body);
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Future<int> _authStatus;

  // maintains constant height before and after loading
  static const double reservedLoadingHeight = 60;

  @override
  void initState() {
    super.initState();
    _authStatus = verifyAuth();
  }

  @override
  Widget build(BuildContext context) {
    final logoStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 100,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 18,
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text("Facet", style: logoStyle)),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "insights into every facet of your bike",
                    style: subtitleStyle,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: reservedLoadingHeight,
              child: FutureBuilder(
                future: _authStatus,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == 200) {
                      // TODO: move to home page
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Placeholder()));
                      });
                      return Container();
                    }
                    if (snapshot.data == 401) {
                      return TextButton.icon(
                        onPressed: () {
                          context.go("/" + Routes.login);
                        },
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: const Text("Login with Strava"),
                      );
                    }
                  }
                  return const UnconstrainedBox(
                    child: CupertinoActivityIndicator(radius: 15),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

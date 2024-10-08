import 'package:facet/dialogs.dart';
import 'package:facet/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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

class StravaConnectPage extends StatelessWidget {
  StravaConnectPage({super.key});

  final stravaOAuthUri = "https://www.strava.com/oauth/mobile/authorize?client_id=133457&redirect_uri=https://facet.rishiroy.com/${Routes.stravaCallback}&response_type=code&scope=activity:read_all";

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
          fontWeight: FontWeight.bold,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  softWrap: true,
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "Login with Strava", style: titleStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 14, left: 12, right: 12),
                      child: RichText(
                        softWrap: true,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  "You will be directed to your browser to authorize Facet to connect to Strava.",
                              style: bodyStyle,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 12, right: 12),
                      child: RichText(
                        softWrap: true,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  "This allows Facet to automatically retrieve your activities as soon as they're uploaded to Strava.",
                              style: bodyStyle,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // TODO: make the icon Strava's logo
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  _launchInBrowser(Uri.parse(stravaOAuthUri));
                },
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text("Login with Strava"),
              ),
              TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: stravaOAuthUri));
                    showSnackbar(context, "URL Copied");
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text("Having Issues? Copy URL")),
            ],
          )
        ],
      ),
    ));
  }
}

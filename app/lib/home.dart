import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:facet/storage.dart';
import 'package:facet/dialogs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileBlock extends StatelessWidget {
  const ProfileBlock({super.key});

  Future<String> _getImgURL() async {
    await Future.delayed(const Duration(seconds: 5));
    return "https://dgalywyr863hv.cloudfront.net/pictures/athletes/44597161/25714763/1/large.jpg";
  }

  Future<(String, String)> _getFullName() async {
    await Future.delayed(const Duration(seconds: 2));
    return ("Rishi", "Roy");
  }

  @override
  Widget build(BuildContext context) {
    final nameStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w900,
        );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 35, bottom: 35),
            child: Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: FutureBuilder(
                    future: _getImgURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CupertinoActivityIndicator();
                      } else if (snapshot.hasData) {
                        return Image.network(snapshot.data!);
                      } else {
                        return const Text("Failed to get image");
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: FutureBuilder(
                    future: _getFullName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CupertinoActivityIndicator();
                      } else if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${snapshot.data!.$1} ${snapshot.data!.$2}",
                                style: nameStyle),
                            Text("Welcome back, ${snapshot.data!.$1}!")
                          ],
                        );
                      } else {
                        return const Text("Failed to get name");
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            right: 17,
            child: Row(children: [
              IconButton(
                onPressed: () async {
                  launchUrl(
                    Uri.parse("https://www.strava.com/settings/profile"),
                    mode: LaunchMode.platformDefault,
                  );
                },
                icon: const Icon(Icons.edit_rounded),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ChecklistBlock extends StatefulWidget {
  final bool showNotif;
  final bool showOther; // dummy placeholder for future checklist items

  const ChecklistBlock(
      {super.key, required this.showNotif, required this.showOther});

  @override
  State<ChecklistBlock> createState() => _ChecklistBlockState();
}

class _ChecklistBlockState extends State<ChecklistBlock> {
  late bool showNotif;
  late bool showOther;

  @override
  void initState() {
    super.initState();
    showNotif = widget.showNotif;
    showOther = widget.showOther;
  }

  @override
  Widget build(BuildContext context) {
    if (showNotif == false && showOther == false) {
      return Container();
    } else {
      return Card(
        child: Column(
          children: [
            if (showNotif)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Notification Permissions",
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              // popup dialog explaining purpose of notifs, with option to remove this checklist item
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Center(
                                        child: Text("Enabling Notifications")),
                                    content: const Text(
                                        "Notifications provide an integral part of Facet's functionality.\n\nNotifications are used sparingly, and are never used for marketing. You may disable them at any time from your system's settings."),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            prefs.setBool(
                                                "user_removed_notif_checklist_item",
                                                true);
                                            setState(() {
                                              showNotif = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                              "Hide this checklist item without granting permission")),
                                      FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Go Back")),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.info_rounded)),
                        FilledButton(
                            onPressed: () async {
                              // request notif permission and check perm. status
                              final notifPermission = await FirebaseMessaging
                                  .instance
                                  .requestPermission(provisional: false);
                              final notifPermGranted =
                                  notifPermission.authorizationStatus ==
                                      AuthorizationStatus.authorized;
                              // if notif perm. granted:
                              if (notifPermGranted) {
                                setState(() {
                                  showNotif =
                                      false; // remove notif checklist item
                                });
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showSnackbar(context, "Permissions granted!");
                                });
                              } else {
                                // user was not presented with dialog to grant notif perm. (this can happen if
                                // they've been previously shown that dialog), or, they did not grant perm.
                                // in either case, display snackbar to direct them to system settings
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showSnackbar(context,
                                      "Grant notification permission from the\nsystem's settings");
                                });
                              }
                            },
                            child: const Text("Grant")),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      );
    }
  }
}

Future<ChecklistBlock> _determineChecklistItems() async {
  final notifPermission =
      await FirebaseMessaging.instance.getNotificationSettings();
  final notifPermGranted =
      notifPermission.authorizationStatus == AuthorizationStatus.authorized;
  final userRemovedNotifPermItem =
      prefs.getBool("user_removed_notif_checklist_item") ?? false;
  return ChecklistBlock(
      showNotif: !notifPermGranted && !userRemovedNotifPermItem,
      showOther: true); // dummy true bool for future checklist items
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        // profile block
        ProfileBlock(),

        // checklist block
        FutureBuilder(
          future: _determineChecklistItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(),
                ],
              );
            } else if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const Text("Error: Could not load checklist");
          },
        ),
      ],
    )));
  }
}

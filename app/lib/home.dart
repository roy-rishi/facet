import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:facet/storage.dart';
import 'package:facet/dialogs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Checklist extends StatefulWidget {
  final bool showNotif;
  final bool showOther; // dummy placeholder for future checklist items

  const Checklist(
      {super.key, required this.showNotif, required this.showOther});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
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
                                            prefs.setBool("user_removed_notif_checklist_item", true);
                                            setState(() {
                                              showNotif = false;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                              "Remove this checklist item without granting permission")),
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

Future<Checklist> _determineChecklistItems() async {
  final notifPermission =
      await FirebaseMessaging.instance.getNotificationSettings();
  final notifPermGranted =
      notifPermission.authorizationStatus == AuthorizationStatus.authorized;
  final userRemovedNotifPermItem = prefs.getBool("user_removed_notif_checklist_item") ?? false;
  return Checklist(
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
        // checklist
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
        )
      ],
    )));
  }
}

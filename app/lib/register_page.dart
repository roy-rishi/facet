import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.emailAddress,});

  final emailAddress;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const double _textFieldWidth = 300;
  static const double _textFieldHeight = 50;
  final _emailTextController = TextEditingController();
  final _passTextController = TextEditingController();
  final _passConfirmTextController = TextEditingController();
  final _secretTextController = TextEditingController();

  bool _showPassField = false;

  @override
  void initState() {
    super.initState();
    _emailTextController.text = widget.emailAddress;
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .displayMedium!
        .copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: Text("Sign Up", style: titleStyle)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // show email field before sending verification email
                if (!_showPassField)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SizedBox(
                      height: _textFieldHeight,
                      width: _textFieldWidth,
                      child: TextField(
                        controller: _emailTextController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),

                // show password field after sending verification email
                if (_showPassField)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SizedBox(
                          height: _textFieldHeight,
                          width: _textFieldWidth,
                          child: TextField(
                            controller: _passTextController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Create password",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SizedBox(
                          height: _textFieldHeight,
                          width: _textFieldWidth,
                          child: TextField(
                            controller: _passConfirmTextController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Re-enter password",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                FilledButton(
                  child: const Text("Continue"),
                  onPressed: () {
                    if (!_showPassField) {
                      // password fields not showing yet
                      setState(() {
                        _showPassField = true;
                      });
                      // display dialog
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                const Center(child: Text("Verify Your Email")),
                            content: const Text(
                                "An email has been sent to egbdf@gmail.com with further instructions."),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"))
                            ],
                          );
                        },
                      );
                    } else {
                      // password fields already showing
                      final pass1 = _passTextController.text.trim();
                      final pass2 = _passConfirmTextController.text.trim();
                      final secret = _secretTextController.text.trim();
                      if (pass1 == "" || pass2 == "" || secret == "") {
                        // incomplete fields
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Center(child: Text("Incomplete fields"))));
                      } else if (pass1 != pass2) {
                        // passwords do not match
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Center(
                                    child: Text("Passwords do not match"))));
                      } else {
                        // check if secret phrase is valid

                      }
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

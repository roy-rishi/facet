import 'package:facet/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _textFieldWidth = 300;
  static const double _textFieldHeight = 47;
  final _emailTextController = TextEditingController();
  final _passTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .displayLarge!
        .copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: Text("Login", style: titleStyle)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
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
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  child: SizedBox(
                    height: _textFieldHeight,
                    width: _textFieldWidth,
                    child: TextField(
                      obscureText: true,
                      controller: _passTextController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      child: Text("Sign In"),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Placeholder()));
                      },
                    ),
                    TextButton(
                      child: Text("Or, Sign Up"),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage(
                                    emailAddress:
                                        _emailTextController.text.trim())));
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

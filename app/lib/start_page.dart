import 'package:flutter/material.dart';

class OnStart extends StatelessWidget {
  const OnStart({super.key});

  @override
  Widget build(BuildContext context) {
    final logoStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 100,
          // color: Theme.of(context).colorScheme.primary,
        );
    final subtitleStyle = Theme.of(context).textTheme.labelLarge!.apply(
          fontSizeDelta: 4.5,
        );

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text("Facet", style: logoStyle)),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text("insights into every facet of your bike",
                    style: subtitleStyle),
              ),
            ],
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Placeholder()));
              },
              // child: CircularProgressIndicator()
              child: Text("Sign In", style: Theme.of(context).textTheme.titleLarge),
              ),
        ],
      ),
    );
  }
}

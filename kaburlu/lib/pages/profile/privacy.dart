import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_outlined),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: Center(
        child: Text(
          'Kaburlu Privacy Policy',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
    );
  }
}

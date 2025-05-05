import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Menu principal',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Paramètres"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text("Aide"),
          onTap: () {},
        ),
      ],
    );
  }
}

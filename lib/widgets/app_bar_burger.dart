import 'package:flutter/material.dart';
import '../main.dart';

class BurgerButton extends StatelessWidget {
  const BurgerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      onPressed: () => menuKey.currentState?.toggleMenu(),
    );
  }
}

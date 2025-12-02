import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'admin_menu_screen.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use a provider to control the drawer if needed,
    // but for simple navigation, the internal state is often enough.
    // However, to open the drawer from the AppBar, we need a controller.
    final GlobalKey<SliderDrawerState> key = GlobalKey<SliderDrawerState>();

    return SliderDrawer(
      key: key,
      appBar: const SizedBox.shrink(), // Hide default app bar
      slider: const AdminMenuScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Console',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => key.currentState?.toggle(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2563EB), // blue-600
                  Color(0xFF0891B2), // cyan-600
                ],
              ),
            ),
          ),
        ),
        body: child,
      ),
    );
  }
}

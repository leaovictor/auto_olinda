import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shell/admin_shell.dart';

/// Reusable AppBar widget for admin screens on mobile
/// Includes a menu button that opens the SliderDrawer
class AdminMobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showMenuButton;
  final Widget? leading;
  final bool centerTitle;

  const AdminMobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showMenuButton = true,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      leading: leading,
      actions: [
        if (actions != null) ...actions!,
        if (isMobile && showMenuButton)
          IconButton(
            onPressed: () {
              final toggle = ref.read(adminDrawerToggleProvider);
              toggle?.call();
            },
            icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
            tooltip: 'Menu',
          ),
      ],
    );
  }
}

/// A simple header widget for admin screens without AppBar
/// Use this inside screens that handle their own layout
class AdminMobileHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AdminMobileHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            if (actions != null) ...actions!,
            if (isMobile) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final toggle = ref.read(adminDrawerToggleProvider);
                  toggle?.call();
                },
                icon: const Icon(Icons.menu),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                tooltip: 'Menu',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

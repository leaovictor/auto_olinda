import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 24,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name != null && name!.isNotEmpty
        ? name!.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: fontSize ?? radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color:
                      textColor ??
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }
}

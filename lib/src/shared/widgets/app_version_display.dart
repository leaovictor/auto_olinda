import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionDisplay extends StatelessWidget {
  final TextStyle? style;
  final bool showBuildNumber;
  final Color? color;

  const AppVersionDisplay({
    super.key,
    this.style,
    this.showBuildNumber = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final info = snapshot.data!;
        final version = info.version;
        final buildNumber = info.buildNumber;

        final text = showBuildNumber ? 'v$version+$buildNumber' : 'v$version';

        return Text(
          text,
          style:
              style?.copyWith(color: color) ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    color ??
                    Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
        );
      },
    );
  }
}

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            if (!controller.isIdle)
              Positioned(
                top: 35.0 * controller.value,
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    value: controller.isLoading ? null : controller.value,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(0, 100.0 * controller.value),
              child: child,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Widget de Watermark dinâmico para rastreabilidade de screenshots
///
/// Exibe uma marca d'água sutil com ID do usuário sobre o conteúdo,
/// permitindo rastrear a origem de prints vazados.
class DynamicWatermark extends StatelessWidget {
  final Widget child;
  final String userId;
  final String? userEmail;
  final double opacity;
  final Color? color;

  const DynamicWatermark({
    super.key,
    required this.child,
    required this.userId,
    this.userEmail,
    this.opacity = 0.05,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final watermarkColor = color ?? theme.colorScheme.onSurface;

    // Gerar texto do watermark (ID parcial + timestamp)
    final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
    final watermarkText = 'ID:$shortId';

    return Stack(
      children: [
        child,
        // Overlay de watermarks em padrão diagonal
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: CustomPaint(
                painter: _WatermarkPainter(
                  text: watermarkText,
                  color: watermarkColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter que desenha watermarks em padrão diagonal
class _WatermarkPainter extends CustomPainter {
  final String text;
  final Color color;

  _WatermarkPainter({required this.text, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Salvar estado do canvas
    canvas.save();

    // Rotacionar -30 graus
    canvas.rotate(-0.5); // aproximadamente -30 graus

    // Desenhar watermarks em grade
    const spacing = 150.0;
    for (double y = -size.height; y < size.height * 2; y += spacing) {
      for (double x = -size.width; x < size.width * 2; x += spacing) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    // Restaurar estado do canvas
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget wrapper que aplica watermark em telas sensíveis
///
/// Uso:
/// ```dart
/// ConfidentialScreen(
///   userId: currentUser.uid,
///   child: YourContentWidget(),
/// )
/// ```
class ConfidentialScreen extends StatelessWidget {
  final Widget child;
  final String userId;
  final String? userEmail;
  final bool showAlphaWarning;

  const ConfidentialScreen({
    super.key,
    required this.child,
    required this.userId,
    this.userEmail,
    this.showAlphaWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Conteúdo com watermark
        DynamicWatermark(userId: userId, userEmail: userEmail, child: child),

        // Badge ALFA no canto (opcional)
        if (showAlphaWarning)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ALFA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

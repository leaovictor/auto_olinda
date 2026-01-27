import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço de segurança para bloqueio de screenshots e registro de violações
class ScreenSecurityService {
  static final ScreenSecurityService _instance =
      ScreenSecurityService._internal();
  factory ScreenSecurityService() => _instance;
  ScreenSecurityService._internal();

  /// Returns the platform name in a web-safe way
  static String _getPlatformName() {
    if (kIsWeb) return 'web';
    return Platform.operatingSystem;
  }

  bool _isSecured = false;
  String? _currentUserId;

  /// Inicializa o serviço com o ID do usuário atual
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

  /// Ativa a proteção de tela (bloqueia screenshots no Android)
  ///
  /// No Android: Usa FLAG_SECURE para impedir prints e gravação
  /// No iOS: Não há API nativa equivalente, apenas detecção
  /// Na Web: Não é possível bloquear
  Future<void> enableSecureMode() async {
    if (_isSecured) return;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        _isSecured = true;
        // debugPrint(
        //   '🔒 [Security] Modo seguro ATIVADO - Screenshots bloqueados',
        // );
      } else {
        // debugPrint('⚠️ [Security] Modo seguro não disponível nesta plataforma');
      }
    } catch (e) {
      // debugPrint('❌ [Security] Erro ao ativar modo seguro: $e');
    }
  }

  /// Desativa a proteção de tela
  Future<void> disableSecureMode() async {
    if (!_isSecured) return;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        _isSecured = false;
        // debugPrint('🔓 [Security] Modo seguro DESATIVADO');
      }
    } catch (e) {
      // debugPrint('❌ [Security] Erro ao desativar modo seguro: $e');
    }
  }

  /// Registra uma tentativa de screenshot no Firestore
  Future<void> logScreenshotAttempt({
    required String screenName,
    String? additionalInfo,
  }) async {
    if (_currentUserId == null) return;

    try {
      await FirebaseFirestore.instance.collection('security_logs').add({
        'type': 'screenshot_attempt',
        'userId': _currentUserId,
        'screenName': screenName,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': _getPlatformName(),
      });

      // debugPrint(
      //   '📸 [Security] Tentativa de screenshot registrada: $screenName',
      // );
    } catch (e) {
      // debugPrint('❌ [Security] Erro ao registrar tentativa: $e');
    }
  }

  /// Exibe um alerta de violação do NDA
  static void showViolationAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Atenção!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'A captura de tela desta página é uma VIOLAÇÃO do Acordo de Confidencialidade (NDA) que você assinou.\n\n'
          'Esta tentativa foi registrada e pode resultar em penalidades legais.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Exibe um SnackBar de aviso rápido
  static void showQuickWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Screenshots são proibidos nesta tela (NDA)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Mixin para telas que precisam de proteção contra screenshots
///
/// Uso:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with SecureScreenMixin {
///   @override
///   void initState() {
///     super.initState();
///     enableSecureScreen();
///   }
///
///   @override
///   void dispose() {
///     disableSecureScreen();
///     super.dispose();
///   }
/// }
/// ```
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  final _securityService = ScreenSecurityService();

  /// Ativa a proteção de screenshot para esta tela
  Future<void> enableSecureScreen() async {
    await _securityService.enableSecureMode();
  }

  /// Desativa a proteção de screenshot
  Future<void> disableSecureScreen() async {
    await _securityService.disableSecureMode();
  }

  /// Registra tentativa de screenshot (chamar quando detectar)
  Future<void> logScreenshotAttempt(String screenName) async {
    await _securityService.logScreenshotAttempt(screenName: screenName);
    if (mounted) {
      ScreenSecurityService.showViolationAlert(context);
    }
  }
}

/// Widget wrapper que automaticamente protege seu conteúdo
class SecureScreen extends StatefulWidget {
  final Widget child;
  final String screenName;
  final bool showWarningOnMount;

  const SecureScreen({
    super.key,
    required this.child,
    required this.screenName,
    this.showWarningOnMount = false,
  });

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> with SecureScreenMixin {
  @override
  void initState() {
    super.initState();
    enableSecureScreen();

    if (widget.showWarningOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScreenSecurityService.showQuickWarning(context);
      });
    }
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

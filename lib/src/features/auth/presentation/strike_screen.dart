import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../data/auth_repository.dart';
import 'package:lavaflow_app/core/providers/system_settings_provider.dart';

class StrikeScreen extends ConsumerStatefulWidget {
  const StrikeScreen({super.key});

  @override
  ConsumerState<StrikeScreen> createState() => _StrikeScreenState();
}

class _StrikeScreenState extends ConsumerState<StrikeScreen> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // We can't easily read async provider in initState synchronously
    // But we can start the timer and letting it update in the callback
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
    // Run once immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTimeLeft());
  }

  void _updateTimeLeft() {
    if (!mounted) return;
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;
    final strikeUntil = user?.strikeUntil;

    if (strikeUntil == null) {
      // Don't cancel timer yet, maybe user is loading
      if (!userAsync.isLoading && user != null) {
        // User loaded and has no strike?
        _timer?.cancel();
      }
      return;
    }

    final now = DateTime.now();
    if (strikeUntil.isAfter(now)) {
      setState(() {
        _timeLeft = strikeUntil.difference(now);
      });
    } else {
      // Strike over?
      setState(() {
        _timeLeft = Duration.zero;
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final supportPhone = ref.watch(supportPhoneNumberProvider);
    ref.watch(currentUserProfileProvider); // Watch to rebuild on user updates

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Warning Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50], // Light red bg
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.block, size: 64, color: Colors.red[600])
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1000.ms,
                    ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Conta Temporariamente Bloqueada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Detectamos uma ausência (No-Show) no seu último agendamento. Para garantir a qualidade do serviço para todos, sua conta ficará bloqueada por 24 horas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Timer Card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Liberado em:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_timeLeft),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight
                            .bold, // Monospace font usually better for timer but let's stick to default bold
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Support Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchWhatsApp(context, supportPhone),
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Falar com o Suporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Logout (Optional, if they want to switch account)
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String? phoneNumber,
  ) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de suporte não configurado.')),
      );
      return;
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final user = ref.read(currentUserProfileProvider).value;
    final strikeReason = user?.lastStrikeReason ?? "Bloqueio";

    final uri = Uri.parse(
      'https://wa.me/$cleanNumber?text=Olá, minha conta está bloqueada ($strikeReason). Gostaria de ajuda.',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }
}

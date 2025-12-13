import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'multi_step_acceptance_screen.dart';
import '../domain/nda_content.dart';
import '../../../shared/utils/app_toast.dart';

class NdaCheckScreen extends ConsumerStatefulWidget {
  const NdaCheckScreen({super.key});

  @override
  ConsumerState<NdaCheckScreen> createState() => _NdaCheckScreenState();
}

class _NdaCheckScreenState extends ConsumerState<NdaCheckScreen> {
  late DateTime _acceptanceDate;
  late String _ndaText;

  @override
  void initState() {
    super.initState();
    _acceptanceDate = DateTime.now();
    _ndaText = NdaContent.generateFullText(_acceptanceDate);
  }

  Future<void> _handleAccept() async {
    await ref.read(authControllerProvider.notifier).acceptNda(_ndaText);
    // Redirect will be handled by AppRouter watching the user profile update
  }

  void _handleDecline() {
    ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: 'Erro ao salvar: ${state.error}');
      }
    });

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiStepAcceptanceScreen(
      acceptanceDate: _acceptanceDate,
      onAccept: _handleAccept,
      onDecline: _handleDecline,
    );
  }
}

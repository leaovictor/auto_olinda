
import sys

file_path = '/home/victorleao/Documentos/auto_olinda/lib/src/features/booking/presentation/booking_controller.dart'

new_code = r'''    } catch (e) {
      // 1. Clean extraction of error details
      String rawMessage = e.toString();
      String? code;
      String? details;

      // Try to treat as FirebaseFunctionsException (via dynamic to avoid import if not present)
      try {
        final dynamic customE = e;
        if (customE.runtimeType.toString().contains('FirebaseFunctionsException')) {
          try { code = customE.code?.toString(); } catch(_) {}
          try { details = customE.message?.toString(); } catch(_) {}
          if (details != null && details!.isNotEmpty) rawMessage = details!;
        }
      } catch (_) {
        // Fallback to string parsing
      }

      // If code is still null, try to parse from string "[firebase_functions/code] message"
      if (code == null && rawMessage.contains('firebase_functions/')) {
        final start = rawMessage.indexOf('/') + 1;
        final end = rawMessage.indexOf(']');
        if (start > 0 && end > start) {
          code = rawMessage.substring(start, end);
        }
      }
      
      // Cleanup generic prefixes from message if present
      if (details == null) {
        // Remove [firebase_functions/code] prefix
        if (rawMessage.contains('] ')) {
          details = rawMessage.split('] ').last;
        } else {
          details = rawMessage;
        }
      }

      final messageLower = (details ?? rawMessage).toLowerCase();
      final codeLower = (code ?? '').toLowerCase();
      String errorMessage;

      // 2. Map to user friendly messages
      if (codeLower == 'resource-exhausted' || messageLower.contains('resource-exhausted')) {
         if (messageLower.contains('limite')) {
             errorMessage = details ?? 'Limite do plano atingido!';
         } else if (messageLower.contains('esgotado') || messageLower.contains('cheio')) {
             errorMessage = 'Horário esgotado! Por favor escolha outro horário.';
         } else {
             errorMessage = details ?? 'Limite de agendamentos atingido.';
         }
      } else if (codeLower == 'failed-precondition' || messageLower.contains('failed-precondition')) {
         if (messageLower.contains('antecedência')) {
             errorMessage = 'Antecedência mínima necessária (2h).';
         } else if (messageLower.contains('fechado') || messageLower.contains('funcionamento')) {
             errorMessage = 'Estabelecimento fechado neste horário/dia.';
         } else {
             errorMessage = details ?? 'Não foi possível agendar. Verifique as regras.';
         }
      } else if (codeLower == 'permission-denied' || messageLower.contains('permission-denied')) {
          errorMessage = details ?? 'Ação não permitida.';
      } else if (codeLower == 'already-exists' || messageLower.contains('already-exists')) {
          errorMessage = 'Já existe um agendamento para este veículo neste horário.';
      } else if (codeLower == 'unauthenticated' || messageLower.contains('unauthenticated')) {
          errorMessage = 'Você precisa estar logado.';
      } else {
          // Fallback: Show the clean message from server
          errorMessage = details ?? rawMessage;
      }

      state = state.copyWith(error: errorMessage);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }'''

with open(file_path, 'r') as f:
    lines = f.readlines()

# Indices: 216 to 285 (1-based) match indices 215 to 284 (0-based)
# We want to keep 0..214 (lines[:215])
# We want to keep 285..end (lines[285:])
# So we remove 215..284.

# Check that line 215 is 'catch' to be safe
if 'catch' not in lines[215]:
    print(f"Error: Line 216 is not catch block: {lines[215]}")
    sys.exit(1)

final_content = ''.join(lines[:215]) + new_code + '\n' + ''.join(lines[285:])

with open(file_path, 'w') as f:
    f.write(final_content)

print("Successfully patched file.")

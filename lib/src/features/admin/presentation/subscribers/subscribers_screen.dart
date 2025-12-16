import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/atoms/app_loader.dart';
import '../../../../features/auth/domain/app_user.dart';
import '../../../../features/subscription/domain/subscriber.dart';
import '../../../../shared/utils/app_toast.dart';
import '../../data/admin_repository.dart';

/// Combined user + subscription data for admin view
class UserSubscription {
  final AppUser user;
  final Subscriber? subscription;

  UserSubscription({required this.user, this.subscription});

  String get status => subscription?.status ?? 'none';
  bool get isActive => status == 'active' || status == 'trialing';
  bool get isPaused => status == 'paused';
  bool get isCanceled => status == 'canceled';
  bool get hasNoSubscription => subscription == null;
}

/// Provider that combines all users with their subscriptions
final usersWithSubscriptionsProvider = FutureProvider<List<UserSubscription>>((
  ref,
) async {
  final users = await ref.watch(adminUsersProvider.future);
  final subscribers = await ref.watch(subscribersProvider.future);

  final subscriptionMap = <String, Subscriber>{};
  for (final sub in subscribers) {
    subscriptionMap[sub.userId] = sub;
  }

  return users.map((user) {
    return UserSubscription(
      user: user,
      subscription: subscriptionMap[user.uid],
    );
  }).toList();
});

enum SubscriptionFilter { all, active, paused, canceled, none }

class SubscribersScreen extends ConsumerStatefulWidget {
  const SubscribersScreen({super.key});

  @override
  ConsumerState<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends ConsumerState<SubscribersScreen> {
  SubscriptionFilter _filter = SubscriptionFilter.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserSubscription> _filterUsers(List<UserSubscription> users) {
    var filtered = users;

    // Apply status filter
    switch (_filter) {
      case SubscriptionFilter.active:
        filtered = filtered.where((u) => u.isActive).toList();
        break;
      case SubscriptionFilter.paused:
        filtered = filtered.where((u) => u.isPaused).toList();
        break;
      case SubscriptionFilter.canceled:
        filtered = filtered.where((u) => u.isCanceled).toList();
        break;
      case SubscriptionFilter.none:
        filtered = filtered.where((u) => u.hasNoSubscription).toList();
        break;
      case SubscriptionFilter.all:
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((u) {
        final name = u.user.displayName?.toLowerCase() ?? '';
        final email = u.user.email.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _pauseSubscription(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Suspender Assinatura',
      'A cobrança será pausada. O usuário manterá acesso até a próxima renovação.',
    );
    if (!confirmed) return;

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('adminPauseSubscription').call({
        'userId': userId,
      });
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Assinatura suspensa com sucesso.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _resumeSubscription(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Reativar Assinatura',
      'A cobrança será retomada normalmente.',
    );
    if (!confirmed) return;

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('adminResumeSubscription').call({
        'userId': userId,
      });
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Assinatura reativada com sucesso.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _cancelSubscription(String userId) async {
    final cancelNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text('Como deseja cancelar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ao fim do período'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Imediatamente'),
          ),
        ],
      ),
    );

    if (cancelNow == null) return;

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('adminCancelSubscription').call({
        'userId': userId,
        'cancelAtPeriodEnd': cancelNow,
      });
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Assinatura cancelada.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _deleteSubscription(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Excluir Assinatura',
      'Isso remove apenas do sistema local. O registro permanece no Stripe.',
    );
    if (!confirmed) return;

    try {
      await ref.read(adminRepositoryProvider).deleteSubscription(userId);
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Registro excluído.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _adjustBonusWashes(UserSubscription userSub) async {
    final sub = userSub.subscription;
    if (sub == null) return;

    final currentBonus = sub.bonusWashes;
    final controller = TextEditingController(text: currentBonus.toString());

    final newValue = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar Lavagens Bônus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lavagens bônus são adicionadas ao limite do plano. '
              'Use para conceder lavagens extras ao assinante.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Lavagens Bônus',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context, value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newValue == null) return;

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('adminAdjustBonusWashes').call({
        'userId': userSub.user.uid,
        'bonusWashes': newValue,
      });
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(
          context,
          message: 'Lavagens bônus atualizadas para $newValue.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _grantPremiumDays(UserSubscription userSub) async {
    final daysController = TextEditingController(text: '30');

    final days = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conceder Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conceder acesso premium gratuito para:',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              userSub.user.displayName ?? userSub.user.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dias de Premium',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixText: 'dias',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(daysController.text) ?? 0;
              if (value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Conceder'),
          ),
        ],
      ),
    );

    if (days == null || days <= 0) return;

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('adminGrantPremiumDays').call({
        'userId': userSub.user.uid,
        'days': days,
      });
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Premium concedido por $days dias.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _suspendAccount(UserSubscription userSub) async {
    final confirmed = await _showConfirmDialog(
      'Suspender Conta',
      'O usuário não poderá fazer novos agendamentos. Deseja continuar?',
    );
    if (!confirmed) return;

    try {
      await ref
          .read(adminRepositoryProvider)
          .updateUserStatus(userSub.user.uid, 'suspended');
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Conta suspensa.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _reactivateAccount(UserSubscription userSub) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateUserStatus(userSub.user.uid, 'active');
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Conta reativada.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  Future<void> _deleteAccount(UserSubscription userSub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ATENÇÃO: Esta ação não pode ser desfeita!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Usuário: ${userSub.user.displayName ?? userSub.user.email}'),
            const SizedBox(height: 8),
            Text(
              'A conta será marcada como excluída e o usuário perderá acesso.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(adminRepositoryProvider)
          .updateUserStatus(userSub.user.uid, 'deleted');
      ref.invalidate(usersWithSubscriptionsProvider);
      if (mounted) {
        AppToast.success(context, message: 'Conta excluída.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(usersWithSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários e Assinaturas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Todos', SubscriptionFilter.all),
                const SizedBox(width: 8),
                _buildFilterChip('Ativos', SubscriptionFilter.active),
                const SizedBox(width: 8),
                _buildFilterChip('Pausados', SubscriptionFilter.paused),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelados', SubscriptionFilter.canceled),
                const SizedBox(width: 8),
                _buildFilterChip('Sem Assinatura', SubscriptionFilter.none),
              ],
            ),
          ),
          // User list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filtered = _filterUsers(users);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum usuário encontrado.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final userSub = filtered[index];
                    return _buildUserCard(userSub);
                  },
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SubscriptionFilter filter) {
    final isSelected = _filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _buildUserCard(UserSubscription userSub) {
    final user = userSub.user;
    final sub = userSub.subscription;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(
            userSub.status,
          ).withValues(alpha: 0.2),
          child: Text(
            (user.displayName ?? user.email)[0].toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(userSub.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.displayName ?? 'Sem nome'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email ?? 'Sem email'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(userSub.status),
                if (sub != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Desde ${DateFormat('dd/MM/yy').format(sub.startDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (sub.bonusWashes > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 12,
                            color: Colors.purple[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+${sub.bonusWashes}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: _buildActionsMenu(userSub),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String label;
    Color color;

    switch (status) {
      case 'active':
      case 'trialing':
        label = 'Ativo';
        color = Colors.green;
        break;
      case 'paused':
        label = 'Pausado';
        color = Colors.orange;
        break;
      case 'canceled':
        label = 'Cancelado';
        color = Colors.red;
        break;
      case 'incomplete':
      case 'past_due':
        label = 'Pendente';
        color = Colors.amber;
        break;
      default:
        label = 'Sem assinatura';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
      case 'trialing':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionsMenu(UserSubscription userSub) {
    final isSuspended = userSub.user.status == 'suspended';
    final isDeleted = userSub.user.status == 'deleted';

    // Don't show menu for deleted users
    if (isDeleted) {
      return const SizedBox.shrink();
    }

    // For non-subscribers, show account management options
    if (userSub.hasNoSubscription) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (action) {
          switch (action) {
            case 'grant_premium':
              _grantPremiumDays(userSub);
              break;
            case 'suspend':
              _suspendAccount(userSub);
              break;
            case 'reactivate':
              _reactivateAccount(userSub);
              break;
            case 'delete':
              _deleteAccount(userSub);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'grant_premium',
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: Colors.purple),
              title: Text('Conceder Premium'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (isSuspended)
            const PopupMenuItem(
              value: 'reactivate',
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Reativar Conta'),
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            const PopupMenuItem(
              value: 'suspend',
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.orange),
                title: Text('Suspender Conta'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text('Excluir Conta'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case 'pause':
            _pauseSubscription(userSub.user.uid);
            break;
          case 'resume':
            _resumeSubscription(userSub.user.uid);
            break;
          case 'cancel':
            _cancelSubscription(userSub.user.uid);
            break;
          case 'delete':
            _deleteSubscription(userSub.user.uid);
            break;
          case 'bonus':
            _adjustBonusWashes(userSub);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (userSub.isActive) {
          items.add(
            PopupMenuItem(
              value: 'bonus',
              child: ListTile(
                leading: Icon(Icons.add_circle, color: Colors.purple),
                title: Text('Ajustar Lavagens'),
                subtitle: Text(
                  'Bônus: ${userSub.subscription?.bonusWashes ?? 0}',
                  style: const TextStyle(fontSize: 11),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
          items.add(
            const PopupMenuItem(
              value: 'pause',
              child: ListTile(
                leading: Icon(Icons.pause, color: Colors.orange),
                title: Text('Suspender'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
          items.add(
            const PopupMenuItem(
              value: 'cancel',
              child: ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('Cancelar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
        }

        if (userSub.isPaused) {
          items.add(
            const PopupMenuItem(
              value: 'resume',
              child: ListTile(
                leading: Icon(Icons.play_arrow, color: Colors.green),
                title: Text('Reativar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
          items.add(
            const PopupMenuItem(
              value: 'cancel',
              child: ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text('Cancelar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
        }

        if (userSub.isCanceled) {
          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir registro'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}

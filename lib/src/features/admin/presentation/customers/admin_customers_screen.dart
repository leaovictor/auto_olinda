import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/admin_repository.dart';
import '../../../auth/domain/app_user.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../../../common_widgets/atoms/app_text_field.dart';
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../../shared/utils/app_toast.dart';
import 'widgets/edit_customer_dialog.dart';
import '../shell/admin_shell.dart';

class AdminCustomersScreen extends ConsumerStatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  ConsumerState<AdminCustomersScreen> createState() =>
      _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends ConsumerState<AdminCustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Clientes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        actions: isMobile
            ? [
                IconButton(
                  onPressed: () {
                    final toggle = ref.read(adminDrawerToggleProvider);
                    toggle?.call();
                  },
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                ),
              ]
            : null,
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminUsersProvider);
          // Wait a bit to show the loading indicator
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppTextField(
                    label: 'Buscar Cliente',
                    hint: 'Nome, email ou telefone',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: usersAsync.when(
                    data: (users) {
                      final filteredUsers = users.where((user) {
                        final name = user.displayName?.toLowerCase() ?? '';
                        final email = user.email.toLowerCase();
                        final phone = user.phoneNumber?.toLowerCase() ?? '';
                        return name.contains(_searchQuery) ||
                            email.contains(_searchQuery) ||
                            phone.contains(_searchQuery);
                      }).toList();

                      if (filteredUsers.isEmpty) {
                        return const Center(
                          child: Text('Nenhum cliente encontrado.'),
                        );
                      }

                      if (isWide) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(context, user);
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(context, user);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Erro: $err')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final isSuspended = user.status == 'suspended';
    final isCancelled = user.status == 'cancelled';

    Color statusColor = Colors.green;
    if (isSuspended) statusColor = Colors.orange;
    if (isCancelled) statusColor = Colors.red;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Slidable(
        key: ValueKey(user.uid),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) => EditCustomerDialog(user: user),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            if (!isCancelled) ...[
              if (isSuspended)
                SlidableAction(
                  onPressed: (context) {
                    _updateStatus(user.uid, 'active');
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle,
                  label: 'Reativar',
                )
              else
                SlidableAction(
                  onPressed: (context) {
                    _confirmAction(
                      context,
                      'Suspender Conta',
                      'Tem certeza que deseja suspender este usuário? Ele não poderá fazer novos agendamentos.',
                      () => _updateStatus(user.uid, 'suspended'),
                    );
                  },
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  icon: Icons.block,
                  label: 'Suspender',
                ),
              SlidableAction(
                onPressed: (context) {
                  _confirmAction(
                    context,
                    'Cancelar Conta',
                    'Tem certeza que deseja cancelar este usuário? Esta ação é grave.',
                    () => _updateStatus(user.uid, 'cancelled'),
                  );
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.cancel,
                label: 'Cancelar',
              ),
            ],
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName?.substring(0, 1).toUpperCase() ?? 'C',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.displayName ?? 'Sem nome',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                if (user.phoneNumber != null)
                  Row(
                    children: [
                      Text(user.phoneNumber!),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.green),
                        tooltip: 'Conversar no WhatsApp',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _launchWhatsApp(user.phoneNumber!),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      user.ndaAcceptedVersion != null
                          ? Icons.verified_user
                          : Icons.gpp_maybe,
                      size: 16,
                      color: user.ndaAcceptedVersion != null
                          ? Colors.blue
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.ndaAcceptedVersion != null
                          ? 'NDA: ${user.ndaAcceptedVersion}'
                          : 'NDA: Pendente',
                      style: TextStyle(
                        fontSize: 12,
                        color: user.ndaAcceptedVersion != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String uid, String status) async {
    try {
      await ref.read(adminRepositoryProvider).updateUserStatus(uid, status);
      if (mounted) {
        AppToast.success(context, message: 'Status atualizado para $status');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar status: $e');
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Ensure country code (assuming BR +55 if missing, but usually firebase auth has it)
    // If phone starts with 0, remove it.
    // This is a basic heuristic.

    final url = Uri.parse('https://wa.me/$cleanPhone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppToast.error(context, message: 'Não foi possível abrir o WhatsApp');
      }
    }
  }
}

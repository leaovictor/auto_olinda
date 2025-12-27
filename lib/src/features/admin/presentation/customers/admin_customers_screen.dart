import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/admin_repository.dart';
import '../../../auth/domain/app_user.dart';
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
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

    return Container(
      decoration: BoxDecoration(gradient: AdminTheme.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Gerenciar Clientes', style: AdminTheme.headingMedium),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AdminTheme.textPrimary),
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
                    icon: Icon(Icons.menu, color: AdminTheme.textPrimary),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Container(
                      decoration: AdminTheme.glassmorphicDecoration(
                        opacity: 0.1,
                        borderRadius: 12,
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AdminTheme.textPrimary),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Buscar cliente por nome, email ou telefone',
                          hintStyle: TextStyle(color: AdminTheme.textSecondary),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AdminTheme.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
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
                          return Center(
                            child: Text(
                              'Nenhum cliente encontrado.',
                              style: AdminTheme.bodyMedium,
                            ),
                          );
                        }

                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  childAspectRatio: 1.8,
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(context, user);
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(
                        child: Text(
                          'Erro: $err',
                          style: TextStyle(color: AdminTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user) {
    final isSuspended = user.status == 'suspended';
    final isCancelled = user.status == 'cancelled';

    Color statusColor = AdminTheme.gradientSuccess[1];
    if (isSuspended) statusColor = AdminTheme.gradientWarning[0];
    if (isCancelled) statusColor = AdminTheme.gradientDanger[0];

    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminTheme.radiusXL),
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
                backgroundColor: AdminTheme.gradientInfo[0],
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
                    backgroundColor: AdminTheme.gradientSuccess[0],
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
                    backgroundColor: AdminTheme.gradientWarning[0],
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
                  backgroundColor: AdminTheme.gradientDanger[0],
                  foregroundColor: Colors.white,
                  icon: Icons.cancel,
                  label: 'Cancelar',
                ),
              ],
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AdminTheme.gradientPrimary[0].withOpacity(
                    0.2,
                  ),
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName?.substring(0, 1).toUpperCase() ??
                              'C',
                          style: TextStyle(
                            color: AdminTheme.gradientPrimary[0],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Sem nome',
                        style: AdminTheme.headingSmall.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: AdminTheme.bodyMedium),
                      if (user.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              user.phoneNumber!,
                              style: AdminTheme.bodyMedium.copyWith(
                                color: AdminTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _launchWhatsApp(user.phoneNumber!),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF25D366,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF25D366,
                                    ).withOpacity(0.5),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      color: Color(0xFF25D366),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "WhatsApp",
                                      style: TextStyle(
                                        color: Color(0xFF25D366),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              user.status.toUpperCase(),
                              style: AdminTheme.labelSmall.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (user.ndaAcceptedVersion != null
                                          ? AdminTheme.gradientInfo[0]
                                          : AdminTheme.gradientWarning[0])
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    (user.ndaAcceptedVersion != null
                                            ? AdminTheme.gradientInfo[0]
                                            : AdminTheme.gradientWarning[0])
                                        .withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  user.ndaAcceptedVersion != null
                                      ? Icons.verified_user
                                      : Icons.gpp_maybe,
                                  size: 14,
                                  color: user.ndaAcceptedVersion != null
                                      ? AdminTheme.gradientInfo[0]
                                      : AdminTheme.gradientWarning[0],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.ndaAcceptedVersion != null
                                      ? 'NDA: ${user.ndaAcceptedVersion}'
                                      : 'NDA: Pendente',
                                  style: AdminTheme.labelSmall.copyWith(
                                    color: user.ndaAcceptedVersion != null
                                        ? AdminTheme.gradientInfo[0]
                                        : AdminTheme.gradientWarning[0],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Last Access Badge
                          _buildLastAccessBadge(user.lastAccessAt),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a badge showing the last access time with color coding for activity status
  Widget _buildLastAccessBadge(DateTime? lastAccessAt) {
    String accessText;
    Color accessColor;
    IconData accessIcon;

    if (lastAccessAt == null) {
      accessText = 'Nunca acessou';
      accessColor = AdminTheme.gradientDanger[0];
      accessIcon = Icons.person_off;
    } else {
      final now = DateTime.now();
      final difference = now.difference(lastAccessAt);

      if (difference.inDays == 0) {
        accessText = 'Hoje';
        accessColor = AdminTheme.gradientSuccess[0];
        accessIcon = Icons.check_circle;
      } else if (difference.inDays == 1) {
        accessText = 'Ontem';
        accessColor = AdminTheme.gradientSuccess[0];
        accessIcon = Icons.check_circle;
      } else if (difference.inDays < 7) {
        accessText = 'Há ${difference.inDays} dias';
        accessColor = AdminTheme.gradientSuccess[0];
        accessIcon = Icons.access_time;
      } else if (difference.inDays < 14) {
        accessText = 'Há 1 semana';
        accessColor = AdminTheme.gradientWarning[0];
        accessIcon = Icons.schedule;
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        accessText = 'Há $weeks semanas';
        accessColor = AdminTheme.gradientWarning[0];
        accessIcon = Icons.schedule;
      } else if (difference.inDays < 60) {
        accessText = 'Há 1 mês';
        accessColor = AdminTheme.gradientDanger[0];
        accessIcon = Icons.warning_amber;
      } else {
        final months = (difference.inDays / 30).floor();
        accessText = 'Há $months meses';
        accessColor = AdminTheme.gradientDanger[0];
        accessIcon = Icons.warning_amber;
      }
    }

    final formattedDate = lastAccessAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(lastAccessAt)
        : 'Nunca';

    return Tooltip(
      message: 'Último acesso: $formattedDate',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: accessColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: accessColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(accessIcon, size: 14, color: accessColor),
            const SizedBox(width: 4),
            Text(
              accessText,
              style: AdminTheme.labelSmall.copyWith(color: accessColor),
            ),
          ],
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
        backgroundColor: AdminTheme.bgCard,
        title: Text(title, style: AdminTheme.headingSmall),
        content: Text(content, style: AdminTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Confirmar',
              style: TextStyle(color: AdminTheme.gradientPrimary[0]),
            ),
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

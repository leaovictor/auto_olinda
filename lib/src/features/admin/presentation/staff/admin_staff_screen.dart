import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/admin_repository.dart';
import '../../../auth/domain/app_user.dart';
import '../../../../common_widgets/atoms/app_text_field.dart';
import '../../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../../shared/utils/app_toast.dart';

/// Provider for staff users (admin and staff roles only)
final adminStaffUsersProvider = StreamProvider<List<AppUser>>((ref) {
  final allUsers = ref.watch(adminUsersProvider);
  return allUsers.when(
    data: (users) => Stream.value(
      users.where((u) => u.role == 'admin' || u.role == 'staff').toList(),
    ),
    loading: () => const Stream.empty(),
    error: (e, s) => Stream.error(e, s),
  );
});

/// Screen for managing admin and staff users
class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterRole = 'all'; // 'all', 'admin', 'staff'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'staff':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'staff':
        return 'Funcionário';
      default:
        return 'Cliente';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'staff':
        return Icons.badge;
      default:
        return Icons.person;
    }
  }

  Future<void> _changeUserRole(AppUser user, String newRole) async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      await adminRepo.updateUserRole(user.uid, newRole);
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        AppToast.success(
          context,
          message: 'Cargo atualizado para ${_getRoleLabel(newRole)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar cargo: $e');
      }
    }
  }

  Future<void> _suspendUser(AppUser user) async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      await adminRepo.updateUserStatus(user.uid, 'suspended');
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        AppToast.warning(context, message: 'Usuário suspenso');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao suspender: $e');
      }
    }
  }

  Future<void> _reactivateUser(AppUser user) async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      await adminRepo.updateUserStatus(user.uid, 'active');
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        AppToast.success(context, message: 'Usuário reativado');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao reativar: $e');
      }
    }
  }

  void _showRoleChangeDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Cargo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o novo cargo para ${user.displayName ?? user.email}:',
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.purple),
              title: const Text('Administrador'),
              subtitle: const Text('Acesso total ao painel'),
              selected: user.role == 'admin',
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, 'admin');
              },
            ),
            ListTile(
              leading: Icon(Icons.badge, color: Colors.blue),
              title: const Text('Funcionário'),
              subtitle: const Text('Acesso ao painel de funcionários'),
              selected: user.role == 'staff',
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, 'staff');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.grey),
              title: const Text('Cliente'),
              subtitle: const Text('Acesso apenas como cliente'),
              selected: user.role == 'client',
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, 'client');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminUsersProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestão de Funcionários",
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Gerencie administradores e funcionários do sistema.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _showAddStaffDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Adicionar"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              usersAsync.when(
                data: (allUsers) {
                  final admins = allUsers
                      .where((u) => u.role == 'admin')
                      .length;
                  final staff = allUsers.where((u) => u.role == 'staff').length;
                  final total = admins + staff;

                  return Row(
                    children: [
                      _buildStatCard(
                        theme,
                        "Total",
                        total.toString(),
                        Icons.groups,
                        Colors.indigo,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        theme,
                        "Administradores",
                        admins.toString(),
                        Icons.admin_panel_settings,
                        Colors.purple,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        theme,
                        "Funcionários",
                        staff.toString(),
                        Icons.badge,
                        Colors.blue,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),

              // Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'Buscar Funcionário',
                      hint: 'Nome, email ou telefone',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _filterRole,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por Cargo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Todos')),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Administradores'),
                        ),
                        DropdownMenuItem(
                          value: 'staff',
                          child: Text('Funcionários'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _filterRole = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Staff List
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: usersAsync.when(
                  data: (allUsers) {
                    // Filter to staff/admin only
                    var staffUsers = allUsers
                        .where((u) => u.role == 'admin' || u.role == 'staff')
                        .toList();

                    // Apply role filter
                    if (_filterRole != 'all') {
                      staffUsers = staffUsers
                          .where((u) => u.role == _filterRole)
                          .toList();
                    }

                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      staffUsers = staffUsers.where((user) {
                        final name = user.displayName?.toLowerCase() ?? '';
                        final email = user.email.toLowerCase();
                        final phone = user.phoneNumber?.toLowerCase() ?? '';
                        return name.contains(_searchQuery) ||
                            email.contains(_searchQuery) ||
                            phone.contains(_searchQuery);
                      }).toList();
                    }

                    if (staffUsers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Nenhum funcionário encontrado",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Adicione funcionários ou altere o cargo de usuários existentes.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Equipe",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${staffUsers.length} usuários",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "USUÁRIO",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "CARGO",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "STATUS",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 100, child: Text("")),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Table Rows
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: staffUsers.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = staffUsers[index];
                            return _buildStaffRow(theme, user);
                          },
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text("Erro: $e")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRow(ThemeData theme, AppUser user) {
    final isActive = user.status == 'active';

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showRoleChangeDialog(user),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Cargo',
          ),
          if (isActive)
            SlidableAction(
              onPressed: (_) => _suspendUser(user),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.pause,
              label: 'Suspender',
            )
          else
            SlidableAction(
              onPressed: (_) => _reactivateUser(user),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.play_arrow,
              label: 'Reativar',
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // User Info
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getRoleColor(
                      user.role,
                    ).withValues(alpha: 0.2),
                    child: user.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                _getRoleIcon(user.role),
                                color: _getRoleColor(user.role),
                              ),
                            ),
                          )
                        : Icon(
                            _getRoleIcon(user.role),
                            color: _getRoleColor(user.role),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Sem nome',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Role Badge
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(user.role),
                      size: 16,
                      color: _getRoleColor(user.role),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRoleLabel(user.role),
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Ativo' : 'Suspenso',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showRoleChangeDialog(user),
                    tooltip: 'Alterar cargo',
                  ),
                  IconButton(
                    icon: Icon(
                      isActive ? Icons.pause : Icons.play_arrow,
                      size: 20,
                    ),
                    onPressed: () =>
                        isActive ? _suspendUser(user) : _reactivateUser(user),
                    tooltip: isActive ? 'Suspender' : 'Reativar',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStaffDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover Usuário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para adicionar um funcionário, busque um usuário existente pelo email e altere seu cargo.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email do usuário',
                hintText: 'usuario@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                AppToast.warning(context, message: 'Digite um email');
                return;
              }

              // Search for user and show role dialog
              final users = ref.read(adminUsersProvider).value ?? [];
              final user = users
                  .where((u) => u.email.toLowerCase() == email.toLowerCase())
                  .firstOrNull;

              if (user == null) {
                AppToast.error(context, message: 'Usuário não encontrado');
                return;
              }

              Navigator.pop(context);
              _showRoleChangeDialog(user);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}

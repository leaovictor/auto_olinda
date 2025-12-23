import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/admin_repository.dart';
import '../../../auth/domain/app_user.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

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
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Alterar Cargo', style: AdminTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o novo cargo para ${user.displayName ?? user.email}:',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.purple,
              ),
              title: const Text('Administrador', style: AdminTheme.bodyLarge),
              subtitle: Text(
                'Acesso total ao painel',
                style: AdminTheme.bodyMedium.copyWith(
                  color: AdminTheme.textSecondary,
                ),
              ),
              selected: user.role == 'admin',
              selectedTileColor: AdminTheme.gradientPrimary[0].withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, 'admin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge, color: Colors.blue),
              title: const Text('Funcionário', style: AdminTheme.bodyLarge),
              subtitle: Text(
                'Acesso ao painel de funcionários',
                style: AdminTheme.bodyMedium.copyWith(
                  color: AdminTheme.textSecondary,
                ),
              ),
              selected: user.role == 'staff',
              selectedTileColor: AdminTheme.gradientPrimary[0].withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _changeUserRole(user, 'staff');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: const Text('Cliente', style: AdminTheme.bodyLarge),
              subtitle: Text(
                'Acesso apenas como cliente',
                style: AdminTheme.bodyMedium.copyWith(
                  color: AdminTheme.textSecondary,
                ),
              ),
              selected: user.role == 'client',
              selectedTileColor: AdminTheme.gradientPrimary[0].withOpacity(0.1),
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
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Gestão de Funcionários',
          style: AdminTheme.headingMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminUsersProvider);
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Gerencie administradores e funcionários do sistema.",
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AdminTheme.gradientPrimary,
                        ),
                        borderRadius: BorderRadius.circular(
                          AdminTheme.radiusMD,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _showAddStaffDialog,
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          "Adicionar",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
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
                    final staff = allUsers
                        .where((u) => u.role == 'staff')
                        .length;
                    final total = admins + staff;

                    return Row(
                      children: [
                        _buildStatCard(
                          "Total",
                          total.toString(),
                          Icons.groups,
                          Colors.indigo,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          "Admins",
                          admins.toString(),
                          Icons.admin_panel_settings,
                          Colors.purple,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          "Equipe",
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
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Buscar Funcionário',
                          hintText: 'Nome, email ou telefone',
                          labelStyle: const TextStyle(
                            color: AdminTheme.textSecondary,
                          ),
                          hintStyle: const TextStyle(
                            color: AdminTheme.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AdminTheme.textSecondary,
                          ),
                          filled: true,
                          fillColor: AdminTheme.bgCardLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.gradientPrimary[0],
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: AdminTheme.bgCard,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        value: _filterRole,
                        decoration: InputDecoration(
                          labelText: 'Filtrar',
                          labelStyle: const TextStyle(
                            color: AdminTheme.textSecondary,
                          ),
                          filled: true,
                          fillColor: AdminTheme.bgCardLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                            borderSide: BorderSide(
                              color: AdminTheme.borderLight,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos')),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admins'),
                          ),
                          DropdownMenuItem(
                            value: 'staff',
                            child: Text('Equipe'),
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
                  decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
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
                                  color: AdminTheme.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Nenhum funcionário encontrado",
                                  style: AdminTheme.headingSmall.copyWith(
                                    color: AdminTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Adicione funcionários ou altere o cargo de usuários existentes.",
                                  textAlign: TextAlign.center,
                                  style: AdminTheme.bodyMedium.copyWith(
                                    color: AdminTheme.textSecondary,
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
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text(
                                  "Equipe",
                                  style: AdminTheme.headingSmall,
                                ),
                                const Spacer(),
                                Text(
                                  "${staffUsers.length} usuários",
                                  style: AdminTheme.bodyMedium.copyWith(
                                    color: AdminTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: AdminTheme.borderLight, height: 1),
                          // Table Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "USUÁRIO",
                                    style: AdminTheme.labelSmall.copyWith(
                                      color: AdminTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "CARGO",
                                    style: AdminTheme.labelSmall.copyWith(
                                      color: AdminTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "STATUS",
                                    style: AdminTheme.labelSmall.copyWith(
                                      color: AdminTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          Divider(color: AdminTheme.borderLight, height: 1),
                          // Table Rows
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: staffUsers.length,
                            separatorBuilder: (_, __) => Divider(
                              color: AdminTheme.borderLight,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final user = staffUsers[index];
                              return _buildStaffRow(user);
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "Erro: $e",
                          style: const TextStyle(color: AdminTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AdminTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AdminTheme.labelSmall.copyWith(
                color: AdminTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRow(AppUser user) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // User Info
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
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
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Sem nome',
                          style: AdminTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          user.email,
                          style: AdminTheme.labelSmall.copyWith(
                            color: AdminTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Role Badge
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getRoleColor(user.role).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(user.role),
                      size: 14,
                      color: _getRoleColor(user.role),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _getRoleLabel(user.role),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Ativo' : 'Suspenso',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AdminTheme.textSecondary,
              size: 16,
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
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Promover Usuário', style: AdminTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para adicionar um funcionário, busque um usuário existente pelo email e altere seu cargo.',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: AdminTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Email do usuário',
                hintText: 'usuario@email.com',
                labelStyle: const TextStyle(color: AdminTheme.textSecondary),
                hintStyle: const TextStyle(color: AdminTheme.textMuted),
                prefixIcon: const Icon(
                  Icons.email,
                  color: AdminTheme.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  borderSide: BorderSide(color: AdminTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
                  borderSide: BorderSide(color: AdminTheme.gradientPrimary[0]),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AdminTheme.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AdminTheme.gradientPrimary[0],
            ),
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

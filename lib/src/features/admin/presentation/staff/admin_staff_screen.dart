import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';
import '../../../staff/data/staff_repository.dart';
import '../../../staff/domain/staff_member.dart';
import '../../../auth/domain/app_user.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

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

/// Screen for managing admin and staff users with tabbed interface
class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends ConsumerState<AdminStaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      HapticFeedback.mediumImpact();
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
      HapticFeedback.mediumImpact();
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
      HapticFeedback.mediumImpact();
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

  Future<void> _toggleShift(StaffMember staff) async {
    try {
      HapticFeedback.mediumImpact();
      final staffRepo = ref.read(staffRepositoryProvider);
      if (staff.isOnShift) {
        await staffRepo.endShift(staff.id);
        if (mounted) {
          AppToast.info(context, message: '${staff.name} saiu do turno');
        }
      } else {
        await staffRepo.startShift(staff.id);
        if (mounted) {
          AppToast.success(context, message: '${staff.name} iniciou turno');
        }
      }
      ref.invalidate(staffMembersProvider);
      ref.invalidate(onShiftStaffProvider);
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao atualizar turno: $e');
      }
    }
  }

  void _showRoleChangeDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        ),
        title: const Text('Alterar Cargo', style: AdminTheme.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o novo cargo para ${user.displayName ?? user.email}:',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildRoleOption(
              context: context,
              user: user,
              role: 'admin',
              icon: Icons.admin_panel_settings,
              color: Colors.purple,
              title: 'Administrador',
              subtitle: 'Acesso total ao painel',
            ),
            _buildRoleOption(
              context: context,
              user: user,
              role: 'staff',
              icon: Icons.badge,
              color: Colors.blue,
              title: 'Funcionário',
              subtitle: 'Acesso ao painel de funcionários',
            ),
            _buildRoleOption(
              context: context,
              user: user,
              role: 'client',
              icon: Icons.person,
              color: Colors.grey,
              title: 'Cliente',
              subtitle: 'Acesso apenas como cliente',
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

  Widget _buildRoleOption({
    required BuildContext context,
    required AppUser user,
    required String role,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final isSelected = user.role == role;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminTheme.gradientPrimary[0].withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        border: Border.all(
          color: isSelected
              ? AdminTheme.gradientPrimary[0]
              : AdminTheme.borderLight,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: AdminTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: AdminTheme.bodyMedium.copyWith(
            color: AdminTheme.textSecondary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () {
          Navigator.pop(context);
          _changeUserRole(user, role);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTeamTab(),
                    _buildMetricsTab(),
                    _buildShiftsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Gestão de Equipe', style: AdminTheme.headingMedium),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
          borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AdminTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.groups, size: 20), text: 'Equipe'),
          Tab(icon: Icon(Icons.insights, size: 20), text: 'Métricas'),
          Tab(icon: Icon(Icons.schedule, size: 20), text: 'Escalas'),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminTheme.gradientPrimary[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showAddStaffDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Adicionar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ).animate().scale(delay: 300.ms);
  }

  // ============ TEAM TAB ============
  Widget _buildTeamTab() {
    final usersAsync = ref.watch(adminUsersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref.invalidate(adminUsersProvider);
        ref.invalidate(staffMembersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            usersAsync.when(
              data: (allUsers) {
                final admins = allUsers.where((u) => u.role == 'admin').length;
                final staff = allUsers.where((u) => u.role == 'staff').length;
                return _buildStatsRow(admins, staff);
              },
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox(height: 80),
            ),
            const SizedBox(height: 20),

            // Search and Filter
            _buildSearchAndFilter(),
            const SizedBox(height: 20),

            // Staff List
            _buildStaffList(usersAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int admins, int staff) {
    final total = admins + staff;
    return Row(
      children: [
        _buildStatCard('Total', total.toString(), Icons.groups, Colors.indigo),
        const SizedBox(width: 12),
        _buildStatCard(
          'Admins',
          admins.toString(),
          Icons.admin_panel_settings,
          Colors.purple,
        ),
        const SizedBox(width: 12),
        _buildStatCard('Equipe', staff.toString(), Icons.badge, Colors.blue),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
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
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AdminTextField(
            controller: _searchController,
            hint: 'Buscar funcionário...',
            icon: Icons.search,
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: AdminDropdownField<String>(
            value: _filterRole,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Todos')),
              DropdownMenuItem(value: 'admin', child: Text('Admins')),
              DropdownMenuItem(value: 'staff', child: Text('Staff')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _filterRole = value);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStaffList(AsyncValue<List<AppUser>> usersAsync) {
    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: usersAsync.when(
        data: (allUsers) {
          var staffUsers = allUsers
              .where((u) => u.role == 'admin' || u.role == 'staff')
              .toList();

          // Apply filters
          if (_filterRole != 'all') {
            staffUsers = staffUsers
                .where((u) => u.role == _filterRole)
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            staffUsers = staffUsers.where((user) {
              final name = user.displayName?.toLowerCase() ?? '';
              final email = user.email.toLowerCase();
              return name.contains(_searchQuery) ||
                  email.contains(_searchQuery);
            }).toList();
          }

          if (staffUsers.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildListHeader(staffUsers.length),
              ...staffUsers.asMap().entries.map((entry) {
                return _buildStaffCard(entry.value)
                    .animate()
                    .fadeIn(delay: (50 * entry.key).ms)
                    .slideX(begin: 0.05);
              }),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Erro: $e', style: AdminTheme.bodyMedium),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Equipe', style: AdminTheme.headingSmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AdminTheme.gradientPrimary[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count membros',
              style: AdminTheme.labelSmall.copyWith(
                color: AdminTheme.gradientPrimary[0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(AppUser user) {
    final isActive = user.status == 'active';
    final roleColor = _getRoleColor(user.role);

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showRoleChangeDialog(user),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Cargo',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed: (_) =>
                isActive ? _suspendUser(user) : _reactivateUser(user),
            backgroundColor: isActive ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: isActive ? Icons.pause : Icons.play_arrow,
            label: isActive ? 'Suspender' : 'Reativar',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/admin/staff/${user.uid}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AdminTheme.borderLight.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: user.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getRoleIcon(user.role),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(_getRoleIcon(user.role), color: Colors.white),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName ?? 'Sem nome',
                            style: AdminTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getRoleLabel(user.role),
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AdminTheme.labelSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AdminTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_off,
              size: 48,
              color: AdminTheme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum funcionário encontrado',
            style: AdminTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione funcionários ou altere o cargo de usuários existentes.',
            textAlign: TextAlign.center,
            style: AdminTheme.bodyMedium.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============ METRICS TAB ============
  Widget _buildMetricsTab() {
    final staffAsync = ref.watch(staffMembersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref.invalidate(staffMembersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Performance da Equipe',
                  style: AdminTheme.headingSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AdminTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          "d 'de' MMM",
                          'pt_BR',
                        ).format(DateTime.now()),
                        style: AdminTheme.labelSmall.copyWith(
                          color: AdminTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 20),

            // Metrics content
            staffAsync.when(
              data: (staffList) {
                if (staffList.isEmpty) {
                  return _buildEmptyMetrics();
                }

                // Sort by revenue today
                final sortedStaff = [...staffList]
                  ..sort((a, b) => b.revenueToday.compareTo(a.revenueToday));

                return Column(
                  children: [
                    // Summary cards
                    _buildMetricsSummary(staffList),
                    const SizedBox(height: 24),

                    // Top performer highlight
                    if (sortedStaff.isNotEmpty &&
                        sortedStaff.first.totalBookingsToday > 0)
                      _buildTopPerformer(sortedStaff.first),

                    const SizedBox(height: 24),

                    // Ranking list
                    _buildRankingList(sortedStaff),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Erro ao carregar métricas: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSummary(List<StaffMember> staffList) {
    final totalToday = staffList.fold<int>(
      0,
      (sum, s) => sum + s.totalBookingsToday,
    );
    final revenueToday = staffList.fold<double>(
      0,
      (sum, s) => sum + s.revenueToday,
    );
    final avgRating = staffList.isNotEmpty
        ? staffList.fold<double>(0, (sum, s) => sum + s.avgRating) /
              staffList.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Atendimentos Hoje',
            totalToday.toString(),
            Icons.car_repair,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Receita Hoje',
            'R\$${revenueToday.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avaliação Média',
            avgRating.toStringAsFixed(1),
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: AdminTheme.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AdminTheme.labelSmall.copyWith(
              color: AdminTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformer(StaffMember staff) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⭐️ Top Performer Hoje',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff.name,
                  style: AdminTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${staff.totalBookingsToday} atendimentos • R\$${staff.revenueToday.toStringAsFixed(0)}',
                  style: AdminTheme.bodyMedium.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildRankingList(List<StaffMember> staffList) {
    return Container(
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ranking de Atendimentos',
              style: AdminTheme.headingSmall,
            ),
          ),
          Divider(color: AdminTheme.borderLight, height: 1),
          ...staffList.asMap().entries.map((entry) {
            final index = entry.key;
            final staff = entry.value;
            return _buildRankingRow(
              index + 1,
              staff,
            ).animate().fadeIn(delay: (50 * index).ms);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRankingRow(int rank, StaffMember staff) {
    Color rankColor;
    IconData? rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.looks_one;
        break;
      case 2:
        rankColor = Colors.grey.shade400;
        rankIcon = Icons.looks_two;
        break;
      case 3:
        rankColor = Colors.orange.shade700;
        rankIcon = Icons.looks_3;
        break;
      default:
        rankColor = AdminTheme.textSecondary;
        rankIcon = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AdminTheme.borderLight.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, color: rankColor, size: 20)
                  : Text(
                      '$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: staff.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(staff.photoUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.car_repair,
                      size: 12,
                      color: AdminTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${staff.totalBookingsToday} hoje',
                      style: AdminTheme.labelSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_month,
                      size: 12,
                      color: AdminTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${staff.totalBookingsMonth} mês',
                      style: AdminTheme.labelSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$${staff.revenueToday.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'hoje',
                style: AdminTheme.labelSmall.copyWith(
                  color: AdminTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMetrics() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminTheme.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insights,
              size: 48,
              color: AdminTheme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sem dados de performance',
            style: AdminTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Os dados aparecerão aqui quando a equipe começar a atender.',
            textAlign: TextAlign.center,
            style: AdminTheme.bodyMedium.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============ SHIFTS TAB ============
  Widget _buildShiftsTab() {
    final onShiftAsync = ref.watch(onShiftStaffProvider);
    final allStaffAsync = ref.watch(staffMembersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref.invalidate(onShiftStaffProvider);
        ref.invalidate(staffMembersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active shifts section
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Em Turno Agora', style: AdminTheme.headingSmall),
                const Spacer(),
                onShiftAsync.when(
                  data: (list) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${list.length} ativos',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 16),

            // On shift staff list
            onShiftAsync.when(
              data: (onShiftList) {
                if (onShiftList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AdminTheme.glassmorphicDecoration(opacity: 0.4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nenhum funcionário em turno',
                                style: AdminTheme.bodyLarge,
                              ),
                              Text(
                                'Inicie um turno na lista abaixo',
                                style: AdminTheme.bodyMedium.copyWith(
                                  color: AdminTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: onShiftList.map((staff) {
                    return _buildOnShiftCard(staff);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Erro: $e'),
            ),
            const SizedBox(height: 32),

            // All staff for shift management
            const Text('Toda a Equipe', style: AdminTheme.headingSmall),
            const SizedBox(height: 16),

            allStaffAsync.when(
              data: (staffList) {
                return Container(
                  decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
                  child: Column(
                    children: staffList.asMap().entries.map((entry) {
                      return _buildShiftToggleRow(
                        entry.value,
                      ).animate().fadeIn(delay: (30 * entry.key).ms);
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnShiftCard(StaffMember staff) {
    final shiftDuration = staff.shiftStart != null
        ? DateTime.now().difference(staff.shiftStart!)
        : Duration.zero;
    final hours = shiftDuration.inHours;
    final minutes = shiftDuration.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.15),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Pulsing indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.green),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${hours}h ${minutes}min',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // End shift button
          TextButton.icon(
            onPressed: () => _toggleShift(staff),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Encerrar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _buildShiftToggleRow(StaffMember staff) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AdminTheme.borderLight.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRoleColor(staff.role).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getRoleIcon(staff.role),
              color: _getRoleColor(staff.role),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: AdminTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getRoleLabel(staff.role),
                  style: AdminTheme.labelSmall.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Toggle button
          Switch.adaptive(
            value: staff.isOnShift,
            onChanged: (_) => _toggleShift(staff),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.gradientPrimary[0].withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_add,
                color: AdminTheme.gradientPrimary[0],
              ),
            ),
            const SizedBox(width: 12),
            const Text('Promover Usuário', style: AdminTheme.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Busque um usuário existente pelo email para alterar seu cargo.',
              style: AdminTheme.bodyMedium.copyWith(
                color: AdminTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AdminTextField(
              controller: emailController,
              hint: 'usuario@email.com',
              label: 'Email do Usuário',
              icon: Icons.email,
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AdminTheme.gradientPrimary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  AppToast.warning(context, message: 'Digite um email');
                  return;
                }

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
              child: const Text(
                'Buscar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

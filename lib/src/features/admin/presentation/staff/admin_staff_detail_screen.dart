import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../staff/data/staff_repository.dart';
import '../../../staff/domain/staff_member.dart';
import '../../data/admin_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

/// Staff detail screen showing performance and history
class AdminStaffDetailScreen extends ConsumerStatefulWidget {
  final String staffId;

  const AdminStaffDetailScreen({super.key, required this.staffId});

  @override
  ConsumerState<AdminStaffDetailScreen> createState() =>
      _AdminStaffDetailScreenState();
}

class _AdminStaffDetailScreenState
    extends ConsumerState<AdminStaffDetailScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endDate = now;
    _startDate = now.subtract(const Duration(days: 7));
  }

  Future<void> _toggleShift(StaffMember staff) async {
    try {
      HapticFeedback.mediumImpact();
      final staffRepo = ref.read(staffRepositoryProvider);
      if (staff.isOnShift) {
        await staffRepo.endShift(staff.id);
        if (mounted) {
          AppToast.info(context, message: 'Turno encerrado');
        }
      } else {
        await staffRepo.startShift(staff.id);
        if (mounted) {
          AppToast.success(context, message: 'Turno iniciado');
        }
      }
      ref.invalidate(staffMembersProvider);
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  void _showRoleChangeDialog(StaffMember staff) {
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
              'Selecione o novo cargo para ${staff.name}:',
              style: AdminTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildRoleOption(
              staff: staff,
              role: 'admin',
              icon: Icons.admin_panel_settings,
              color: Colors.purple,
              title: 'Administrador',
              subtitle: 'Acesso total ao painel',
            ),
            _buildRoleOption(
              staff: staff,
              role: 'staff',
              icon: Icons.badge,
              color: Colors.blue,
              title: 'Funcionário',
              subtitle: 'Acesso ao painel de funcionários',
            ),
            _buildRoleOption(
              staff: staff,
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
    required StaffMember staff,
    required String role,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final isSelected = staff.role == role;
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
        onTap: () async {
          Navigator.pop(context);
          try {
            HapticFeedback.mediumImpact();
            final adminRepo = ref.read(adminRepositoryProvider);
            await adminRepo.updateUserRole(staff.id, role);
            ref.invalidate(adminUsersProvider);
            ref.invalidate(staffMembersProvider);
            if (mounted) {
              AppToast.success(context, message: 'Cargo atualizado');
            }
          } catch (e) {
            if (mounted) {
              AppToast.error(context, message: 'Erro: $e');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffMembersProvider);
    final performanceAsync = ref.watch(
      staffPerformanceProvider(widget.staffId, _startDate, _endDate),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: staffAsync.when(
            data: (staffList) {
              final staff = staffList.firstWhere(
                (s) => s.id == widget.staffId,
                orElse: () => StaffMember(
                  id: widget.staffId,
                  name: 'Carregando...',
                  email: '',
                ),
              );

              return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  ref.invalidate(staffMembersProvider);
                  ref.invalidate(
                    staffPerformanceProvider(
                      widget.staffId,
                      _startDate,
                      _endDate,
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildProfileHeader(staff),
                      const SizedBox(height: 24),
                      _buildQuickActions(staff),
                      const SizedBox(height: 24),
                      _buildPerformanceSection(performanceAsync),
                      const SizedBox(height: 24),
                      _buildWeeklyChart(performanceAsync),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar: $e'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Detalhes do Funcionário',
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
    );
  }

  Widget _buildProfileHeader(StaffMember staff) {
    final isActive = staff.status == 'active';
    final roleColor = staff.role == 'admin' ? Colors.purple : Colors.blue;
    final roleLabel = staff.role == 'admin' ? 'Administrador' : 'Funcionário';
    final roleIcon = staff.role == 'admin'
        ? Icons.admin_panel_settings
        : Icons.badge;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [roleColor, roleColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: roleColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: staff.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      staff.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(roleIcon, color: Colors.white, size: 40),
                    ),
                  )
                : Icon(roleIcon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            staff.name,
            style: AdminTheme.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            staff.email,
            style: AdminTheme.bodyMedium.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roleColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roleIcon, size: 14, color: roleColor),
                    const SizedBox(width: 6),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Ativo' : 'Suspenso',
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Shift indicator
              if (staff.isOnShift) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.amber),
                      SizedBox(width: 6),
                      Text(
                        'Em Turno',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildQuickActions(StaffMember staff) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.swap_horiz,
            label: 'Alterar Cargo',
            color: Colors.blue,
            onTap: () => _showRoleChangeDialog(staff),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: staff.isOnShift ? Icons.logout : Icons.login,
            label: staff.isOnShift ? 'Encerrar Turno' : 'Iniciar Turno',
            color: staff.isOnShift ? Colors.orange : Colors.green,
            onTap: () => _toggleShift(staff),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AdminTheme.labelSmall.copyWith(
                  color: AdminTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(
    AsyncValue<StaffPerformance> performanceAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AdminTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Performance', style: AdminTheme.headingSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminTheme.gradientPrimary[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Últimos 7 dias',
                  style: AdminTheme.labelSmall.copyWith(
                    color: AdminTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          performanceAsync.when(
            data: (performance) => Row(
              children: [
                _buildPerfMetric(
                  icon: Icons.car_repair,
                  value: performance.totalBookings.toString(),
                  label: 'Atendimentos',
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildPerfMetric(
                  icon: Icons.attach_money,
                  value: 'R\$${performance.totalRevenue.toStringAsFixed(0)}',
                  label: 'Receita',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildPerfMetric(
                  icon: Icons.star,
                  value: performance.avgRating.toStringAsFixed(1),
                  label: 'Avaliação',
                  color: Colors.amber,
                ),
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Erro: $e'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildPerfMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AdminTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AdminTheme.labelSmall.copyWith(
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AsyncValue<StaffPerformance> performanceAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AdminTheme.glassmorphicDecoration(opacity: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: AdminTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Atendimentos da Semana',
                style: AdminTheme.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          performanceAsync.when(
            data: (performance) {
              final maxBookings = performance.dailyStats.isNotEmpty
                  ? performance.dailyStats
                        .map((d) => d.bookings)
                        .reduce((a, b) => a > b ? a : b)
                  : 0;

              return SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: performance.dailyStats.map((day) {
                    final height = maxBookings > 0
                        ? (day.bookings / maxBookings) * 80
                        : 0.0;
                    final dayName = DateFormat.E('pt_BR').format(day.date);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          day.bookings.toString(),
                          style: AdminTheme.labelSmall.copyWith(
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 24,
                          height: height.clamp(4, 80),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: AdminTheme.gradientPrimary,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayName.substring(0, 3),
                          style: AdminTheme.labelSmall.copyWith(
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SizedBox(height: 120, child: Center(child: Text('Erro: $e'))),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }
}

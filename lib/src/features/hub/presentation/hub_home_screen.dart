import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../company/data/company_repository.dart';
import '../../company/domain/company_model.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common_widgets/molecules/user_avatar.dart';

class HubHomeScreen extends ConsumerStatefulWidget {
  const HubHomeScreen({super.key});

  @override
  ConsumerState<HubHomeScreen> createState() => _HubHomeScreenState();
}

class _HubHomeScreenState extends ConsumerState<HubHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesProvider);
    final userAsync = ref.watch(currentUserProfileProvider);
    final theme = Theme.of(context);

    // Time-based greeting
    final hour = DateTime.now().hour;
    String greeting = 'Bom dia';
    if (hour >= 12 && hour < 18) greeting = 'Boa tarde';
    if (hour >= 18) greeting = 'Boa noite';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with Glass/Gradient feel possibility,
            // but keeping it clean on surface for now with refined typography.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(text: '$greeting,'),
                                if (userAsync.value?.role == 'superuser')
                                  TextSpan(
                                    text: ' (Admin Hub)',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          userAsync.when(
                            data: (user) => Text(
                              user?.displayName?.split(' ').first ??
                                  'Visitante',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            loading: () => const ShimmerLoading.rectangular(
                              width: 100,
                              height: 24,
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ).animate().fadeIn().slideX(),
                      // User Avatar with access to Profile
                      InkWell(
                        onTap: () => context.push('/profile'),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: userAsync.when(
                            data: (user) => UserAvatar(
                              photoUrl: user?.photoUrl,
                              name: user?.displayName ?? 'U',
                              radius: 24,
                            ),
                            loading: () => const ShimmerLoading.circular(
                              width: 48,
                              height: 48,
                            ),
                            error: (_, __) => const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scale(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Glassmorphic Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Buscar lava-jato...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.7,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  if (userAsync.value?.role == 'superuser') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: Navigate to create company screen
                          // context.push('/admin/create-company');
                          // Or show dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_business_rounded),
                        label: const Text('Cadastrar Novo Lava-Jato'),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Companies List
            Expanded(
              child: companiesAsync.when(
                data: (companies) {
                  if (companies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 64,
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum lava-jato encontrado',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: companies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final company = companies[index];
                      return _buildPremiumCompanyCard(context, company, index);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (_, __) =>
                      const ShimmerLoading.rectangular(height: 140),
                ),
                error: (err, stack) => Center(child: Text('Erro: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCompanyCard(
    BuildContext context,
    Company company,
    int index,
  ) {
    final theme = Theme.of(context);
    final isOpen = company.isActive;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/company/${company.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / Banner Area
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.store_rounded,
                        size: 48,
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOpen ? Icons.check_circle : Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOpen ? 'Aberto' : 'Fechado',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Area
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withOpacity(
                            0.5,
                          ),
                        ),
                        image: company.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(company.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: company.logoUrl == null
                          ? Icon(
                              Icons.business,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (company.address != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    company.address!.street,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company.rating.toStringAsFixed(1),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${company.reviewCount} avaliações)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
  }
}

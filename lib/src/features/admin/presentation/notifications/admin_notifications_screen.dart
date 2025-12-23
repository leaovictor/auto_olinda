import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

enum NotificationTarget { all, plan, user }

/// Search result model for client search
class ClientSearchResult {
  final String id;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? licensePlate;

  ClientSearchResult({
    required this.id,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.licensePlate,
  });

  String get subtitle {
    final parts = <String>[];
    if (email != null && email!.isNotEmpty) parts.add(email!);
    if (phoneNumber != null && phoneNumber!.isNotEmpty) parts.add(phoneNumber!);
    if (licensePlate != null && licensePlate!.isNotEmpty) {
      parts.add('🚗 $licensePlate');
    }
    return parts.join(' • ');
  }
}

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends ConsumerState<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _clientSearchController = TextEditingController();

  NotificationTarget _targetType = NotificationTarget.all;
  String? _selectedPlanId;

  // Multi-selection for users
  List<ClientSearchResult> _selectedClients = [];

  bool _isSending = false;
  bool _isSearching = false;
  List<ClientSearchResult> _searchResults = [];

  // Limits
  static const int maxTitleLength = 65;
  static const int maxBodyLength = 240;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _clientSearchController.dispose();
    super.dispose();
  }

  /// Searches for clients by name, email, phone, or vehicle license plate
  Future<void> _searchClients(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final queryLower = query.toLowerCase().trim();
      final results = <ClientSearchResult>[];
      final addedUserIds = <String>{};

      // 1. Search users by displayName, email, phoneNumber
      final usersSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'client')
          .limit(200)
          .get();

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        final displayName = (data['displayName'] ?? '')
            .toString()
            .toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final phoneNumber = (data['phoneNumber'] ?? '')
            .toString()
            .toLowerCase();

        if (displayName.contains(queryLower) ||
            email.contains(queryLower) ||
            phoneNumber.contains(queryLower)) {
          if (!addedUserIds.contains(doc.id)) {
            addedUserIds.add(doc.id);
            results.add(
              ClientSearchResult(
                id: doc.id,
                displayName: data['displayName']?.toString() ?? 'Sem nome',
                email: data['email']?.toString(),
                phoneNumber: data['phoneNumber']?.toString(),
              ),
            );
          }
        }
      }

      // 2. Search vehicles by licensePlate and get their owners
      final vehiclesSnapshot = await firestore
          .collection('vehicles')
          .limit(200)
          .get();

      for (final doc in vehiclesSnapshot.docs) {
        final data = doc.data();
        final licensePlate = (data['licensePlate'] ?? '')
            .toString()
            .toLowerCase();

        if (licensePlate.contains(queryLower)) {
          final ownerId = data['ownerId']?.toString();
          if (ownerId != null && !addedUserIds.contains(ownerId)) {
            // Fetch user info
            final userDoc = await firestore
                .collection('users')
                .doc(ownerId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              addedUserIds.add(ownerId);
              results.add(
                ClientSearchResult(
                  id: ownerId,
                  displayName:
                      userData['displayName']?.toString() ?? 'Sem nome',
                  email: userData['email']?.toString(),
                  phoneNumber: userData['phoneNumber']?.toString(),
                  licensePlate: data['licensePlate']?.toString(),
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        AppToast.error(context, message: 'Erro ao buscar: $e');
      }
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_targetType == NotificationTarget.plan && _selectedPlanId == null) {
      AppToast.warning(context, message: 'Selecione um plano');
      return;
    }

    if (_targetType == NotificationTarget.user && _selectedClients.isEmpty) {
      AppToast.warning(context, message: 'Selecione pelo menos um cliente');
      return;
    }

    setState(() => _isSending = true);

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final callable = functions.httpsCallable('sendAdminNotification');

      String targetTypeStr;
      switch (_targetType) {
        case NotificationTarget.all:
          targetTypeStr = 'all';
          break;
        case NotificationTarget.plan:
          targetTypeStr = 'plan';
          break;
        case NotificationTarget.user:
          targetTypeStr = 'user';
          break;
      }

      int totalSent = 0;
      int totalUsers = 0;

      if (_targetType == NotificationTarget.user) {
        // Send to each selected client individually
        for (final client in _selectedClients) {
          try {
            final result = await callable.call({
              'targetType': 'user',
              'targetId': client.id,
              'title': _titleController.text.trim(),
              'body': _bodyController.text.trim(),
            });
            final data = result.data as Map<String, dynamic>;
            if (data['success'] == true) {
              totalSent += (data['sent'] as int? ?? 0);
              totalUsers++;
            }
          } catch (_) {
            // Continue with next client
          }
        }

        if (mounted) {
          AppToast.success(
            context,
            message:
                'Enviado para $totalUsers clientes ($totalSent notificações)',
          );
          _titleController.clear();
          _bodyController.clear();
          setState(() {
            _selectedClients = [];
          });
        }
      } else {
        // All or Plan target
        final result = await callable.call({
          'targetType': targetTypeStr,
          'targetId': _targetType == NotificationTarget.plan
              ? _selectedPlanId
              : null,
          'title': _titleController.text.trim(),
          'body': _bodyController.text.trim(),
        });

        final data = result.data as Map<String, dynamic>;

        if (mounted) {
          if (data['success'] == true) {
            AppToast.success(
              context,
              message:
                  'Enviado para ${data['totalUsers']} usuários (${data['sent']} com sucesso)',
            );
            _titleController.clear();
            _bodyController.clear();
          } else {
            AppToast.warning(
              context,
              message: data['message'] ?? 'Nenhum destinatário encontrado',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePlansProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Enviar Notificação',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: kToolbarHeight + 40,
            bottom: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Type Selector
                Text('Destinatários', style: AdminTheme.headingSmall),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: AdminTheme.glassmorphicDecoration(opacity: 0.3),
                  padding: const EdgeInsets.all(4),
                  child: SegmentedButton<NotificationTarget>(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AdminTheme.gradientPrimary[0];
                        }
                        return Colors.transparent;
                      }),
                      foregroundColor: WidgetStateColor.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return AdminTheme.textSecondary;
                      }),
                      side: WidgetStateProperty.all(BorderSide.none),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: NotificationTarget.all,
                        label: Text('Todos'),
                        icon: Icon(Icons.people),
                      ),
                      ButtonSegment(
                        value: NotificationTarget.plan,
                        label: Text('Por Plano'),
                        icon: Icon(Icons.card_membership),
                      ),
                      ButtonSegment(
                        value: NotificationTarget.user,
                        label: Text('Individual'),
                        icon: Icon(Icons.person),
                      ),
                    ],
                    selected: {_targetType},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _targetType = selection.first;
                        _selectedPlanId = null;
                        _selectedClients = [];
                        _searchResults = [];
                        _clientSearchController.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Plan Selector (if plan target)
                if (_targetType == NotificationTarget.plan) ...[
                  Text('Selecione o Plano', style: AdminTheme.headingSmall),
                  const SizedBox(height: 8),
                  plansAsync.when(
                    data: (plans) => DropdownButtonFormField<String>(
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      initialValue: _selectedPlanId,
                      decoration: InputDecoration(
                        hintText: 'Escolha um plano',
                        hintStyle: const TextStyle(
                          color: AdminTheme.textSecondary,
                        ),
                        filled: true,
                        fillColor: AdminTheme.bgCardLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminTheme.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminTheme.borderLight,
                          ),
                        ),
                      ),
                      items: plans
                          .map(
                            (plan) => DropdownMenuItem(
                              value: plan.id,
                              child: Text(plan.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlanId = value);
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Erro ao carregar planos'),
                  ),
                  const SizedBox(height: 24),
                ],

                // User Selector (if user target)
                if (_targetType == NotificationTarget.user) ...[
                  Text('Buscar Cliente', style: AdminTheme.headingSmall),
                  const SizedBox(height: 8),

                  // Search Input
                  TextFormField(
                    controller: _clientSearchController,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText:
                          'Digite nome, email, telefone ou placa do veículo',
                      hintStyle: const TextStyle(
                        color: AdminTheme.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AdminTheme.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AdminTheme.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AdminTheme.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AdminTheme.gradientPrimary[0],
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AdminTheme.textSecondary,
                      ),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AdminTheme.textSecondary,
                                ),
                              ),
                            )
                          : _clientSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AdminTheme.textSecondary,
                              ),
                              onPressed: () {
                                _clientSearchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      _searchClients(value);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selected Clients Chips (Multi-select)
                  if (_selectedClients.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedClients.length} cliente(s) selecionado(s)',
                                style: AdminTheme.bodySmall.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedClients = [];
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear_all,
                                  size: 18,
                                  color: AdminTheme.textSecondary,
                                ),
                                label: Text(
                                  'Limpar todos',
                                  style: AdminTheme.bodySmall.copyWith(
                                    color: AdminTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedClients.map((client) {
                              return Chip(
                                backgroundColor: AdminTheme.gradientPrimary[0]
                                    .withOpacity(0.2),
                                avatar: CircleAvatar(
                                  backgroundColor:
                                      AdminTheme.gradientPrimary[0],
                                  radius: 12,
                                  child: Text(
                                    client.displayName.isNotEmpty
                                        ? client.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                label: Text(
                                  client.displayName,
                                  style: const TextStyle(
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AdminTheme.textSecondary,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedClients.removeWhere(
                                      (c) => c.id == client.id,
                                    );
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  // Search Results
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: AdminTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminTheme.borderLight),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AdminTheme.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          final isAlreadySelected = _selectedClients.any(
                            (c) => c.id == result.id,
                          );
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isAlreadySelected
                                  ? Colors.green.withOpacity(0.2)
                                  : AdminTheme.gradientPrimary[0].withOpacity(
                                      0.2,
                                    ),
                              child: isAlreadySelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : Text(
                                      (result.displayName.isNotEmpty
                                              ? result.displayName[0]
                                              : '?')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: AdminTheme.gradientPrimary[0],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            title: Text(
                              result.displayName,
                              style: TextStyle(
                                color: isAlreadySelected
                                    ? Colors.green
                                    : AdminTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              result.subtitle,
                              style: AdminTheme.bodySmall.copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isAlreadySelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.add_circle_outline,
                                    color: AdminTheme.textSecondary,
                                  ),
                            onTap: () {
                              setState(() {
                                if (isAlreadySelected) {
                                  _selectedClients.removeWhere(
                                    (c) => c.id == result.id,
                                  );
                                } else {
                                  _selectedClients.add(result);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                  // No results message
                  if (_searchResults.isEmpty &&
                      _clientSearchController.text.isNotEmpty &&
                      !_isSearching)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Nenhum cliente encontrado. Tente outro termo de busca.',
                        style: AdminTheme.bodySmall.copyWith(
                          color: AdminTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],

                // Title Field
                Text('Título', style: AdminTheme.headingSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: maxTitleLength,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Ex: Promoção Especial! 🎉',
                    hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                    filled: true,
                    fillColor: AdminTheme.bgCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminTheme.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminTheme.borderLight,
                      ),
                    ),
                    counterText:
                        '${_titleController.text.length}/$maxTitleLength',
                    counterStyle: const TextStyle(
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Título é obrigatório';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),

                // Body Field
                Text('Mensagem', style: AdminTheme.headingSmall),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bodyController,
                  maxLength: maxBodyLength,
                  maxLines: 4,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Escreva sua mensagem aqui... Use emojis! 😊🚗✨',
                    hintStyle: const TextStyle(color: AdminTheme.textSecondary),
                    filled: true,
                    fillColor: AdminTheme.bgCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminTheme.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminTheme.borderLight,
                      ),
                    ),
                    counterText:
                        '${_bodyController.text.length}/$maxBodyLength',
                    counterStyle: const TextStyle(
                      color: AdminTheme.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mensagem é obrigatória';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),

                // Preview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AdminTheme.glassmorphicDecoration(
                    opacity: 0.6,
                    glowColor: AdminTheme.gradientPrimary[0],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications,
                            color: AdminTheme.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Prévia',
                            style: AdminTheme.bodySmall.copyWith(
                              color: AdminTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _titleController.text.isEmpty
                            ? 'Título da notificação'
                            : _titleController.text,
                        style: AdminTheme.headingSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bodyController.text.isEmpty
                            ? 'Corpo da mensagem aparecerá aqui...'
                            : _bodyController.text,
                        style: AdminTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Send Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: _isSending
                            ? [Colors.grey, Colors.grey]
                            : AdminTheme.gradientPrimary,
                      ),
                      boxShadow: [
                        if (!_isSending)
                          BoxShadow(
                            color: AdminTheme.gradientPrimary[0].withOpacity(
                              0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendNotification,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        _isSending ? 'Enviando...' : 'Enviar Notificação',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
}

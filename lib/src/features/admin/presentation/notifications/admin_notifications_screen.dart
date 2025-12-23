import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

enum NotificationTarget { all, plan, user }

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

  NotificationTarget _targetType = NotificationTarget.all;
  String? _selectedPlanId;
  String? _selectedUserId;
  String? _selectedUserName;

  bool _isSending = false;

  // Limits
  static const int maxTitleLength = 65;
  static const int maxBodyLength = 240;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_targetType == NotificationTarget.plan && _selectedPlanId == null) {
      AppToast.warning(context, message: 'Selecione um plano');
      return;
    }

    if (_targetType == NotificationTarget.user && _selectedUserId == null) {
      AppToast.warning(context, message: 'Selecione um cliente');
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

      final result = await callable.call({
        'targetType': targetTypeStr,
        'targetId': _targetType == NotificationTarget.plan
            ? _selectedPlanId
            : _targetType == NotificationTarget.user
            ? _selectedUserId
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
    final usersAsync = ref.watch(allUsersProvider);

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
                        _selectedUserId = null;
                        _selectedUserName = null;
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
                  Text('Selecione o Cliente', style: AdminTheme.headingSmall),
                  const SizedBox(height: 8),
                  usersAsync.when(
                    data: (users) => Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable.empty();
                        }
                        return users.where((user) {
                          final name = (user['displayName'] ?? '')
                              .toString()
                              .toLowerCase();
                          final email = (user['email'] ?? '')
                              .toString()
                              .toLowerCase();
                          final query = textEditingValue.text.toLowerCase();
                          return name.contains(query) || email.contains(query);
                        });
                      },
                      displayStringForOption: (user) =>
                          '${user['displayName']} (${user['email']})',
                      onSelected: (user) {
                        setState(() {
                          _selectedUserId = user['id'];
                          _selectedUserName = user['displayName'];
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: const TextStyle(
                                color: AdminTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Digite o nome ou email',
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
                                suffixIcon: _selectedUserId != null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                            );
                          },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Erro ao carregar clientes'),
                  ),
                  if (_selectedUserName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Chip(
                        label: Text(_selectedUserName!),
                        onDeleted: () {
                          setState(() {
                            _selectedUserId = null;
                            _selectedUserName = null;
                          });
                        },
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_event.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AddEventDialog({super.key, required this.initialDate});

  @override
  ConsumerState<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  AdminEventType _selectedType = AdminEventType.task;
  bool _hasReminder = false;
  Duration _reminderOffset = const Duration(minutes: 15);
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedDate = widget.initialDate;
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.initialDate),
    );
    _timeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1), // Gradient Primary 0
              onPrimary: Colors.white,
              surface: AdminTheme.bgCard,
              onSurface: AdminTheme.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AdminTheme.bgCard,
              hourMinuteTextColor: AdminTheme.textPrimary,
              dayPeriodTextColor: AdminTheme.textPrimary,
              dialHandColor: AdminTheme.gradientPrimary[0],
              dialBackgroundColor: AdminTheme.bgCardLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final eventDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = AdminEvent(
        id: '', // Firestore will generate ID
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        date: eventDate,
        type: _selectedType,
        remindAt: _hasReminder ? eventDate.subtract(_reminderOffset) : null,
      );

      try {
        await ref.read(adminRepositoryProvider).addEvent(event);

        if (mounted) {
          Navigator.of(context).pop();
          AppToast.success(
            context,
            message: 'Compromisso adicionado com sucesso!',
          );
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao adicionar compromisso: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AdminTheme.glassmorphicDecoration(opacity: 0.95),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Novo Compromisso', style: AdminTheme.headingSmall),
                const SizedBox(height: 24),
                AdminTextField(
                  controller: _titleController,
                  label: 'Título',
                  hint: 'Ex: Pagar Fornecedor',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AdminTextField(
                  controller: _descriptionController,
                  label: 'Descrição (Opcional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AdminTextField(
                        controller: _dateController,
                        label: 'Data',
                        readOnly: true,
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminTextField(
                        controller: _timeController,
                        label: 'Hora',
                        readOnly: true,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AdminDropdownField<AdminEventType>(
                  label: 'Tipo',
                  value: _selectedType,
                  items: AdminEventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Theme(
                  data: Theme.of(context).copyWith(
                    listTileTheme: const ListTileThemeData(
                      textColor: AdminTheme.textPrimary,
                    ),
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AdminTheme.gradientPrimary[0];
                        }
                        return Colors.grey;
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AdminTheme.gradientPrimary[0].withValues(
                            alpha: 0.5,
                          );
                        }
                        return Colors.grey.withValues(alpha: 0.5);
                      }),
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Definir Lembrete',
                      style: TextStyle(color: AdminTheme.textPrimary),
                    ),
                    value: _hasReminder,
                    onChanged: (value) {
                      setState(() {
                        _hasReminder = value;
                      });
                    },
                  ),
                ),
                if (_hasReminder)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: DropdownButton<Duration>(
                      value: _reminderOffset,
                      isExpanded: true,
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary),
                      underline: Container(
                        height: 1,
                        color: AdminTheme.borderLight,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: Duration(minutes: 15),
                          child: Text('15 minutos antes'),
                        ),
                        DropdownMenuItem(
                          value: Duration(minutes: 30),
                          child: Text('30 minutos antes'),
                        ),
                        DropdownMenuItem(
                          value: Duration(hours: 1),
                          child: Text('1 hora antes'),
                        ),
                        DropdownMenuItem(
                          value: Duration(hours: 24),
                          child: Text('1 dia antes'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _reminderOffset = value;
                          });
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: AdminTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AdminTheme.gradientPrimary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Salvar'),
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
}

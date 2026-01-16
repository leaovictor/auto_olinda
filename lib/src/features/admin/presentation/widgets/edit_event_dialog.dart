import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_event.dart';
import '../../../../shared/utils/app_toast.dart';

import '../widgets/admin_text_field.dart';
import '../widgets/admin_dropdown_field.dart';

class EditEventDialog extends ConsumerStatefulWidget {
  final AdminEvent event;

  const EditEventDialog({super.key, required this.event});

  @override
  ConsumerState<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends ConsumerState<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late AdminEventType _selectedType;
  bool _hasReminder = false;
  Duration _reminderOffset = const Duration(minutes: 15);
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );
    _selectedDate = widget.event.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.date);
    _selectedType = widget.event.type;
    _hasReminder = widget.event.remindAt != null;

    if (_hasReminder && widget.event.remindAt != null) {
      _reminderOffset = widget.event.date.difference(widget.event.remindAt!);
      // Normalize duration if it's not one of our standard options to avoid UI issues?
      // For now, we just let it be whatever it is or default if invalid logic.
      if (_reminderOffset.isNegative) {
        _reminderOffset = const Duration(minutes: 15);
      }
    }
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.event.date),
    );
    _timeController = TextEditingController(
      text: _selectedTime.format(context),
      // Note: format(context) might need context which is not available in initState if not localized correctly,
      // but usually TimeOfDay.format works if context is available.
      // Actually standard pattern is to set it later or use a standard formatter if context depends on locale.
      // We will set it in didChangeDependencies to be safe.
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timeController.text = _selectedTime.format(context);
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
    );
    if (picked != null && picked != _selectedTime) {
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

      final updatedEvent = widget.event.copyWith(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        date: eventDate,
        type: _selectedType,
        remindAt: _hasReminder ? eventDate.subtract(_reminderOffset) : null,
      );

      try {
        await ref.read(adminRepositoryProvider).updateEvent(updatedEvent);

        if (mounted) {
          Navigator.of(context).pop();
          AppToast.success(
            context,
            message: 'Compromisso atualizado com sucesso!',
          );
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao atualizar compromisso: $e');
        }
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Compromisso'),
        content: const Text('Tem certeza que deseja excluir este compromisso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteEvent(widget.event.id);
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          AppToast.success(context, message: 'Compromisso excluído.');
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, message: 'Erro ao excluir: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Compromisso'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminTextField(
                controller: _titleController,
                label: 'Título',
                validator: (value) =>
                    value!.isEmpty ? 'Insira um título' : null,
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: _descriptionController,
                label: 'Descrição',
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
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.event.type !=
            AdminEventType
                .other) // Example condition, just showing delete always usually
          TextButton(
            onPressed: _deleteEvent,
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),

        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _saveEvent, child: const Text('Salvar')),
      ],
    );
  }
}

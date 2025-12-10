import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_event.dart';
import '../../../../shared/utils/app_toast.dart';

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
      if (_reminderOffset.isNegative)
        _reminderOffset = const Duration(minutes: 15);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Insira um título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AdminEventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
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

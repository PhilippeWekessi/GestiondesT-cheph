import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // null = ajout, sinon = modification

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _fmt = DateFormat('d MMM y, HH:mm', 'fr_FR');
  final TaskService _service = TaskService();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _dateCtrl;
  DateTime? _date;
  late Priority _priority;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _contentCtrl = TextEditingController(text: t?.content ?? '');
    _date = t?.date;
    _dateCtrl = TextEditingController(text: t != null ? _fmt.format(t.date) : '');
    _priority = t?.priority ?? Priority.high;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final initial = _date ?? DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateCtrl.text = _fmt.format(_date!);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final task = Task(
        id: widget.task?.id ?? '',
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        date: _date!,
        priority: _priority,
      );

      if (_isEdit) {
        await _service.updateTask(task);
      } else {
        await _service.createTask(task);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // retour : la liste se recharge
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la tâche' : 'Nouvelle tâche'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Ex : Réviser Flutter',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le titre est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  hintText: 'Description de la tâche',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le contenu est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDateTime,
                decoration: const InputDecoration(
                  labelText: 'Date et heure',
                  suffixIcon: Icon(Icons.event),
                ),
                validator: (_) =>
                    _date == null ? "Choisissez la date et l'heure" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priorité'),
                items: Priority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 14, color: p.color),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (p) {
                  if (p != null) setState(() => _priority = p);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
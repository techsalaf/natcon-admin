import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NatconDelegateDetailsScreen extends StatefulWidget {
  final int count;
  final Map<String, dynamic> account;

  const NatconDelegateDetailsScreen({
    super.key,
    required this.count,
    required this.account,
  });

  @override
  State<NatconDelegateDetailsScreen> createState() =>
      _NatconDelegateDetailsScreenState();
}

class _NatconDelegateDetailsScreenState
    extends State<NatconDelegateDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> _delegates = [];
  bool _consent = false;

  @override
  void initState() {
    super.initState();
    final count = widget.count.clamp(1, 50);
    for (var i = 0; i < count; i++) {
      _delegates.add({
        'name': TextEditingController(
          text: i == 0 ? '${widget.account['name'] ?? ''}' : '',
        ),
        'email': TextEditingController(
          text: i == 0 ? '${widget.account['email'] ?? ''}' : '',
        ),
        'course': TextEditingController(),
        'institution': TextEditingController(),
        'level': TextEditingController(),
        'whatsapp': TextEditingController(
          text: i == 0
              ? '${widget.account['ccode'] ?? ''}${widget.account['mobile'] ?? ''}'
              : '',
        ),
        'calling_line': TextEditingController(),
        'state_origin': TextEditingController(),
        'times_attended': TextEditingController(text: '0'),
      });
    }
  }

  @override
  void dispose() {
    for (final delegate in _delegates) {
      for (final controller in delegate.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Widget _field(
    Map<String, TextEditingController> fields,
    String key,
    String label, {
    TextInputType keyboard = TextInputType.text,
    bool required = true,
    List<TextInputFormatter>? formatters,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: fields[key],
        keyboardType: keyboard,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: key == 'email'
            ? (value) {
                if (value == null || value.trim().isEmpty) return 'Required';
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim()))
                  return 'Enter a valid email';
                return null;
              }
            : key == 'times_attended'
            ? (value) {
                final count = int.tryParse(value ?? '');
                if (count == null || count < 0 || count > 99) {
                  return 'Enter a number from 0 to 99';
                }
                return null;
              }
            : required
            ? _required
            : null,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept the privacy notice to continue.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _delegates
          .map(
            (fields) => {
              for (final entry in fields.entries)
                entry.key: entry.value.text.trim(),
            },
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delegate details')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Each attendee needs an individual NATCON ticket. Complete these details for every delegate.',
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < _delegates.length; i++) ...[
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delegate ${i + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        _field(_delegates[i], 'name', 'Full name'),
                        _field(
                          _delegates[i],
                          'email',
                          'Gmail or email',
                          keyboard: TextInputType.emailAddress,
                        ),
                        _field(_delegates[i], 'course', 'Course'),
                        _field(_delegates[i], 'institution', 'Institution'),
                        _field(
                          _delegates[i],
                          'level',
                          'Level or status',
                          hint:
                              'Undergraduate, graduate, corps member, Masters, etc.',
                        ),
                        _field(
                          _delegates[i],
                          'whatsapp',
                          'WhatsApp number',
                          keyboard: TextInputType.phone,
                        ),
                        _field(
                          _delegates[i],
                          'calling_line',
                          'Calling line (if different from WhatsApp)',
                          keyboard: TextInputType.phone,
                          required: false,
                        ),
                        _field(
                          _delegates[i],
                          'state_origin',
                          'State of origin',
                        ),
                        _field(
                          _delegates[i],
                          'times_attended',
                          'Previous NATCON attendance',
                          keyboard: TextInputType.number,
                          formatters: [FilteringTextInputFormatter.digitsOnly],
                          hint: 'Enter 0 if this is your first NATCON',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _consent,
                onChanged: (value) => setState(() => _consent = value ?? false),
                title: const Text(
                  'I agree that TAA may use these details to manage this registration, payment, ticket delivery, and attendance.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                child: const Text('Continue to secure payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

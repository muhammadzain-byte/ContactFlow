import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../widgets/contact_avatar.dart';

class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key, this.contact});

  final Contact? contact;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _companyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late bool _isFavorite;

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nameController = TextEditingController(text: contact?.name ?? '');
    _roleController = TextEditingController(text: contact?.role ?? '');
    _companyController = TextEditingController(text: contact?.company ?? '');
    _phoneController = TextEditingController(text: contact?.phone ?? '');
    _emailController = TextEditingController(text: contact?.email ?? '');
    _locationController = TextEditingController(text: contact?.location ?? '');
    _notesController = TextEditingController(text: contact?.notes ?? '');
    _isFavorite = contact?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return _phoneController.text.trim().isEmpty
          ? 'Add a phone number or email address.'
          : null;
    }

    final looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return looksValid ? null : 'Enter a valid email address.';
  }

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return _emailController.text.trim().isEmpty
          ? 'Add a phone number or email address.'
          : null;
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 ? null : 'Enter at least 7 phone digits.';
  }

  String _createId(String name) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final prefix = slug.isEmpty ? 'contact' : slug;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final contact = Contact(
      id: widget.contact?.id ?? _createId(name),
      name: name,
      role: _roleController.text.trim(),
      company: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      location: _locationController.text.trim(),
      notes: _notesController.text.trim(),
      isFavorite: _isFavorite,
    );

    Navigator.of(context).pop(contact);
  }

  Contact get _previewContact {
    final original = widget.contact;
    final name = _nameController.text.trim();
    return Contact(
      id: original?.id ?? 'contact-form-preview',
      name: name.isEmpty ? 'New contact' : name,
      role: _roleController.text.trim(),
      company: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      location: _locationController.text.trim(),
      notes: _notesController.text.trim(),
      isFavorite: _isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit contact' : 'New contact')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withAlpha(105),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            ContactAvatar(
                              contact: _previewContact,
                              radius: 36,
                              enableHero: false,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEditing
                                        ? 'Update the profile'
                                        : 'Create a profile',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'ContactFlow keeps this information in memory for the current session.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Profile',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ContactField(
                        fieldKey: const ValueKey('contact-name-field'),
                        controller: _nameController,
                        label: 'Full name',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        validator:
                            (value) => _requiredValidator(value, 'Full name'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _ContactField(
                        controller: _roleController,
                        label: 'Role (optional)',
                        icon: Icons.badge_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),
                      _ContactField(
                        controller: _companyController,
                        label: 'Company or organization (optional)',
                        icon: Icons.business_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Contact details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Add a phone number, an email address, or both.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ContactField(
                        fieldKey: const ValueKey('contact-phone-field'),
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        validator: _phoneValidator,
                      ),
                      const SizedBox(height: 14),
                      _ContactField(
                        fieldKey: const ValueKey('contact-email-field'),
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 14),
                      _ContactField(
                        controller: _locationController,
                        label: 'Location (optional)',
                        icon: Icons.location_on_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 14),
                      _ContactField(
                        controller: _notesController,
                        label: 'Notes (optional)',
                        icon: Icons.notes_rounded,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 3,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile.adaptive(
                        key: const ValueKey('contact-favorite-field'),
                        value: _isFavorite,
                        onChanged: (value) {
                          setState(() => _isFavorite = value);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        title: const Text('Add to favorites'),
                        subtitle: const Text(
                          'Keep this person in your favorites view.',
                        ),
                        secondary: const Icon(Icons.star_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant.withAlpha(100)),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      key: const ValueKey('contact-form-save'),
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(isEditing ? 'Save changes' : 'Add contact'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

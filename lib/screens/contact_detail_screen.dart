import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/contact_controller.dart';
import '../models/contact.dart';
import '../widgets/contact_avatar.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({
    super.key,
    required this.contactId,
    required this.controller,
  });

  final String contactId;
  final ContactController controller;

  Future<void> _copyValue(
    BuildContext context,
    String label,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to the clipboard.')));
  }

  Future<void> _editContact(BuildContext context, Contact contact) async {
    final updated = await Navigator.of(context).push<Contact>(
      MaterialPageRoute<Contact>(
        builder: (context) => ContactFormScreen(contact: contact),
      ),
    );

    if (updated == null || !context.mounted) {
      return;
    }

    controller.updateContact(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${updated.name} was updated.')));
  }

  Future<void> _deleteContact(BuildContext context, Contact contact) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete contact?'),
            content: Text(
              '${contact.name} will be removed from this session. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const ValueKey('confirm-delete-contact'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    controller.removeContact(contact.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final contact = controller.contactById(contactId);
        if (contact == null) {
          return const Scaffold(
            body: Center(child: Text('This contact is no longer available.')),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final profileLine = [
          contact.role,
          contact.company,
        ].where((value) => value.isNotEmpty).join(' \u00B7 ');
        final hasAbout =
            contact.company.isNotEmpty ||
            contact.role.isNotEmpty ||
            contact.notes.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Contact details'),
            actions: [
              Semantics(
                button: true,
                toggled: contact.isFavorite,
                label:
                    contact.isFavorite
                        ? 'Remove ${contact.name} from favorites'
                        : 'Add ${contact.name} to favorites',
                child: ExcludeSemantics(
                  child: IconButton(
                    key: ValueKey('detail-favorite-${contact.id}'),
                    tooltip:
                        contact.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                    onPressed: () => controller.toggleFavorite(contact.id),
                    icon: Icon(
                      contact.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color:
                          contact.isFavorite ? const Color(0xFFFFB020) : null,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('edit-contact-button'),
                tooltip: 'Edit contact',
                onPressed: () => _editContact(context, contact),
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteContact(context, contact);
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded),
                            SizedBox(width: 12),
                            Text('Delete contact'),
                          ],
                        ),
                      ),
                    ],
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 48),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.tertiaryContainer,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              ContactAvatar(contact: contact, radius: 55),
                              const SizedBox(height: 22),
                              Text(
                                contact.name,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                profileLine.isEmpty ? 'Contact' : profileLine,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (contact.phone.isNotEmpty)
                                    FilledButton.icon(
                                      key: const ValueKey('copy-phone-button'),
                                      onPressed:
                                          () => _copyValue(
                                            context,
                                            'Phone number',
                                            contact.phone,
                                          ),
                                      icon: const Icon(Icons.phone_outlined),
                                      label: const Text('Copy phone'),
                                    ),
                                  if (contact.email.isNotEmpty)
                                    OutlinedButton.icon(
                                      key: const ValueKey('copy-email-button'),
                                      onPressed:
                                          () => _copyValue(
                                            context,
                                            'Email address',
                                            contact.email,
                                          ),
                                      icon: const Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                      label: const Text('Copy email'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ContactInfoCard(
                          title: 'Contact information',
                          children: [
                            if (contact.phone.isNotEmpty)
                              _ContactInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: contact.phone,
                                onCopy:
                                    () => _copyValue(
                                      context,
                                      'Phone number',
                                      contact.phone,
                                    ),
                              ),
                            if (contact.email.isNotEmpty)
                              _ContactInfoRow(
                                icon: Icons.alternate_email_rounded,
                                label: 'Email',
                                value: contact.email,
                                onCopy:
                                    () => _copyValue(
                                      context,
                                      'Email address',
                                      contact.email,
                                    ),
                              ),
                            if (contact.location.isNotEmpty)
                              _ContactInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: contact.location,
                              ),
                          ],
                        ),
                        if (hasAbout) ...[
                          const SizedBox(height: 16),
                          _ContactInfoCard(
                            title: 'About',
                            children: [
                              if (contact.company.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.business_outlined,
                                  label: 'Organization',
                                  value: contact.company,
                                ),
                              if (contact.role.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Role',
                                  value: contact.role,
                                ),
                              if (contact.notes.isNotEmpty)
                                _ContactInfoRow(
                                  icon: Icons.notes_rounded,
                                  label: 'Notes',
                                  value: contact.notes,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(110)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(135),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              tooltip: 'Copy $label',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 19),
            ),
        ],
      ),
    );
  }
}

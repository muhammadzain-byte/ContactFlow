import 'package:flutter/material.dart';

import '../models/contact.dart';
import 'contact_avatar.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoriteLabel =
        contact.isFavorite
            ? 'Remove ${contact.name} from favorites'
            : 'Add ${contact.name} to favorites';
    final profileLine = [
      contact.role,
      contact.company,
    ].where((value) => value.isNotEmpty).join(' \u00B7 ');
    final hasPhone = contact.phone.isNotEmpty;
    final primaryContact = hasPhone ? contact.phone : contact.email;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(110)),
      ),
      child: InkWell(
        key: ValueKey('contact-card-${contact.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              ContactAvatar(contact: contact, radius: 31),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profileLine.isEmpty ? 'Contact' : profileLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          hasPhone
                              ? Icons.phone_outlined
                              : Icons.alternate_email_rounded,
                          size: 17,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            primaryContact,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            contact.location.isEmpty
                                ? 'Location not added'
                                : contact.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Semantics(
                button: true,
                toggled: contact.isFavorite,
                label: favoriteLabel,
                child: ExcludeSemantics(
                  child: IconButton(
                    key: ValueKey('favorite-toggle-${contact.id}'),
                    tooltip: favoriteLabel,
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      contact.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color:
                          contact.isFavorite
                              ? const Color(0xFFFFB020)
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

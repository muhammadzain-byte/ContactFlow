import 'package:flutter/material.dart';

import '../controllers/contact_controller.dart';
import '../models/contact.dart';
import '../widgets/contact_card.dart';
import '../widgets/contact_empty_state.dart';
import 'contact_detail_screen.dart';
import 'contact_form_screen.dart';

class ContactDirectoryScreen extends StatefulWidget {
  const ContactDirectoryScreen({
    super.key,
    required this.controller,
    required this.onToggleTheme,
  });

  final ContactController controller;
  final VoidCallback onToggleTheme;

  @override
  State<ContactDirectoryScreen> createState() => _ContactDirectoryScreenState();
}

class _ContactDirectoryScreenState extends State<ContactDirectoryScreen> {
  late final TextEditingController _searchController;

  ContactController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: controller.query);
    _searchController.addListener(_handleSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openContact(Contact contact) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder:
            (context) => ContactDetailScreen(
              contactId: contact.id,
              controller: controller,
            ),
      ),
    );
  }

  Future<void> _addContact() async {
    final contact = await Navigator.of(context).push<Contact>(
      MaterialPageRoute<Contact>(
        builder: (context) => const ContactFormScreen(),
      ),
    );

    if (contact == null || !mounted) {
      return;
    }

    controller.setFilter(ContactFilter.all);
    _clearSearch();
    controller.addContact(contact);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contact.name} was added to your directory.')),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    controller.updateQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.people_alt_rounded,
                size: 22,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                'ContactFlow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('theme-toggle'),
            tooltip: 'Toggle light and dark theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-contact-button'),
        onPressed: _addContact,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add contact'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final contacts = controller.visibleContacts;
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final scaleDelta = (textScale - 1).clamp(0.0, 1.5);
              final cardExtent = 164.0 + (scaleDelta * 72).toDouble();

              return CustomScrollView(
                key: const PageStorageKey<String>('contact-directory-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _DirectoryHero(
                        contactCount: controller.contacts.length,
                        favoriteCount: controller.favoriteCount,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: TextField(
                          key: const ValueKey('contact-search'),
                          controller: _searchController,
                          onChanged: controller.updateQuery,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            labelText: 'Search contacts',
                            hintText: 'Name, role, company, phone, or email',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon:
                                _searchController.text.isEmpty
                                    ? null
                                    : IconButton(
                                      key: const ValueKey('clear-search'),
                                      tooltip: 'Clear search',
                                      onPressed: _clearSearch,
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilterChip(
                            key: const ValueKey('all-filter'),
                            selected: controller.filter == ContactFilter.all,
                            onSelected:
                                (_) => controller.setFilter(ContactFilter.all),
                            avatar: const Icon(
                              Icons.people_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('All contacts'),
                          ),
                          FilterChip(
                            key: const ValueKey('favorites-filter'),
                            selected:
                                controller.filter == ContactFilter.favorites,
                            onSelected:
                                (_) => controller.setFilter(
                                  ContactFilter.favorites,
                                ),
                            avatar: const Icon(
                              Icons.star_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Favorites (${controller.favoriteCount})',
                            ),
                          ),
                          PopupMenuButton<ContactSort>(
                            key: const ValueKey('sort-menu'),
                            tooltip: 'Sort contacts',
                            initialValue: controller.sort,
                            onSelected: controller.setSort,
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: ContactSort.nameAscending,
                                    child: Text('Name: A to Z'),
                                  ),
                                  PopupMenuItem(
                                    value: ContactSort.nameDescending,
                                    child: Text('Name: Z to A'),
                                  ),
                                ],
                            child: Chip(
                              avatar: const Icon(
                                Icons.sort_by_alpha_rounded,
                                size: 18,
                              ),
                              label: Text(
                                controller.sort == ContactSort.nameAscending
                                    ? 'A to Z'
                                    : 'Z to A',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Text(
                              '${contacts.length} ${contacts.length == 1 ? 'result' : 'results'}',
                              key: const ValueKey('result-count'),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (contacts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ContactEmptyState(
                        key: const ValueKey('empty-state'),
                        icon:
                            controller.filter == ContactFilter.favorites
                                ? Icons.star_outline_rounded
                                : Icons.person_search_rounded,
                        title:
                            controller.filter == ContactFilter.favorites
                                ? 'No favorites found'
                                : 'No contacts found',
                        message:
                            controller.query.isNotEmpty
                                ? 'Try a different name, company, phone number, or email address.'
                                : controller.filter == ContactFilter.favorites
                                ? 'Star any contact to keep that person close at hand.'
                                : 'Add a contact to start building your directory.',
                        actionLabel:
                            controller.query.isNotEmpty ? 'Clear search' : null,
                        onAction:
                            controller.query.isNotEmpty ? _clearSearch : null,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 560,
                          mainAxisExtent: cardExtent,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final contact = contacts[index];
                          return ContactCard(
                            contact: contact,
                            onTap: () => _openContact(contact),
                            onToggleFavorite:
                                () => controller.toggleFavorite(contact.id),
                          );
                        }, childCount: contacts.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DirectoryHero extends StatelessWidget {
  const _DirectoryHero({
    required this.contactCount,
    required this.favoriteCount,
  });

  final int contactCount;
  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 1080),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, const Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(48),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 22,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your people, beautifully organized.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Find the right person quickly, keep favorites close, and manage every profile in one calm workspace.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(220),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStat(
                value: '$contactCount',
                label: 'Contacts',
                icon: Icons.people_alt_rounded,
              ),
              _HeroStat(
                value: '$favoriteCount',
                label: 'Favorites',
                icon: Icons.star_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(42)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white.withAlpha(210),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'controllers/contact_controller.dart';
import 'data/seed_contacts.dart';
import 'models/contact.dart';
import 'screens/contact_directory_screen.dart';
import 'theme/app_theme.dart';

class ContactFlowApp extends StatefulWidget {
  const ContactFlowApp({super.key, this.initialContacts = seedContacts});

  final List<Contact> initialContacts;

  @override
  State<ContactFlowApp> createState() => _ContactFlowAppState();
}

class _ContactFlowAppState extends State<ContactFlowApp> {
  late final ContactController _controller;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _controller = ContactController(initialContacts: widget.initialContacts);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isCurrentlyDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    setState(() {
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: ContactDirectoryScreen(
        controller: _controller,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

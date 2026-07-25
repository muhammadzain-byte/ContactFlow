import 'package:flutter/foundation.dart';

@immutable
class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.phone,
    required this.email,
    required this.location,
    required this.notes,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String role;
  final String company;
  final String phone;
  final String email;
  final String location;
  final String notes;
  final bool isFavorite;

  String get initials {
    final parts =
        name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return String.fromCharCode(parts.first.runes.first).toUpperCase();
    }

    final firstInitial = String.fromCharCode(parts.first.runes.first);
    final lastInitial = String.fromCharCode(parts.last.runes.first);
    return '$firstInitial$lastInitial'.toUpperCase();
  }

  String get searchableText =>
      [name, role, company, phone, email, location].join(' ').toLowerCase();

  String get phoneDigits => phone.replaceAll(RegExp(r'\D'), '');

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty || searchableText.contains(normalizedQuery)) {
      return true;
    }

    final digits = normalizedQuery.replaceAll(RegExp(r'\D'), '');
    return digits.isNotEmpty && phoneDigits.contains(digits);
  }

  Contact copyWith({
    String? id,
    String? name,
    String? role,
    String? company,
    String? phone,
    String? email,
    String? location,
    String? notes,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

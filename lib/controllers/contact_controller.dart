import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/contact.dart';

enum ContactFilter { all, favorites }

enum ContactSort { nameAscending, nameDescending }

class ContactController extends ChangeNotifier {
  ContactController({required List<Contact> initialContacts})
    : _contacts = List<Contact>.of(initialContacts);

  final List<Contact> _contacts;
  String _query = '';
  ContactFilter _filter = ContactFilter.all;
  ContactSort _sort = ContactSort.nameAscending;

  UnmodifiableListView<Contact> get contacts =>
      UnmodifiableListView<Contact>(_contacts);

  String get query => _query;
  ContactFilter get filter => _filter;
  ContactSort get sort => _sort;
  int get favoriteCount =>
      _contacts.where((contact) => contact.isFavorite).length;

  List<Contact> get visibleContacts {
    final visible =
        _contacts.where((contact) {
          final matchesFilter =
              _filter == ContactFilter.all || contact.isFavorite;
          return matchesFilter && contact.matches(_query);
        }).toList();

    visible.sort((first, second) {
      final comparison = first.name.toLowerCase().compareTo(
        second.name.toLowerCase(),
      );
      return _sort == ContactSort.nameAscending ? comparison : -comparison;
    });

    return visible;
  }

  Contact? contactById(String id) {
    for (final contact in _contacts) {
      if (contact.id == id) {
        return contact;
      }
    }
    return null;
  }

  void updateQuery(String value) {
    final normalized = value.trim().toLowerCase();
    if (_query == normalized) {
      return;
    }
    _query = normalized;
    notifyListeners();
  }

  void setFilter(ContactFilter value) {
    if (_filter == value) {
      return;
    }
    _filter = value;
    notifyListeners();
  }

  void setSort(ContactSort value) {
    if (_sort == value) {
      return;
    }
    _sort = value;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index == -1) {
      return;
    }
    final contact = _contacts[index];
    _contacts[index] = contact.copyWith(isFavorite: !contact.isFavorite);
    notifyListeners();
  }

  void addContact(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void updateContact(Contact updatedContact) {
    final index = _contacts.indexWhere(
      (contact) => contact.id == updatedContact.id,
    );
    if (index == -1) {
      return;
    }
    _contacts[index] = updatedContact;
    notifyListeners();
  }

  Contact? removeContact(String id) {
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index == -1) {
      return null;
    }
    final removed = _contacts.removeAt(index);
    notifyListeners();
    return removed;
  }
}

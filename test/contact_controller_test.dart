import 'package:contact_flow/controllers/contact_controller.dart';
import 'package:contact_flow/models/contact.dart';
import 'package:flutter_test/flutter_test.dart';

const _alpha = Contact(
  id: 'alpha',
  name: 'Alpha Person',
  role: 'Designer',
  company: 'Studio',
  phone: '+1 (202) 555-0101',
  email: 'alpha@example.com',
  location: 'Seattle',
  notes: 'Alpha notes',
  isFavorite: true,
);

const _zulu = Contact(
  id: 'zulu',
  name: 'Zulu Person',
  role: 'Engineer',
  company: 'Lab',
  phone: '+1 (202) 555-0199',
  email: 'zulu@example.com',
  location: 'Austin',
  notes: 'Zulu notes',
);

void main() {
  late ContactController controller;

  setUp(() {
    controller = ContactController(initialContacts: const [_zulu, _alpha]);
  });

  tearDown(() {
    controller.dispose();
  });

  test('sorts contacts alphabetically by default', () {
    expect(controller.visibleContacts.map((contact) => contact.id), [
      'alpha',
      'zulu',
    ]);
  });

  test('sorts contacts in descending order', () {
    controller.setSort(ContactSort.nameDescending);

    expect(controller.visibleContacts.map((contact) => contact.id), [
      'zulu',
      'alpha',
    ]);
  });

  test('searches text and normalized phone digits', () {
    controller.updateQuery('DESIGNER');
    expect(controller.visibleContacts.single.id, 'alpha');

    controller.updateQuery('2025550199');
    expect(controller.visibleContacts.single.id, 'zulu');
  });

  test('filters and toggles favorites', () {
    controller.setFilter(ContactFilter.favorites);
    expect(controller.visibleContacts.single.id, 'alpha');

    controller.toggleFavorite('zulu');
    expect(controller.visibleContacts.map((contact) => contact.id), [
      'alpha',
      'zulu',
    ]);
  });

  test('adds, updates, and removes a contact', () {
    const added = Contact(
      id: 'new-contact',
      name: 'New Contact',
      role: 'Writer',
      company: 'Words',
      phone: '+1 202-555-0111',
      email: 'new@example.com',
      location: 'Boston',
      notes: 'New notes',
    );

    controller.addContact(added);
    expect(controller.contactById('new-contact'), added);

    final updated = added.copyWith(name: 'Updated Contact');
    controller.updateContact(updated);
    expect(controller.contactById('new-contact')?.name, 'Updated Contact');

    expect(controller.removeContact('new-contact')?.id, 'new-contact');
    expect(controller.contactById('new-contact'), isNull);
  });
}

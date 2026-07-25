import 'package:contact_flow/app.dart';
import 'package:contact_flow/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _contacts = [
  Contact(
    id: 'ada-lovelace',
    name: 'Ada Lovelace',
    role: 'Engineer',
    company: 'Analytical Works',
    phone: '+1 202-555-0101',
    email: 'ada@example.com',
    location: 'London',
    notes: 'Writes careful technical notes.',
    isFavorite: true,
  ),
  Contact(
    id: 'grace-hopper',
    name: 'Grace Hopper',
    role: 'Computer Scientist',
    company: 'Compiler Lab',
    phone: '+1 202-555-0112',
    email: 'grace@example.com',
    location: 'New York',
    notes: 'Builds tools that make programming more approachable.',
  ),
  Contact(
    id: 'katherine-johnson',
    name: 'Katherine Johnson',
    role: 'Mathematician',
    company: 'Flight Research',
    phone: '+1 202-555-0134',
    email: 'katherine@example.com',
    location: 'Virginia',
    notes: 'Solves complex navigation and orbital problems.',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(1000, 900),
    double textScaleFactor = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const ContactFlowApp(initialContacts: _contacts));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the directory and injected contacts', (tester) async {
    await pumpApp(tester);

    expect(find.text('ContactFlow'), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-search')), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Katherine Johnson'), findsOneWidget);
    expect(find.text('3 results'), findsOneWidget);
  });

  testWidgets('search is case-insensitive and can be cleared', (tester) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byKey(const ValueKey('contact-search')),
      'GRACE',
    );
    await tester.pump();

    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsNothing);
    expect(find.text('1 result'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear-search')));
    await tester.pump();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('3 results'), findsOneWidget);
  });

  testWidgets('favorites filter shows only favorited contacts', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('favorites-filter')));
    await tester.pump();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsNothing);
    expect(find.text('Katherine Johnson'), findsNothing);
    expect(find.text('1 result'), findsOneWidget);
  });

  testWidgets('favorite changes are reflected in the filtered directory', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(
      find.byKey(const ValueKey('favorite-toggle-grace-hopper')),
    );
    await tester.pump();

    expect(find.text('Favorites (2)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('favorites-filter')));
    await tester.pump();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('2 results'), findsOneWidget);
  });

  testWidgets('opens the correct contact detail screen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('contact-card-ada-lovelace')));
    await tester.pumpAndSettle();

    expect(find.text('Contact details'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('+1 202-555-0101'), findsWidgets);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.byKey(const ValueKey('copy-phone-button')), findsOneWidget);
  });

  testWidgets('rejects an empty contact form', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('add-contact-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('contact-form-save')));
    await tester.pump();

    expect(find.text('New contact'), findsOneWidget);
    expect(find.byKey(const ValueKey('contact-form-save')), findsOneWidget);
  });

  testWidgets('adds a contact with one contact method', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('add-contact-button')));
    await tester.pumpAndSettle();
    expect(find.text('New contact'), findsOneWidget);

    final nameField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('contact-name-field'), skipOffstage: false),
    );
    final emailField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('contact-email-field'), skipOffstage: false),
    );
    nameField.controller!.text = 'Lin Chen';
    emailField.controller!.text = 'lin@example.com';
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('contact-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Lin Chen'), findsOneWidget);
    expect(find.text('4 results'), findsOneWidget);
  });

  testWidgets('supports a narrow screen with large text', (tester) async {
    await pumpApp(tester, size: const Size(390, 844), textScaleFactor: 2);

    expect(find.text('ContactFlow'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('contact-card-ada-lovelace')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

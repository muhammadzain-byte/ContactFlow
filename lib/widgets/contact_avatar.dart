import 'package:flutter/material.dart';

import '../models/contact.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 30,
    this.enableHero = true,
  });

  final Contact contact;
  final double radius;
  final bool enableHero;

  static const List<List<Color>> _gradients = [
    [Color(0xFF335CFF), Color(0xFF6C8CFF)],
    [Color(0xFF7C3AED), Color(0xFFA855F7)],
    [Color(0xFF0F9D8A), Color(0xFF2DD4BF)],
    [Color(0xFFE8573F), Color(0xFFF59E73)],
    [Color(0xFF0E7490), Color(0xFF38BDF8)],
    [Color(0xFFBE185D), Color(0xFFF472B6)],
  ];

  @override
  Widget build(BuildContext context) {
    final characterTotal = contact.id.codeUnits.fold<int>(
      0,
      (total, value) => total + value,
    );
    final colors = _gradients[characterTotal % _gradients.length];
    final textScale = radius / 2.2;

    final avatar = Semantics(
      image: true,
      label: '${contact.name} avatar',
      child: ExcludeSemantics(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withAlpha(55),
                blurRadius: radius / 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            contact.initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: textScale,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );

    if (!enableHero) {
      return avatar;
    }

    return Hero(
      tag: 'contact-avatar-${contact.id}',
      child: Material(type: MaterialType.transparency, child: avatar),
    );
  }
}

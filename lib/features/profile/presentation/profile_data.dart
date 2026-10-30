import 'package:flutter/material.dart';

class ProfileData {
  ProfileData._();

  static const String username = 'arian';
  static const String handle = '@arian';
  static const String title = 'رزمی‌کار و برنامه‌نویس';

  static const List<ProfileBioLine> bio = [
    ProfileBioLine(
      icon: Icons.sports_martial_arts_rounded,
      text: 'رزمی‌کار سبک کیوکوشین',
    ),
    ProfileBioLine(icon: Icons.code_rounded, text: 'برنامه‌نویس بک‌اند'),
    ProfileBioLine(
      icon: Icons.terminal_rounded,
      text: 'مسلط به NestJS و Django',
    ),
  ];
}

class ProfileBioLine {
  final IconData icon;
  final String text;

  const ProfileBioLine({required this.icon, required this.text});
}

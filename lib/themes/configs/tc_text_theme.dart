import 'package:flutter/material.dart';

class TextThemes {
  TextThemes._();
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: const TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.black),
    headlineSmall: const TextStyle().copyWith(fontSize: 23.0, fontWeight: FontWeight.bold, color: Colors.black),
    //
    titleLarge: const TextStyle().copyWith(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleMedium: const TextStyle().copyWith(fontSize: 19.0, fontWeight: FontWeight.w600, color: Colors.black),
    titleSmall: const TextStyle().copyWith(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black),
    //
    bodyLarge: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyMedium: const TextStyle().copyWith(fontSize: 11.0, color: Colors.black),
    bodySmall: const TextStyle().copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: Colors.black87,
    ),

    labelLarge: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.black),
    labelMedium: const TextStyle().copyWith(fontSize: 11.0, color: Colors.black.withOpacity(0.5)),
    labelSmall: const TextStyle().copyWith(fontSize: 10.0, color: Colors.black),
  );

  //customize for the dark mode
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: const TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: const TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
    //
    titleLarge: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleMedium: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.white),
    titleSmall: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
    //
    bodyLarge: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
    bodyMedium: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white),
    bodySmall: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),

    labelLarge: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.white),
    labelMedium: const TextStyle().copyWith(fontSize: 11.0, color: Colors.white),
    labelSmall: const TextStyle().copyWith(fontSize: 10.0, color: Colors.white),
  );
}

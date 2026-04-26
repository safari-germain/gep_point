import 'package:flutter/material.dart';

class BottomNavigationBarThemes {
  BottomNavigationBarThemes._();

  static BottomNavigationBarThemeData lightBottomNavigationBar = const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedIconTheme: IconThemeData(
      color: Colors.grey,
      applyTextScaling: true,
      size: 35,
    ),
    unselectedIconTheme: IconThemeData(
      color: Colors.black,
      applyTextScaling: true,
      size: 25,
    ),
    elevation: 0,
    selectedItemColor: Color.fromARGB(255, 164, 225, 253),
    unselectedItemColor: Colors.black,
    showSelectedLabels: true,
    type: BottomNavigationBarType.shifting,
  );

  static BottomNavigationBarThemeData darkBottomNavigationBar = const BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 44, 44, 44),
    selectedIconTheme: IconThemeData(
      color: Colors.grey,
      applyTextScaling: true,
      size: 35,
    ),
    unselectedIconTheme: IconThemeData(
      color: Colors.white,
      applyTextScaling: true,
      size: 25,
    ),
    elevation: 0,
    selectedItemColor: Colors.teal,
    unselectedItemColor: Colors.white,
    showSelectedLabels: true,
    type: BottomNavigationBarType.shifting,
  );
}

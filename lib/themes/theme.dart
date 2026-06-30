import 'package:gep_point/themes/configs/tc_card.dart';
import 'package:gep_point/themes/configs/tc_dialog.dart';
import 'package:gep_point/themes/configs/tc_out_line_button_theme.dart';
import 'package:gep_point/themes/configs/tc_appbar.dart';
import 'package:gep_point/themes/configs/tc_bottom_navigation_bar.dart';
import 'package:gep_point/themes/configs/tc_bottom_sheet.dart';
import 'package:gep_point/themes/configs/tc_color_sheme.dart';
import 'package:gep_point/themes/configs/tc_drawer.dart';
import 'package:gep_point/themes/configs/tc_dropdown_button.dart';
import 'package:gep_point/themes/configs/tc_eleveted_button.dart';
import 'package:gep_point/themes/configs/tc_icon.dart';
import 'package:gep_point/themes/configs/tc_list_tile.dart';
import 'package:gep_point/themes/configs/tc_switch.dart';
import 'package:gep_point/themes/configs/tc_text_button_theme.dart';
import 'package:gep_point/themes/configs/tc_text_input.dart';
import 'package:gep_point/themes/configs/tc_text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  AppThemes._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(TextThemes.lightTextTheme),
    switchTheme: SwitchThemes.lightSwichThemeData,
    inputDecorationTheme: TextInput.lightInputDecorationTheme,
    elevatedButtonTheme: ElevationButtonTheme.lightElevetedButton,
    appBarTheme: AppbarThemes.lightAppbartheme,
    bottomSheetTheme: BottomSheetTheme.lightBottomSheetTheme,
    cardTheme: CardThemesData.lightCardtheme,
    dialogTheme: DialogThemesData.lightDialogTheme,
    drawerTheme: DrowerThemeData.lightDrawerThemeData,
    outlinedButtonTheme: OutLineButtonThemes.lightOutLineButtonTheme,
    iconTheme: IconThemes.lightIconTheme,
    textButtonTheme: TextButtonThemes.lightTextButtonThemeData,
    colorScheme: ColorShemee.primaryColorSheme,
    dropdownMenuTheme: DropDownButtonThemeDatas.lightDropDownButontheme,
    listTileTheme: ListTileThemes.lightListTileTheme,
    scaffoldBackgroundColor: Colors.white,
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
    bottomNavigationBarTheme: BottomNavigationBarThemes.lightBottomNavigationBar,
  );

  //dark mode
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.interTextTheme(TextThemes.darkTextTheme),
    switchTheme: SwitchThemes.darkSwichThemeData,
    inputDecorationTheme: TextInput.darkInputDecorationTheme,
    elevatedButtonTheme: ElevationButtonTheme.darkElevetedButton,
    appBarTheme: AppbarThemes.darkAppbartheme,
    bottomSheetTheme: BottomSheetTheme.darkBottomSheetTheme,
    cardTheme: CardThemesData.darkCardtheme,
    dialogTheme: DialogThemesData.darkDialogTheme,
    drawerTheme: DrowerThemeData.darkDrawerThemeData,
    outlinedButtonTheme: OutLineButtonThemes.darkOutLineButtonTheme,
    iconTheme: IconThemes.darkIconTheme,
    textButtonTheme: TextButtonThemes.darkTextButtonThemeData,
    colorScheme: ColorShemee.darkColorSheme,
    dropdownMenuTheme: DropDownButtonThemeDatas.darkDropDownButontheme,
    listTileTheme: ListTileThemes.darkListTileTheme,
    scaffoldBackgroundColor: const Color.fromARGB(221, 26, 25, 25),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
    bottomNavigationBarTheme: BottomNavigationBarThemes.darkBottomNavigationBar,
  );
}

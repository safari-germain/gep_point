import 'package:gep_point/constants.dart';
import 'package:flutter/material.dart';

class TextInput {
  TextInput._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 1,
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: const TextStyle().copyWith(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.grey),
    hintStyle: const TextStyle().copyWith(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.grey),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Colors.black.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious), borderSide: BorderSide(width: 1, color: primaryColor)),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: Colors.grey)),
    focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: primaryColor)),
    errorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious), borderSide: const BorderSide(width: 1, color: Colors.red)),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: Colors.orange)),
  );
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 1,
    fillColor: Colors.black.withOpacity(0.7),
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
    labelStyle: const TextStyle().copyWith(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.grey),
    hintStyle: const TextStyle().copyWith(fontFamily: 'Plus Jakarta', fontSize: 11, color: Colors.grey),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Colors.grey),
    border: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: Colors.grey)),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: Colors.grey)),
    focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: primaryColor)),
    errorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious), borderSide: const BorderSide(width: 1, color: Colors.red)),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        borderSide: const BorderSide(width: 1, color: Colors.orange)),
  );
}

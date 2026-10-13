import 'package:flutter/material.dart';

// form decoration
InputDecoration textInputDecoration(bool isDark) {
  return InputDecoration(
    fillColor: isDark ? Colors.grey[800] : Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.brown[100]!),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Colors.pink, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
  );
}

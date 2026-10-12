import 'package:flutter/material.dart';

class AppTheme {
  // Paleta principal
  static const verde = Color(0xFF2E7D32);
  static const verdeClaro = Color(0xFF4CAF50);
  static const verdeMuy = Color(0xFFE8F5E9);
  static const tierra = Color(0xFF795548);
  static const tierraClaro = Color(0xFFEFEBE9);
  static const amarillo = Color(0xFFF9A825);
  static const azul = Color(0xFF1565C0);
  static const azulClaro = Color(0xFFE3F2FD);
  static const morado = Color(0xFF6A1B9A);
  static const naranja = Color(0xFFE65100);
  static const rojo = Color(0xFFC62828);
  static const fondo = Color(0xFFF9F6F0);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          surface: fondo,
        ),
        scaffoldBackgroundColor: fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: verde,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: verdeClaro,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: verdeClaro, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: rojo, width: 1),
          ),
          labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:brew_crew/providers/cart_provider.dart';

void main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _lightScheme =
      ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: Brightness.light,
      ).copyWith(
        primary: Colors.brown[700],
        onPrimary: Colors.white,
        secondary: Colors.pink[400],
        onSecondary: Colors.white,
        surface: Colors.brown[50],
      );

  static final _darkScheme =
      ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Colors.brown[300],
        onPrimary: Colors.brown[900],
        secondary: Colors.pink[300],
        onSecondary: Colors.brown[900],
        surface: Colors.brown[900],
      );

  ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.secondary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModels?>.value(
      value: AuthService().user,
      initialData: null,
      child: ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const Wrapper(),
          theme: _theme(_lightScheme),
          darkTheme: _theme(_darkScheme),
          themeMode: ThemeMode.system, // Uses system setting (or ThemeMode.dark)
        ),
      ),
    );
  }
}

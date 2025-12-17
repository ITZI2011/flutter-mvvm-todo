import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';

import 'providers/task_provider.dart';
import 'screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final theme = ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF5B5FC7),
            brightness: provider.darkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor:
                provider.darkMode ? const Color(0xFF0F1115) : const Color(0xFFF6F7FB),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              surfaceTintColor: Colors.transparent,
            ),
            // Flutter 3.35: CardThemeData
            cardTheme: const CardThemeData(
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: provider.darkMode ? const Color(0xFF181B22) : const Color(0xFFF2F3F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Todo App',
            theme: theme,
            home: const TodoScreen(),
          );
        },
      ),
    );
  }
}

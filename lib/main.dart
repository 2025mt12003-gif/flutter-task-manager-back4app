
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'
    show ParseUser;

import 'config/parse_config.dart';
import 'screens/login_screen.dart';
import 'screens/task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Back4App Parse SDK
  await ParseConfig.initialize();

  ParseUser? currentUser;

  // Restore existing user session
  try {
    currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser != null) {
      final token = currentUser.sessionToken;

      if (token == null || token.isEmpty) {
        currentUser = null;
      } else {
        final response =
            await ParseUser.getCurrentUserFromServer(token);

        if (response?.success != true) {
          currentUser = null;
        }
      }
    }
  } catch (e) {
    debugPrint('Session restoration failed: $e');
    currentUser = null;
  }

  // Start Flutter application
  runApp(
    TaskManagerApp(
      isLoggedIn: currentUser != null,
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  final bool isLoggedIn;

  const TaskManagerApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,

      // Application theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      // Restore existing authenticated session
      home: isLoggedIn
          ? const TaskScreen()
          : const LoginScreen(),
    );
  }
}

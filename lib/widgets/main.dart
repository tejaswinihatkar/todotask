import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screens/firebase_options.dart'; // Import the generated file
import '../screens/auth_wrapper.dart';
import '../screens/focus_home_page.dart';
import '../screens/login_page.dart';
import '../screens/registration_page.dart';
import '../screens/todo_tasks.dart';
import '../screens/pomodoro_timer.dart';
import '../screens/select_apps_screen.dart';
import '../screens/select_contacts_screen.dart';
import '../screens/profile_page.dart'; // Import ProfilePage
import 'package:permission_handler/permission_handler.dart';
import '../screens/contact_manager.dart'; // Import ContactManager

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: firebaseOptions, // Ensure firebaseOptions is provided
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const FocusHomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/tasks': (context) => const TodoTasksScreen(),
        '/pomodoro': (context) => const PomodoroTimer(
            taskName: "Default Task", // Use a placeholder or dynamic task name
            duration: 25, // Use a placeholder or dynamic duration
        ),
        '/select_apps': (context) => const SelectAppsScreen(),
        '/select_contacts': (context) =>  SelectContactsScreen(),
        '/profile': (context) => const ProfilePage(), // Add the ProfilePage route
        '/todo': (context) => const TodoTasksScreen(),
      },
    );
  }
}

Future<bool> requestPermission() async {
  // Check if the contact permission has been granted
  var status = await Permission.contacts.status;
  
  // If permission is not granted, request it from the user
  if (!status.isGranted) {
    status = await Permission.contacts.request();
  }
  
  // Return true if permission is granted, otherwise false
  return status.isGranted;
}

// Example usage of ContactManager (can be added in relevant parts of the app)
Future<void> enableFocusMode(List<String> selectedContacts) async {
  await ContactManager.muteUnselectedContacts(selectedContacts);
}

Future<void> disableFocusMode() async {
  await ContactManager.disableFocusMode();
}

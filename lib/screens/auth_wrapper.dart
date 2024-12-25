import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'focus_home_page.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const FocusHomePage();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
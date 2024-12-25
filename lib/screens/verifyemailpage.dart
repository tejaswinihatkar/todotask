import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    super.initState();
    // Check if the user is already verified
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is verified, navigate to home screen
      if (user.emailVerified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // User is not verified, show a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Verification Required'),
            content: const Text('Please verify your email address to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('A verification email has been sent to your email address.'),
              const SizedBox(height: 20),
              const Text('Please check your inbox and click on the verification link.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendVerificationEmail,
                child: const Text('Resend Verification Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/custom_navbar.dart';
import 'select_apps_screen.dart';
import 'select_contacts_screen.dart';

class FocusHomePage extends StatelessWidget {
  const FocusHomePage({super.key});

  Future<void> _requestPermissions() async {
    await [
      Permission.contacts,
      Permission.storage,
      Permission.systemAlertWindow,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
      Permission.accessNotificationPolicy,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    _requestPermissions(); // Request permissions when the widget is built

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to CONCENTRIX'),
        backgroundColor: const Color.fromARGB(255, 21, 142, 136),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-screen background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img.png'), // Replace with your image path
                fit: BoxFit.cover, // Ensures the image covers the full screen
              ),
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select:',
                  style: TextStyle(
                    color: Color.fromARGB(255, 8, 8, 8),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.contacts, size: 50, color: Color.fromARGB(255, 10, 136, 238)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SelectContactsScreen()),
                            );
                          },
                        ),
                        const Text(
                          'Contacts',
                          style: TextStyle(color: Color.fromARGB(255, 10, 136, 238), fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.android, size: 50, color:Color.fromARGB(255, 21, 167, 26),),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SelectAppsScreen()),
                            );
                          },
                        ),
                        const Text(
                          'Apps',
                          style: TextStyle(
                            color: Color.fromARGB(255, 21, 167, 26),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}

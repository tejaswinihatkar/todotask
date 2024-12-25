import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';  // For MethodChannel

// Generalized permission request function
Future<bool> requestPermission(Permission permission) async {
  var status = await permission.status;
  if (!status.isGranted) {
    status = await permission.request();
  }
  return status.isGranted;
}

class SelectAppsScreen extends StatefulWidget {
  const SelectAppsScreen({super.key});

  @override
  _SelectAppsScreenState createState() => _SelectAppsScreenState();
}

class _SelectAppsScreenState extends State<SelectAppsScreen> {
  bool _permissionGranted = false;
  List<Application> _installedApps = [];
  final List<Application> _selectedApps = []; // List to store selected (unmuted) apps

  static const platform = MethodChannel('com.example.app/notification'); // MethodChannel

  @override
  void initState() {
    super.initState();
    // Request the necessary permission (e.g., notifications or other)
    requestPermission(Permission.notification).then((granted) {
      setState(() {
        _permissionGranted = granted;
      });
      if (granted) {
        _fetchInstalledApps(); // Fetch apps if permission is granted
      }
    });
  }

  // Function to fetch installed apps
  Future<void> _fetchInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true, // Include app icons
      includeSystemApps: false, // Exclude system apps
    );
    setState(() {
      _installedApps = apps;
    });
  }

  // Show a dialog to manage focus mode for selected and unselected apps
  Future<void> _showManageFocusModeForSelectedApps() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Focus Mode for Selected Apps'),
          content: const Text(
              'Focus mode will mute notifications for unselected apps (muted contacts). Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () {
                // Mute notifications for unselected apps and unmute selected apps
                _manageFocusMode();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  // Function to manage focus mode (mute unselected apps)
  Future<void> _manageFocusMode() async {
    List<Application> unselectedApps = _installedApps
        .where((app) => !_selectedApps.contains(app))
        .toList(); // Find unselected apps (muted apps)

    List<String> unselectedAppPackageNames =
        unselectedApps.map((app) => app.packageName).toList();
    List<String> selectedAppPackageNames =
        _selectedApps.map((app) => app.packageName).toList();

    // Call platform-specific code to manage notification access
    try {
      await platform.invokeMethod('manageNotifications', {
        'unmutedApps': selectedAppPackageNames,
        'mutedApps': unselectedAppPackageNames,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Focus mode updated.'),
      ));
    } on PlatformException catch (e) {
      print("Failed to manage notifications: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps'),
        backgroundColor: const Color.fromARGB(255, 21, 142, 136),
        actions: [
          if (_selectedApps.isNotEmpty) // Show button if apps are selected
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Show dialog to enable focus mode for selected apps
                _showManageFocusModeForSelectedApps();
              },
            )
        ],
      ),
      body: _permissionGranted
          ? _installedApps.isEmpty
              ? const Center(child: CircularProgressIndicator()) // Loading spinner
              : ListView.builder(
                  itemCount: _installedApps.length,
                  itemBuilder: (context, index) {
                    Application app = _installedApps[index];
                    bool isSelected = _selectedApps.contains(app); // Check if app is selected

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedApps.add(app); // Add app to selected (unmuted) list
                          } else {
                            _selectedApps.remove(app); // Remove app from selected (unmuted) list
                          }
                        });
                      },
                      title: Text(app.appName), // App name
                      subtitle: Text(app.packageName), // Package name
                      secondary: app is ApplicationWithIcon
                          ? Image.memory(app.icon, width: 40, height: 40) // App icon
                          : null,
                    );
                  },
                )
          : const Center(
              child: Text(
                'Permission required to access notifications',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
    );
  }
}

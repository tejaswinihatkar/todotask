import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  XFile? _selectedImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = FirebaseAuth.instance.currentUser;
    setState(() {
      _profileImageUrl = _user?.photoURL; // Set initial profile image URL
    });
  }

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });

      // Upload the image to Firebase Storage and update profile image URL
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      if (_selectedImage == null) return;

      // Create a reference to the Firebase Storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${_user!.uid}.jpg');

      // Upload the file to Firebase Storage
      await storageRef.putFile(File(_selectedImage!.path));

      // Get the URL of the uploaded image
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the user's profile with the new photo URL
      await _user!.updatePhotoURL(downloadUrl);
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;

      setState(() {
        _profileImageUrl = downloadUrl;
      });
    } catch (e) {
      // Handle any errors
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_user != null)
              Column(
                children: [
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) // Display Firebase image URL
                          : const AssetImage('assets/default_avatar.png') 
                              as ImageProvider, // Default image if no profile picture
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Name: ${_user!.displayName ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${_user!.email}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

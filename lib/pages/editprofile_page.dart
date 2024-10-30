import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyeksregep/models/Userprofile.dart';
import 'package:proyeksregep/pages/profiledetail_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  EditProfilePage({required this.userProfile});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _photoUrl; // Variable to store the photo URL

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController.text = widget.userProfile.name;
    ageController.text = widget.userProfile.age.toString();
    dobController.text = widget.userProfile.dateOfBirth;
    _photoUrl = widget.userProfile.photoUrl; // Get current photo URL
  }

  // Function to save updated profile
  Future<void> _saveUpdatedProfile() async {
    if (nameController.text.isEmpty || ageController.text.isEmpty || dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    try {
      int age = int.parse(ageController.text);
      User? user = _auth.currentUser;

      if (user != null) {
        UserProfile updatedProfile = UserProfile(
          id: user.uid,
          name: nameController.text,
          age: age,
          dateOfBirth: dobController.text,
          photoUrl: _photoUrl, // Include photo URL
        );

        // Save data to Firestore
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .set(updatedProfile.toMap());

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile updated!')));

        // Navigate back to ProfileDetailPage with updated data
        Navigator.pop(context, updatedProfile); // Send updated profile back
      }
    } catch (e) {
      // Show an alert if age is not a valid number
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid age input. Please enter a numeric value.')));
    }
  }

  // Function to select a new profile photo
  Future<void> _selectProfilePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Upload photo to Firebase Storage
      String filePath = 'profile_photos/${_auth.currentUser!.uid}.png'; // Set file path for the image
      File file = File(image.path);
      try {
        await FirebaseStorage.instance.ref(filePath).putFile(file); // Upload the image

        // Get the download URL
        String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
        setState(() {
          _photoUrl = downloadUrl; // Update photo URL in state
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload photo.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectProfilePhoto, // Call function to select a photo
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                child: _photoUrl == null ? Icon(Icons.camera_alt, size: 60.0) : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number, // Input only numbers
            ),
            GestureDetector(
              onTap: () => _selectDate(context), // Call date picker
              child: AbsorbPointer(
                child: TextField(
                  controller: dobController,
                  decoration: InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUpdatedProfile, // Call function to save updated data
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      dobController.text = formattedDate; // Set the selected date in the controller
    }
  }
}

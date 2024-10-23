import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    nameController.text = widget.userProfile.name;
    ageController.text = widget.userProfile.age.toString();
    dobController.text = widget.userProfile.dateOfBirth;
  }

  // Function to save updated profile
  Future<void> _saveUpdatedProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      UserProfile updatedProfile = UserProfile(
        id: user.uid,
        name: nameController.text,
        age: int.parse(ageController.text),
        dateOfBirth: dobController.text,
      );

      // Update Firestore with new data
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .set(updatedProfile.toMap());

      // Show success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile updated!')));

      // Navigate back to ProfileDetailPage with updated profile
      Navigator.pop(context, updatedProfile); // Kembali ke halaman profil dengan data yang diperbarui
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

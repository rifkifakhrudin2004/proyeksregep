import 'package:flutter/material.dart';
import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
import 'editprofile_page.dart'; // Import the EditProfilePage
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for data handling
import 'home_page.dart'; // Import HomePage for navigation

class ProfileDetailPage extends StatelessWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onEdit; // Change to accept UserProfile as parameter
  final Function() onClear;

  ProfileDetailPage({
    required this.userProfile,
    required this.onEdit,
    required this.onClear,
  });

  // Function to show confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to clear this profile?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                onClear(); // Call onClear function if user confirms
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${userProfile.name}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Age: ${userProfile.age}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Date of Birth: ${userProfile.dateOfBirth}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman EditProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(userProfile: userProfile),
                  ),
                ).then((updatedUserProfile) {
                  if (updatedUserProfile != null) {
                    // Update userProfile dengan data yang diperbarui jika ada
                    onEdit(updatedUserProfile); // Pass the updated user profile
                  }
                });
              },
              child: Text("Edit Profile"),
            ),
            ElevatedButton(
              onPressed: () => _showDeleteConfirmationDialog(context), // Show confirmation dialog
              child: Text("Clear Data"),
            ),
          ],
        ),
      ),
    );
  }
}

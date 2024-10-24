import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
import 'package:proyeksregep/pages/profiledetail_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Load profile data on initial access
  }

  // Function to load profile from Firestore
  Future<void> _loadProfile() async {
    User? user = _auth.currentUser; // Get current user
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid) // Get document based on user UID
          .get();

      // If the profile document exists, fill in the form fields
      if (doc.exists) {
        userProfile = UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        // Kosongkan inputan jika ingin hanya menampilkan data setelah "Lihat Profil"
      }
    }
  }

  // Function to show alert when data is incomplete
void _showIncompleteDataAlert() {
  String errorMessage = '';
  
  // Check which fields are empty and create the error message
  if (nameController.text.isEmpty) {
    errorMessage += 'Nama tidak boleh kosong.\n';
  }
  if (ageController.text.isEmpty) {
    errorMessage += 'Usia tidak boleh kosong.\n';
  }
  if (dobController.text.isEmpty) {
    errorMessage += 'Tanggal lahir tidak boleh kosong.\n';
  }

  // Show alert if there are incomplete fields
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Data Tidak Lengkap'),
        content: Text(errorMessage.trim()), // Trim the error message
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close alert dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
  // Function to save profile to Firestore
  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;

    // Check if all fields are filled
    if (_areFieldsEmpty()) {
      _showIncompleteDataAlert(); // Show alert if any field is empty
      return; // Exit the function if there are empty fields
    }

    if (user != null) {
      // Check if profile already exists
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid) // Get document based on user UID
          .get();

      if (doc.exists) {
        // If the profile already exists, show alert
        _showAlert("Profile sudah ada", "Anda tidak dapat menyimpan profil Anda lagi.");
      } else {
        // Create a UserProfile object from input data
        UserProfile profile = _createUserProfile(user.uid);

        // Save data to Firestore with user UID as document key
        await _saveProfileToFirestore(user.uid, profile);

        // Show notification that data has been saved
        _showSuccessSnackbar('Profil berhasil disimpan!');

        // Clear input fields after saving
        _clearInputFields();

        // Navigate to detail page
        _navigateToProfileDetailPage(profile, user.uid);
      }
    }
  }

  // Check if any fields are empty
  bool _areFieldsEmpty() {
    return nameController.text.isEmpty || ageController.text.isEmpty || dobController.text.isEmpty;
  }

  // Create a UserProfile object from input data
  UserProfile _createUserProfile(String userId) {
    return UserProfile(
      id: userId,
      name: nameController.text,
      age: int.parse(ageController.text),
      dateOfBirth: dobController.text,
    );
  }

  // Save profile data to Firestore
  Future<void> _saveProfileToFirestore(String userId, UserProfile profile) async {
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(userId)
        .set(profile.toMap());
  }

  // Show a success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Clear input fields
  void _clearInputFields() {
    nameController.clear();
    ageController.clear();
    dobController.clear();
  }

  // Navigate to ProfileDetailPage
  void _navigateToProfileDetailPage(UserProfile profile, String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailPage(
          userProfile: profile,
          onEdit: (updatedProfile) {
            // Handle the updated profile if needed
            Navigator.pop(context); // Go back to profile page for editing
          },
          onClear: () async {
            // Delete data from Firestore
            await FirebaseFirestore.instance.collection('profiles').doc(userId).delete();
            Navigator.pop(context); // Go back to profile page
          },
        ),
      ),
    );
  }

  // Function to show alert
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
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
      // Format date to YYYY-MM-DD
      String formattedDate = "${selectedDate.toLocal()}".split(' ')[0];
      dobController.text = formattedDate; // Fill controller with selected date
    }
  }

  // Function to show alert when profile is not found
  void _showProfileNotFoundAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Tidak Ditemukan'),
          content: Text('Silahkan buat profil Anda terlebih dahulu.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to view profile details
  void _viewProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      if (userProfile != null) {
        // If profile exists, navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailPage(
              userProfile: userProfile!,
              onEdit: (updatedProfile) {
                // Handle editing if needed
                Navigator.pop(context); // Go back to profile page for editing
              },
              onClear: () async {
                // Delete data from Firestore
                await FirebaseFirestore.instance.collection('profiles').doc(user.uid).delete();
                Navigator.pop(context); // Go back to profile page
              },
            ),
          ),
        );
      } else {
        // If profile is not inputted, show alert
        _showProfileNotFoundAlert();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "Usia"),
              keyboardType: TextInputType.number, // Input only numbers
            ),
            GestureDetector(
              onTap: () => _selectDate(context), // Call date picker
              child: AbsorbPointer(
                child: TextField(
                  controller: dobController,
                  decoration: InputDecoration(labelText: "Tanggal Lahir (YYYY-MM-DD)"),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row( // Change to Row to place buttons side by side
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _saveProfile, // Call function to save data
                  child: Text("Simpan Profil"),
                ),
                ElevatedButton(
                  onPressed: _viewProfile, // Call function to view profile
                  child: Text("Lihat Profil"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

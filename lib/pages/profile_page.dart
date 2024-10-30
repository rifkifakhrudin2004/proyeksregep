import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
import 'package:proyeksregep/pages/profiledetail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  UserProfile? userProfile;
  String? _photourl;

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
        _photourl = userProfile?.photoUrl; // Load the existing photo URL
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

  // Show a dialog for selecting image source
  void _showImageSourceDialog() {
    // Check if a photo has already been uploaded
    if (_photourl != null) {
      // If a photo is already uploaded, show a dialog indicating that
      _showAlert("Informasi", "Anda sudah mengunggah foto profil. Anda tidak bisa mengunggah lagi.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Foto'),
          content: Text('Apakah ingin mengambil foto dari kamera atau galeri?'),
          actions: <Widget>[
            TextButton(
              child: Text('Kamera'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            TextButton(
              child: Text('Galeri'),
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to pick and upload profile image
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      String fileName = 'profile_photos/${_auth.currentUser!.uid}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload image to Firebase Storage
      await storageRef.putFile(File(image.path));
      // Get the download URL for the uploaded image
      _photourl = await storageRef.getDownloadURL();

      setState(() {}); // Update UI with new photo
    }
  }

  Future<void> _saveProfile() async {
    User? user = _auth.currentUser;

    if (_areFieldsEmpty()) {
      _showIncompleteDataAlert();
      return;
    }

    if (int.tryParse(ageController.text) == null) {
      _showAlert("Input Error", "Usia harus berupa angka.");
      return;
    }

    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _showAlert("Profile sudah ada", "Anda tidak dapat menyimpan profil Anda lagi.");
      } else {
        UserProfile profile = UserProfile(
          id: user.uid,
          name: nameController.text,
          age: int.parse(ageController.text),
          dateOfBirth: dobController.text,
          photoUrl: _photourl, // Set the photo URL
        );

        await _saveProfileToFirestore(user.uid, profile);
        _showSuccessSnackbar('Profil berhasil disimpan!');
        _clearInputFields();
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
                // Handle profile update if needed
              },
              onClear: () async {
                // Delete profile from Firestore
                await FirebaseFirestore.instance.collection('profiles').doc(user.uid).delete();
              },
            ),
          ),
        );
      } else {
        _showProfileNotFoundAlert(); // Show alert if profile not found
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _showImageSourceDialog, // Open dialog on image tap
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: _photourl != null ? NetworkImage(_photourl!) : null,
                child: _photourl == null
                    ? Icon(Icons.camera_alt, size: 60.0)
                    : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Usia'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dobController,
              decoration: InputDecoration(labelText: 'Tanggal Lahir'),
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Simpan Profil'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _viewProfile,
              child: Text('Lihat Profil'),
            ),
          ],
        ),
      ),
    );
  }
}

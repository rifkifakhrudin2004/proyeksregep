import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
import 'package:image_picker/image_picker.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  UserProfile? userProfile;
  List<String> _photoUrl = []; // Changed to a list to hold multiple photo URLs
  bool isEditingName = false;
  bool isEditingAge = false;
  bool isEditingDob = false;
  bool isEditingPhoneNumber = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
Future<void> _loadProfile() async {
  User? user = _auth.currentUser;
  if (user != null) {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      // Konversi data ke map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Pastikan photoUrl diambil dengan benar
      List<dynamic> photoUrls = data['photoUrl'] ?? [];
      
      setState(() {
        userProfile = UserProfile.fromMap(data);
        nameController.text = userProfile?.name ?? '';
        ageController.text = userProfile?.age.toString() ?? '';
        dobController.text = userProfile?.dateOfBirth ?? '';
        phoneNumberController.text = userProfile?.phoneNumber ?? '';
        
        // Konversi ke List<String> dan pastikan tidak kosong
        _photoUrl = photoUrls.map((url) => url.toString()).toList();
      });
    } else {
      _showProfileNotFoundAlert();
    }
  }
}
  void _showIncompleteDataAlert() {
    // Code for showing incomplete data alert remains the same
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Foto'),
          content: Text('Ambil foto dari kamera atau galeri?'),
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
  Future<void> _showPhotoPreview() async {
  if (_photoUrl.isEmpty) {
    // Tampilkan opsi untuk mengunggah foto baru jika tidak ada foto
    _showImageSourceDialog(); 
    return; // Keluar dari fungsi jika tidak ada foto untuk ditampilkan
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                _photoUrl.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return const Icon(Icons.person, size: 60.0);
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (_photoUrl.isNotEmpty) {
                        _removePhoto(_photoUrl.first);
                      }
                    },
                    child: Text('Hapus'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showImageSourceDialog(); // Menampilkan opsi untuk mengganti foto
                    },
                    child: Text('Ganti Foto'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Future<void> _pickAndUploadImage(ImageSource source) async {
  final XFile? image = await _picker.pickImage(source: source);
  if (image != null) {
    String fileName = 'profile_photos/${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    // Upload file ke Firebase Storage
    await storageRef.putFile(File(image.path));
    String photoUrl = await storageRef.getDownloadURL();

    // Simpan URL di Firestore
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(_auth.currentUser!.uid)
        .update({
      'photoUrl': [photoUrl] // Pastikan menyimpan dalam bentuk list jika menggunakan List
    });

    _photoUrl = [photoUrl]; // Update variabel _photoUrl dengan URL baru

    setState(() {}); // Perbarui UI setelah URL diperbarui
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
    UserProfile profile = UserProfile(
      id: user.uid,
      name: nameController.text,
      age: int.parse(ageController.text),
      dateOfBirth: dobController.text,
      phoneNumber: phoneNumberController.text, // Save phone number
      photoUrl: _photoUrl, // Preserve the existing list of photos
    );

    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .set(profile.toMap(), SetOptions(merge: true)); // Use merge to keep existing data

    _showSuccessSnackbar('Profil berhasil disimpan!');
  }
}

 Future<void> _removePhoto(String photoUrl) async {
  try {
    Reference photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
    await photoRef.delete();

    // Hapus dari daftar _photoUrl dan perbarui Firestore
    if (_photoUrl.isNotEmpty) {
      _photoUrl.remove(photoUrl); // Remove from list

      // Update Firestore after deletion
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_auth.currentUser!.uid)
          .update({'photoUrl': _photoUrl});
    }

    setState(() {}); // Refresh UI
    _showSuccessSnackbar('Foto berhasil dihapus');

    // Jika semua foto dihapus, tampilkan dialog untuk mengunggah foto baru
    if (_photoUrl.isEmpty) {
      _showImageSourceDialog(); // Tampilkan opsi untuk mengunggah foto baru
    }
  } catch (e) {
    _showAlert('Error', 'Gagal menghapus foto: $e');
  }
}

  bool _areFieldsEmpty() {
    return nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        dobController.text.isEmpty ||
        phoneNumberController.text.isEmpty;
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Profile Page'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _showPhotoPreview,
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: _photoUrl.isEmpty ? Colors.grey[300] : null,
              child: _photoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _photoUrl.first,
                        fit: BoxFit.cover,
                        width: 120.0,
                        height: 120.0,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          print('Error loading image: $exception');
                          return const Icon(Icons.person, size: 60.0);
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 60.0),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  enabled: isEditingName,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
              ),
              IconButton(
                icon: Icon(isEditingName ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditingName = !isEditingName;
                  });
                  if (!isEditingName) _saveProfile();
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ageController,
                  enabled: isEditingAge,
                  decoration: const InputDecoration(labelText: 'Usia'),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: Icon(isEditingAge ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditingAge = !isEditingAge;
                  });
                  if (!isEditingAge) _saveProfile();
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneNumberController,
                  enabled: isEditingPhoneNumber,
                  decoration: const InputDecoration(labelText: 'Nomer Telepon'),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: Icon(isEditingPhoneNumber ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditingPhoneNumber = !isEditingPhoneNumber;
                  });
                  if (!isEditingPhoneNumber) _saveProfile();
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dobController,
                  enabled: isEditingDob,
                  decoration: const InputDecoration(labelText: 'Tanggal Lahir'),
                  onTap: isEditingDob ? () => _selectDate(context) : null,
                  readOnly: true,
                ),
              ),
              IconButton(
                icon: Icon(isEditingDob ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditingDob = !isEditingDob;
                  });
                  if (!isEditingDob) _saveProfile();
                },
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Simpan Profil'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _selectDate(BuildContext context) async {
  if (!isEditingDob) return;
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
  );

  if (selectedDate != null) {
    dobController.text = "${selectedDate.toLocal()}".split(' ')[0];
  }
}

void _showAlert(String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showSuccessSnackbar(String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

// Clear input fields
void _clearInputFields() {
  nameController.clear();
  ageController.clear();
  dobController.clear();
}

// Function to show alert when profile is not found
void _showProfileNotFoundAlert() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Profile Tidak Ditemukan'),
        content: const Text('Silahkan buat profil Anda terlebih dahulu.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close alert dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
}
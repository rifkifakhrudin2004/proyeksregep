import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:proyeksregep/auth/landing_page.dart';


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
  // Tambahkan metode ini di kelas _ProfilePageState
  String? getLastPhotoUrl() {
    if (_photoUrl.isNotEmpty) {
      return _photoUrl.last; // Mengembalikan URL foto terakhir
    }
    return null; // Jika tidak ada foto
  }
  Future<String?> getUserName() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc['username']; // Asumsi nama field di Firestore adalah 'username'
    }
  }
  return null;
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
    String fileName = 'profile_photos/${_auth.currentUser!.uid}${DateTime.now().millisecondsSinceEpoch}.jpg';
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
Future<void> _saveProfile(BuildContext context) async {
  if (nameController.text.isEmpty || ageController.text.isEmpty || 
      phoneNumberController.text.isEmpty || dobController.text.isEmpty) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: "Data Belum Lengkap",
      desc: "Silakan isi nama, usia, nomor telepon, dan tanggal lahir sebelum menyimpan.",
      btnOkOnPress: () {},
    ).show();
    return;
  }

  try {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference docRef = FirebaseFirestore.instance.collection('profiles').doc(user.uid);

      // Cek apakah dokumen ada
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic> profileData = {
        'name': nameController.text,
        'age': int.tryParse(ageController.text),
        'dateOfBirth': dobController.text,
        'phoneNumber': phoneNumberController.text,
      };

      profileData.removeWhere((key, value) => value == null || value == '');

      if (docSnapshot.exists) {
        // Jika dokumen ada, update dokumen
        await docRef.update(profileData);
      } else {
        // Jika dokumen tidak ada, buat dokumen baru
        await docRef.set(profileData);
      }
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Profil Tersimpan",
      desc: "Profil Anda berhasil disimpan.",
      btnOkOnPress: () {},
    ).show();
  } catch (e) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: "Simpan Gagal",
      desc: "Gagal menyimpan profil: ${e.toString()}",
      btnOkOnPress: () {},
    ).show();
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
      title: const Text('Profile',
        style: TextStyle(
          fontFamily:'Roboto',
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(136, 14, 79, 1),
        ),
      ),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: const Color.fromRGBO(136, 14, 79, 1),
        onPressed: () {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        },
      ),
      backgroundColor:  Color.fromRGBO(248, 187, 208, 1), // Ganti dengan warna yang diinginkan
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _showPhotoPreview,
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: _photoUrl.isEmpty ? 
              const Color.fromRGBO(252, 228, 236, 1) : null,
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
                  : const Icon(Icons.person, size: 60.0,color:Color.fromRGBO(136, 14, 79, 1) ),
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
                },
              ),
            ],
          ),
         SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(240, 98, 146, 1), // Button background color
                foregroundColor:  Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(vertical: 16), // Padding inside the button
                elevation: 8, // Shadow effect
              ),
              child: Text(
                "Simpan Profil",
                style: TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Ganti warna sesuai keinginan
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                ),
              ),
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
// Fungsi _logout
void _logout() async {
  await FirebaseAuth.instance.signOut();
  // Setelah logout, arahkan ke halaman login
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LandingPage()), // Pastikan LoginPage sudah ada
  );
}
}
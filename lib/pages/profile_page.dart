import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';
import 'about_us_page.dart'; // Add this import at the top of your file


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

  List<String> _photoUrl = [];
  Map<String, bool> _editingFields = {
    'name': false,
    'age': false,
    'dateOfBirth': false,
    'phoneNumber': false
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          setState(() {
            nameController.text = data['name'] ?? '';
            ageController.text = (data['age'] ?? '').toString();
            dobController.text = data['dateOfBirth'] ?? '';
            phoneNumberController.text = data['phoneNumber'] ?? '';
            _photoUrl = List<String>.from(data['photoUrl'] ?? []);
          });
        } else {
          _showProfileNotFoundAlert();
        }
      }
    } catch (e) {
      _showAlert('Error', 'Gagal memuat profil: $e');
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      String fileName =
          'profile_photos/${_auth.currentUser!.uid}${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(File(image.path));
      String photoUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_auth.currentUser!.uid)
          .update({
        'photoUrl': [photoUrl]
      });

      setState(() {
        _photoUrl = [photoUrl];
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog before logging out
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: "Konfirmasi Logout",
        desc: "Apakah Anda yakin ingin keluar dari akun?",
        btnCancelOnPress: () {},
        btnOkText: "Logout",
        btnOkColor: Colors.pink[700],
        btnOkOnPress: () async {
          // Perform logout
          await _auth.signOut();

          // Navigate to login page and remove all previous routes
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      ).show();
    } catch (e) {
      _showAlert('Logout Error', 'Gagal logout: $e');
    }
  }

 void _showAboutUs() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AboutUsPage()), 
  );
}


  Future<void> _saveProfile(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Data Belum Lengkap",
        desc: "Silakan isi semua data profil sebelum menyimpan.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('profiles').doc(user.uid);

        DocumentSnapshot docSnapshot = await docRef.get();
        Map<String, dynamic> profileData = {
          'name': nameController.text.trim(),
          'age': int.tryParse(ageController.text.trim()),
          'dateOfBirth': dobController.text.trim(),
          'phoneNumber': phoneNumberController.text.trim(),
        };

        profileData.removeWhere((key, value) => value == null || value == '');

        if (docSnapshot.exists) {
          await docRef.update(profileData);
        } else {
          await docRef.set(profileData);
        }

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: "Profil Tersimpan",
          desc: "Profil Anda berhasil disimpan.",
          btnOkOnPress: () {},
        ).show();
      }
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

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileNotFoundAlert() {
    _showAlert(
        "Profil Tidak Ditemukan", "Data profil Anda belum ada di sistem.");
  }

  void _editField(TextEditingController controller, String fieldKey) async {
    String newValue =
        controller.text.trim(); // Pastikan data tidak kosong atau berisi spasi
    if (newValue.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Edit Gagal",
        desc: "$fieldKey tidak boleh kosong.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .update({fieldKey: newValue}); // Update field di Firestore
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: "Edit Berhasil",
          desc: "$fieldKey berhasil diperbarui.",
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Edit Gagal",
        desc: "Gagal memperbarui $fieldKey: $e",
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _showPhotoOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Kelola Foto Profil',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(136, 14, 79, 1),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_photoUrl.isNotEmpty) ...[
                ListTile(
                  leading: Icon(Icons.delete,
                      color: const Color.fromRGBO(136, 14, 79, 1)),
                  title: Text('Hapus Foto'),
                  onTap: () {
                    _deleteProfilePhoto();
                    Navigator.of(context).pop();
                  },
                ),
              ],
              ListTile(
                leading: Icon(Icons.photo_library,
                    color: Color.fromRGBO(136, 14, 79, 1)),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: Color.fromRGBO(136, 14, 79, 1)),
                title: Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteProfilePhoto() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .update({'photoUrl': []});

        setState(() {
          _photoUrl = [];
        });

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "Foto Profil Dihapus",
          desc: "Foto profil Anda berhasil dihapus.",
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Gagal Menghapus Foto",
        desc: "Terjadi kesalahan: $e",
        btnOkOnPress: () {},
      ).show();
    }
  }

  void _showCameraGuide() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Panduan Pemakaian Kamera',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(136, 14, 79, 1),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: InteractiveViewer(
                  maxScale: 4.0,
                  minScale: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/panduan.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/camera');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mulai Kamera',
                  style: TextStyle(
                    color: Color.fromRGBO(136, 14, 79, 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

 Widget _buildProfileCard({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String fieldKey,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Color.fromRGBO(252, 228, 236, 1),
        child: Icon(icon, color: Color.fromRGBO(136, 14, 79, 1)),
      ),
      title: fieldKey == 'dateOfBirth'
          ? _editingFields[fieldKey] == true
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: label,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color.fromRGBO(136, 14, 79, 1),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        controller.text = "${pickedDate.day.toString().padLeft(2, '0')}/"
                            "${pickedDate.month.toString().padLeft(2, '0')}/"
                            "${pickedDate.year}";
                      });
                    }
                  },
                )
              : GestureDetector(
                  onTap: () {}, // Tetap bisa di-tap meskipun tidak dalam mode edit
                  child: Text(
                    controller.text.isEmpty 
                        ? 'Pilih Tanggal Lahir' 
                        : controller.text,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(136, 14, 79, 1),
                    ),
                  ),
                )
          : _editingFields[fieldKey] == true
              ? TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: label,
                  ),
                )
              : Text(
                  controller.text,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(136, 14, 79, 1),
                  ),
                ),
      trailing: IconButton(
        icon: Icon(
          _editingFields[fieldKey] == true ? Icons.check : Icons.edit,
          color: Color.fromRGBO(136, 14, 79, 1),
        ),
        onPressed: () {
          setState(() {
            _editingFields[fieldKey] = !_editingFields[fieldKey]!;
          });
          if (!_editingFields[fieldKey]!) {
            // Simpan perubahan jika diperlukan
            controller.text = controller.text;
          }
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 248, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert,
                color: Color.fromRGBO(136, 14, 79, 1)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.pink[700]),
                    const SizedBox(width: 10),
                    const Text("Tentang Kami"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.pink[700]),
                    const SizedBox(width: 10),
                    const Text("Logout"),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                _showAboutUs();
              } else if (value == 2) {
                _logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _showPhotoOptionsDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70.0,
                      backgroundColor: _photoUrl.isEmpty
                          ? const Color.fromRGBO(136, 14, 79, 1)
                          : Colors.transparent,
                      child: _photoUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _photoUrl.first,
                                fit: BoxFit.cover,
                                width: 140.0,
                                height: 140.0,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 70.0,
                              color: Color.fromRGBO(252, 228, 236, 1),
                            ),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Color.fromRGBO(252, 228, 236, 1),
                        radius: 20,
                        child: Icon(Icons.camera_alt,
                            color: Color.fromRGBO(136, 14, 79, 1), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              _buildProfileCard(
                controller: nameController,
                label: 'Nama',
                icon: Icons.person_outline,
                fieldKey: 'name',
              ),
              _buildProfileCard(
                controller: ageController,
                label: 'Usia',
                icon: Icons.cake_outlined,
                fieldKey: 'age',
              ),
              _buildProfileCard(
                controller: dobController,
                label: 'Tanggal Lahir',
                icon: Icons.calendar_today_outlined,
                fieldKey: 'dateOfBirth',
              ),
              _buildProfileCard(
                controller: phoneNumberController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                fieldKey: 'phoneNumber',
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 15.0),
                ),
                child: const Text(
                  'Simpan Profil',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(136, 14, 79, 1),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCameraGuide,
        backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

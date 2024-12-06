import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  List<String> _photoUrl = [];
  bool isEditingName = false;
  bool isEditingAge = false;
  bool isEditingDob = false;
  bool isEditingPhoneNumber = false;
  bool isEditingAddress = false;
  bool isEditingEmail = false;

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
            addressController.text = data['address'] ?? '';
            emailController.text = data['email'] ?? '';
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
        btnOkText: "Ya, Logout",
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
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: "Tentang Kami",
      desc: "Aplikasi ini dikembangkan untuk membantu pengguna dalam aktivitas sehari-hari. "
             "Kami berkomitmen untuk memberikan pengalaman terbaik dan solusi yang inovatif.",
      btnOkOnPress: () {},
      btnOkText: "Tutup",
    ).show();
  }


  Future<void> _saveProfile(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        dobController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
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
          'address': addressController.text.trim(),
          'email': emailController.text.trim(),
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
  String newValue = controller.text.trim();  // Pastikan data tidak kosong atau berisi spasi
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
          .update({fieldKey: newValue});  // Update field di Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(136, 14, 79, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromRGBO(252, 228, 236, 1),//profile
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.pink[700]),
                    SizedBox(width: 10),
                    Text("Tentang Kami"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.pink[700]),
                    SizedBox(width: 10),
                    Text("Logout"),
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
                onTap: () async {
                  await _pickAndUploadImage(ImageSource.gallery);
                },
                child: CircleAvatar(
                  radius: 70.0,
                  backgroundColor:
                      _photoUrl.isEmpty ? Color.fromRGBO(136, 14, 79, 1) : Colors.transparent,
                  child: _photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _photoUrl.first,
                            fit: BoxFit.cover,
                            width: 140.0,
                            height: 140.0,
                          ),
                        )
                      : Icon(Icons.person, size: 70.0, color: const Color.fromRGBO(252, 228, 236, 1)),
                ),
              ),
              const SizedBox(height: 20.0),
              _buildProfileField(
                controller: nameController,
                label: 'Nama',
                icon: Icons.person_outline,
                isEditing: isEditingName,
                onEditPressed: () {
                  setState(() {
                    isEditingName = !isEditingName;
                  });
                  if (!isEditingName) {
                    _editField(nameController, 'name');
                  }
                },
              ),
              const SizedBox(height: 10.0),
              _buildProfileField(
                controller: ageController,
                label: 'Usia',
                icon: Icons.cake_outlined,
                isEditing: isEditingAge,
                onEditPressed: () {
                  setState(() {
                    isEditingAge = !isEditingAge;
                  });
                  if (!isEditingAge) {
                    _editField(ageController, 'age');
                  }
                },
              ),
              const SizedBox(height: 10.0),
              _buildProfileField(
                controller: dobController,
                label: 'Tanggal Lahir',
                icon: Icons.calendar_today_outlined,
                isEditing: isEditingDob,
                onEditPressed: () {
                  setState(() {
                    isEditingDob = !isEditingDob;
                  });
                  if (!isEditingDob) {
                    _editField(dobController, 'dateOfBirth');
                  }
                },
              ),
              const SizedBox(height: 10.0),
              _buildProfileField(
                controller: phoneNumberController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                isEditing: isEditingPhoneNumber,
                onEditPressed: () {
                  setState(() {
                    isEditingPhoneNumber = !isEditingPhoneNumber;
                  });
                  if (!isEditingPhoneNumber) {
                    _editField(phoneNumberController, 'phoneNumber');
                  }
                },
              ),
              const SizedBox(height: 10.0),
              _buildProfileField(
                controller: addressController,
                label: 'Alamat',
                icon: Icons.home_outlined,
                isEditing: isEditingAddress,
                onEditPressed: () {
                  setState(() {
                    isEditingAddress = !isEditingAddress;
                  });
                  if (!isEditingAddress) {
                    _editField(addressController, 'address');
                  }
                },
              ),
              const SizedBox(height: 10.0),
              _buildProfileField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                isEditing: isEditingEmail,
                onEditPressed: () {
                  setState(() {
                    isEditingEmail = !isEditingEmail;
                  });
                  if (!isEditingEmail) {
                    _editField(emailController, 'email');
                  }
                },
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
                child: Text(
                  'Simpan Profil',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(136, 14, 79, 1),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
        child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEditPressed,
  }) {
    return TextField(
      controller: controller,
      enabled: isEditing, // Enable editing if isEditing is true
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: onEditPressed, // Handle save or edit logic
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

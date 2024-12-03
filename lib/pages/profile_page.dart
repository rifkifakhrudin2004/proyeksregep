import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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

  Future<void> _saveProfile(BuildContext context) async {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        dobController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Data Belum Lengkap",
        desc:
            "Silakan isi nama, usia, nomor telepon, dan tanggal lahir sebelum menyimpan.",
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
          'name': nameController.text,
          'age': int.tryParse(ageController.text),
          'dateOfBirth': dobController.text,
          'phoneNumber': phoneNumberController.text,
        };

        profileData.removeWhere((key, value) => value == null || value == '');

        if (docSnapshot.exists) {
          await docRef.update(profileData);
        } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.pink[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _showPhotoPreview,
                child: CircleAvatar(
                  radius: 70.0,
                  backgroundColor: _photoUrl.isEmpty
                      ? Colors.pink[100]
                      : Colors.transparent,
                  child: _photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _photoUrl.first,
                            fit: BoxFit.cover,
                            width: 140.0,
                            height: 140.0,
                            errorBuilder: (context, exception, stackTrace) {
                              return Icon(Icons.person,
                                  size: 70.0, color: Colors.pink[700]);
                            },
                          ),
                        )
                      : Icon(Icons.person,
                          size: 70.0, color: Colors.pink[700]),
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
                },
              ),
              _buildProfileField(
                controller: ageController,
                label: 'Usia',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                isEditing: isEditingAge,
                onEditPressed: () {
                  setState(() {
                    isEditingAge = !isEditingAge;
                  });
                },
              ),
              _buildProfileField(
                controller: phoneNumberController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isEditing: isEditingPhoneNumber,
                onEditPressed: () {
                  setState(() {
                    isEditingPhoneNumber = !isEditingPhoneNumber;
                  });
                },
              ),
              _buildProfileField(
                controller: dobController,
                label: 'Tanggal Lahir',
                icon: Icons.calendar_today_outlined,
                isEditing: isEditingDob,
                onTap: isEditingDob ? () => _selectDate(context) : null,
                readOnly: true,
                onEditPressed: () {
                  setState(() {
                    isEditingDob = !isEditingDob;
                  });
                },
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[700]!, Colors.pink[500]!],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    "Simpan Profil",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEditPressed,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: Colors.pink[700],
            ),
            onPressed: onEditPressed,
          ),
          border: OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      dobController.text =
          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    }
  }

  void _showAlert(String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showPhotoPreview() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: Column(
        children: [
          const SizedBox(height: 10),
          ClipOval(
            child: Image.network(
              _photoUrl.isNotEmpty ? _photoUrl.first : '',
              errorBuilder: (context, exception, stackTrace) {
                return Icon(Icons.person, size: 70, color: Colors.pink[700]);
              },
              fit: BoxFit.cover,
              width: 140.0,
              height: 140.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _pickAndUploadImage(ImageSource.camera),
                child: const Text("Kamera"),
              ),
              ElevatedButton(
                onPressed: () => _pickAndUploadImage(ImageSource.gallery),
                child: const Text("Galeri"),
              ),
            ],
          ),
        ],
      ),
    ).show();
  }

  void _showProfileNotFoundAlert() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: "Profil Tidak Ditemukan",
      desc: "Data profil Anda belum tersedia. Silakan lengkapi profil.",
      btnOkOnPress: () {},
    ).show();
  }
}

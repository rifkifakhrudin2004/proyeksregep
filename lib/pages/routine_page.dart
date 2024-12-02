import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class SkincareRoutineInputPage extends StatefulWidget {
  final SkincareRoutine? routine;
  SkincareRoutineInputPage({this.routine});

  @override
  _SkincareRoutineInputPageState createState() =>
      _SkincareRoutineInputPageState();
}

class _SkincareRoutineInputPageState extends State<SkincareRoutineInputPage> {
  late TextEditingController _noteController;
  late String _selectedCategory;
  late bool _mondayMorning, _mondayNight, _tuesdayMorning, _tuesdayNight;
  late bool _wednesdayMorning, _wednesdayNight, _thursdayMorning, _thursdayNight;
  late bool _fridayMorning, _fridayNight, _saturdayMorning, _saturdayNight;
  late bool _sundayMorning, _sundayNight;
  late String _avatarUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _categories = [
    'Cleansing (Pembersih Wajah)',
    'Toner (Penyegar)',
    'Exfoliator (Pengelupasan)',
    'Serum',
    'Moisturizer (Pelembap)',
    'Sunscreen (Tabir Surya)',
    'Face Mask (Masker Wajah)',
    'Eye Cream (Krim Mata)',
    'Face Oil (Minyak Wajah)',
    'Spot Treatment (Perawatan Titik)',
    'Lip Care (Perawatan Bibir)',
    'Neck Cream (Krim Leher)',
    'Toning Mist (Penyegar Semprot)',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.routine?.note);
    _selectedCategory = widget.routine?.category ?? _categories[0]; // Default to first category
    _mondayMorning = widget.routine?.mondayMorning ?? false;
    _mondayNight = widget.routine?.mondayNight ?? false;
    _tuesdayMorning = widget.routine?.tuesdayMorning ?? false;
    _tuesdayNight = widget.routine?.tuesdayNight ?? false;
    _wednesdayMorning = widget.routine?.wednesdayMorning ?? false;
    _wednesdayNight = widget.routine?.wednesdayNight ?? false;
    _thursdayMorning = widget.routine?.thursdayMorning ?? false;
    _thursdayNight = widget.routine?.thursdayNight ?? false;
    _fridayMorning = widget.routine?.fridayMorning ?? false;
    _fridayNight = widget.routine?.fridayNight ?? false;
    _saturdayMorning = widget.routine?.saturdayMorning ?? false;
    _saturdayNight = widget.routine?.saturdayNight ?? false;
    _sundayMorning = widget.routine?.sundayMorning ?? false;
    _sundayNight = widget.routine?.sundayNight ?? false;
    _avatarUrl = widget.routine?.avatarUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Add Skincare Routine' : 'Edit Routine'),
        backgroundColor: const Color.fromARGB(255, 253, 152, 185), // Pink color for the app bar
      ),
      body: _isLoading
          ? Center(
              child: SpinKitCircle(
                color: const Color.fromARGB(255, 247, 143, 177), // Pink color for the loading spinner
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? Image.file(File(_avatarUrl)).image
                          : NetworkImage('https://www.example.com/default-avatar.jpg')
                              as ImageProvider,
                      child: _avatarUrl.isEmpty ? Icon(Icons.camera_alt, color: Colors.white) : null,
                    ),
                  ),
                  SizedBox(height: 20),

                  DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Day Selection with Time (Checkbox)
                  _buildDaySelection('Monday'),
                  _buildDaySelection('Tuesday'),
                  _buildDaySelection('Wednesday'),
                  _buildDaySelection('Thursday'),
                  _buildDaySelection('Friday'),
                  _buildDaySelection('Saturday'),
                  _buildDaySelection('Sunday'),

                  // Note Input
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),

                  // Save and Cancel Buttons
                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    ElevatedButton(
      onPressed: _saveRoutine,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 253, 152, 185), // Warna tombol seperti sebelumnya
        foregroundColor: Colors.black, // Warna teks tombol menjadi hitam
      ),
      child: Text('Save'),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.pop(context); // Cancel dan kembali
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 253, 152, 185), // Warna tombol seperti sebelumnya
        foregroundColor: Colors.black, // Warna teks tombol menjadi hitam
      ),
      child: Text('Cancel'),
    ),
  ],
),

                ],
              ),
            ),
    );
  }

  // Day selection widget
  Widget _buildDaySelection(String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(day, style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: Row(
              children: [
                Text("Morning"),
                Checkbox(
                  value: _getMorningValue(day),
                  onChanged: (value) {
                    setState(() {
                      _setMorningValue(day, value!);
                    });
                  },
                  activeColor: Colors.green, // Set checkbox color to green
                ),
                Text("Night"),
                Checkbox(
                  value: _getNightValue(day),
                  onChanged: (value) {
                    setState(() {
                      _setNightValue(day, value!);
                    });
                  },
                  activeColor: Colors.green, // Set checkbox color to green
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _getMorningValue(String day) {
    switch (day) {
      case 'Monday': return _mondayMorning;
      case 'Tuesday': return _tuesdayMorning;
      case 'Wednesday': return _wednesdayMorning;
      case 'Thursday': return _thursdayMorning;
      case 'Friday': return _fridayMorning;
      case 'Saturday': return _saturdayMorning;
      case 'Sunday': return _sundayMorning;
      default: return false;
    }
  }

  bool _getNightValue(String day) {
    switch (day) {
      case 'Monday': return _mondayNight;
      case 'Tuesday': return _tuesdayNight;
      case 'Wednesday': return _wednesdayNight;
      case 'Thursday': return _thursdayNight;
      case 'Friday': return _fridayNight;
      case 'Saturday': return _saturdayNight;
      case 'Sunday': return _sundayNight;
      default: return false;
    }
  }

  void _setMorningValue(String day, bool value) {
    switch (day) {
      case 'Monday': _mondayMorning = value; break;
      case 'Tuesday': _tuesdayMorning = value; break;
      case 'Wednesday': _wednesdayMorning = value; break;
      case 'Thursday': _thursdayMorning = value; break;
      case 'Friday': _fridayMorning = value; break;
      case 'Saturday': _saturdayMorning = value; break;
      case 'Sunday': _sundayMorning = value; break;
    }
  }

  void _setNightValue(String day, bool value) {
    switch (day) {
      case 'Monday': _mondayNight = value; break;
      case 'Tuesday': _tuesdayNight = value; break;
      case 'Wednesday': _wednesdayNight = value; break;
      case 'Thursday': _thursdayNight = value; break;
      case 'Friday': _fridayNight = value; break;
      case 'Saturday': _saturdayNight = value; break;
      case 'Sunday': _sundayNight = value; break;
    }
  }
  void _pickAvatar() async {
    // Pick an image from the gallery
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Update avatar URL with the selected file's path
        _avatarUrl = pickedFile.path;
      });
    } else {
      // Handle the case when no image is picked
      print('No image selected');
    }
  }

  // Save the skincare routine
  void _saveRoutine() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

     if (currentUser == null) {
      _showErrorDialog('Please log in to save a routine');
      return;
    }
    if (_selectedCategory.isEmpty) {
      _showErrorDialog('Please select a category');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Firebase Storage if a new image is selected
      String imageUrl = _avatarUrl;
      if (_avatarUrl.isNotEmpty && !_avatarUrl.startsWith('http')) {
        imageUrl = await _uploadImage(_avatarUrl);
      }

      // Prepare routine data
      final updatedRoutine = SkincareRoutine(
        id: widget.routine?.id, 
        userId: currentUser.uid,
        avatarUrl: imageUrl,
        category: _selectedCategory,
        note: _noteController.text,
        mondayMorning: _mondayMorning,
        mondayNight: _mondayNight,
        tuesdayMorning: _tuesdayMorning,
        tuesdayNight: _tuesdayNight,
        wednesdayMorning: _wednesdayMorning,
        wednesdayNight: _wednesdayNight,
        thursdayMorning: _thursdayMorning,
        thursdayNight: _thursdayNight,
        fridayMorning: _fridayMorning,
        fridayNight: _fridayNight,
        saturdayMorning: _saturdayMorning,
        saturdayNight: _saturdayNight,
        sundayMorning: _sundayMorning,
        sundayNight: _sundayNight,
      );

      // Save to Firestore
      // Save to Firestore
      if (widget.routine == null) {
        // New routine
        await _firestore
            .collection('skincare_routines')
            .add(updatedRoutine.toMap());
      } else {
        // Update existing routine
        await _firestore
            .collection('skincare_routines')
            .doc(widget.routine!.id)
            .update(updatedRoutine.toMap());
      }

      // Show success dialog
      _showSuccessDialog('Skincare Routine Saved Successfully');
    } catch (e) {
      // Show error dialog
      _showErrorDialog('Failed to save routine: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    Stream<QuerySnapshot> getUserRoutines() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return _firestore
        .collection('skincare_routines')
        .where('userId', isEqualTo: currentUser?.uid)
        .snapshots();
  }
  }

  // Method to upload image to Firebase Storage
  Future<String> _uploadImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final String fileName =
          'skincare_routine_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a reference to the location you want to store the file
      Reference reference =
          _storage.ref().child('skincare_routine_images/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = reference.putFile(imageFile);

      // Get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Error dialog method
  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  // Success dialog method
  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    )..show();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SkincareRoutineInputPage extends StatefulWidget {
  final SkincareRoutine?
      routine; // Menerima data skincare untuk editing, null jika untuk input baru
  SkincareRoutineInputPage({this.routine});

  @override
  _SkincareRoutineInputPageState createState() =>
      _SkincareRoutineInputPageState();
}

class _SkincareRoutineInputPageState extends State<SkincareRoutineInputPage> {
  late TextEditingController _noteController;
  late String _selectedCategory;
  late bool _mondayMorning, _mondayNight, _tuesdayMorning, _tuesdayNight;
  late bool _wednesdayMorning,
      _wednesdayNight,
      _thursdayMorning,
      _thursdayNight;
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
    _selectedCategory =
        widget.routine?.category ?? _categories[0]; // Default to first category
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
        title: Text(
            widget.routine == null ? 'Add Skincare Routine' : 'Edit Routine'),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarUrl.isNotEmpty
                          ? Image.file(File(_avatarUrl))
                              .image // Use Image.file instead of FileImage
                          : NetworkImage(
                                  'https://www.example.com/default-avatar.jpg')
                              as ImageProvider,
                      child: _avatarUrl.isEmpty ? Icon(Icons.camera_alt) : null,
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
                    decoration: InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),

                  // Save and Cancel Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _saveRoutine,
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cancel and go back
                        },
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(day),
        Checkbox(
          value: day == 'Monday'
              ? _mondayMorning
              : day == 'Tuesday'
                  ? _tuesdayMorning
                  : day == 'Wednesday'
                      ? _wednesdayMorning
                      : day == 'Thursday'
                          ? _thursdayMorning
                          : day == 'Friday'
                              ? _fridayMorning
                              : day == 'Saturday'
                                  ? _saturdayMorning
                                  : day == 'Sunday'
                                      ? _sundayMorning
                                      : false,
          onChanged: (value) {
            setState(() {
              if (day == 'Monday') {
                _mondayMorning = value!;
              } else if (day == 'Tuesday') {
                _tuesdayMorning = value!;
              } else if (day == 'Wednesday') {
                _wednesdayMorning = value!;
              } else if (day == 'Thursday') {
                _thursdayMorning = value!;
              } else if (day == 'Friday') {
                _fridayMorning = value!;
              } else if (day == 'Saturday') {
                _saturdayMorning = value!;
              } else if (day == 'Sunday') {
                _sundayMorning = value!;
              }
            });
          },
        ),
        Text("Morning"),
        Checkbox(
          value: day == 'Monday'
              ? _mondayNight
              : day == 'Tuesday'
                  ? _tuesdayNight
                  : day == 'Wednesday'
                      ? _wednesdayNight
                      : day == 'Thursday'
                          ? _thursdayNight
                          : day == 'Friday'
                              ? _fridayNight
                              : day == 'Saturday'
                                  ? _saturdayNight
                                  : day == 'Sunday'
                                      ? _sundayNight
                                      : false,
          onChanged: (value) {
            setState(() {
              if (day == 'Monday') {
                _mondayNight = value!;
              } else if (day == 'Tuesday') {
                _tuesdayNight = value!;
              } else if (day == 'Wednesday') {
                _wednesdayNight = value!;
              } else if (day == 'Thursday') {
                _thursdayNight = value!;
              } else if (day == 'Friday') {
                _fridayNight = value!;
              } else if (day == 'Saturday') {
                _saturdayNight = value!;
              } else if (day == 'Sunday') {
                _sundayNight = value!;
              }
            });
          },
        ),
        Text("Night"),
      ],
    );
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
    // Validate input
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
        id: widget.routine?.id, // Preserve the existing ID if editing
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

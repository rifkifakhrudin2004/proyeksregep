import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:proyeksregep/models/categories_skincare.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyeksregep/pages/routinelist_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyeksregep/services/categories_service.dart';

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
  late bool _wednesdayMorning,
      _wednesdayNight,
      _thursdayMorning,
      _thursdayNight;
  late bool _fridayMorning, _fridayNight, _saturdayMorning, _saturdayNight;
  late bool _sundayMorning, _sundayNight;
  late String _avatarUrl;
  bool _isLoading = false;
  List<SkincareCategory> _categories = [];
  bool _isLoadingCategories = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _categoryAvatars = {};

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.routine?.note);
    _selectedCategory = widget.routine?.category ?? '';

    // Inisialisasi variabel boolean
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

    _fetchCategories();
  }
  Future<void> _fetchCategories() async {
    try {
      // Use the new CategoryService to fetch categories
      final categories = await CategoryService.fetchCategories();
      
      setState(() {
        _categories = categories;
        _categoryAvatars = CategoryService.extractCategoryAvatars(categories);
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routine == null ? 'Add Skincare Routine' : 'Edit Routine',
          style: TextStyle(
              color: Color.fromRGBO(136, 14, 79, 1),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
        elevation: 0,
      ),
      body: _isLoading || _isLoadingCategories
          ? Center(
              child: SpinKitCircle(
                color: const Color.fromARGB(255, 247, 143, 177),
                size: 50.0,
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Display
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedCategory != null &&
                                _categoryAvatars[_selectedCategory] != null
                            ? NetworkImage(_categoryAvatars[_selectedCategory]!)
                            : null,
                        child: _selectedCategory == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                              )
                            : null,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Category Dropdown with Styling
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory.isEmpty
                                ? 'Select Category'
                                : _selectedCategory,
                            isExpanded: true,
                            hint: Text('Select Category'),
                            style: TextStyle(
                                color: Color.fromRGBO(136, 14, 79, 1),
                                fontSize: 16),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Color.fromRGBO(136, 14, 79, 1)),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                                _avatarUrl = newValue != 'Select Category'
                                    ? _categoryAvatars[newValue] ?? ''
                                    : '';
                              });
                            },
                            items: _categories.map<DropdownMenuItem<String>>(
                                (SkincareCategory category) {
                              return DropdownMenuItem<String>(
                                value: category.categoryName,
                                child: Text(category.categoryName,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Day Selection with improved layout
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Days and Times',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(136, 14, 79, 1)),
                            ),
                            SizedBox(height: 10),
                            _buildDaySelection('Monday'),
                            _buildDaySelection('Tuesday'),
                            _buildDaySelection('Wednesday'),
                            _buildDaySelection('Thursday'),
                            _buildDaySelection('Friday'),
                            _buildDaySelection('Saturday'),
                            _buildDaySelection('Sunday'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Notes Input with improved styling
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle:
                            TextStyle(color: Color.fromRGBO(136, 14, 79, 1)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.pink, width: 2),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),

                    // Save and Cancel Buttons with improved styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveRoutine,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(136, 14, 79, 1),
                              foregroundColor:
                                  const Color.fromRGBO(252, 228, 236, 1),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Save', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(252, 228, 236, 1),
                              foregroundColor:
                                  const Color.fromRGBO(136, 14, 79, 1),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                Text('Cancel', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDaySelection(String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Morning", style: TextStyle(fontSize: 12)),
                SizedBox(
                  width: 30,
                  child: Checkbox(
                    value: _getMorningValue(day),
                    onChanged: (value) {
                      setState(() {
                        _setMorningValue(day, value!);
                      });
                    },
                    activeColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 10),
                Text("Night", style: TextStyle(fontSize: 12)),
                SizedBox(
                  width: 30,
                  child: Checkbox(
                    value: _getNightValue(day),
                    onChanged: (value) {
                      setState(() {
                        _setNightValue(day, value!);
                      });
                    },
                    activeColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
      case 'Monday':
        return _mondayMorning;
      case 'Tuesday':
        return _tuesdayMorning;
      case 'Wednesday':
        return _wednesdayMorning;
      case 'Thursday':
        return _thursdayMorning;
      case 'Friday':
        return _fridayMorning;
      case 'Saturday':
        return _saturdayMorning;
      case 'Sunday':
        return _sundayMorning;
      default:
        return false;
    }
  }

  bool _getNightValue(String day) {
    switch (day) {
      case 'Monday':
        return _mondayNight;
      case 'Tuesday':
        return _tuesdayNight;
      case 'Wednesday':
        return _wednesdayNight;
      case 'Thursday':
        return _thursdayNight;
      case 'Friday':
        return _fridayNight;
      case 'Saturday':
        return _saturdayNight;
      case 'Sunday':
        return _sundayNight;
      default:
        return false;
    }
  }

  void _setMorningValue(String day, bool value) {
    switch (day) {
      case 'Monday':
        _mondayMorning = value;
        break;
      case 'Tuesday':
        _tuesdayMorning = value;
        break;
      case 'Wednesday':
        _wednesdayMorning = value;
        break;
      case 'Thursday':
        _thursdayMorning = value;
        break;
      case 'Friday':
        _fridayMorning = value;
        break;
      case 'Saturday':
        _saturdayMorning = value;
        break;
      case 'Sunday':
        _sundayMorning = value;
        break;
    }
  }

  void _setNightValue(String day, bool value) {
    switch (day) {
      case 'Monday':
        _mondayNight = value;
        break;
      case 'Tuesday':
        _tuesdayNight = value;
        break;
      case 'Wednesday':
        _wednesdayNight = value;
        break;
      case 'Thursday':
        _thursdayNight = value;
        break;
      case 'Friday':
        _fridayNight = value;
        break;
      case 'Saturday':
        _saturdayNight = value;
        break;
      case 'Sunday':
        _sundayNight = value;
        break;
    }
  }

  void _saveRoutine() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showErrorDialog(
          'Silakan login terlebih dahulu untuk menyimpan rutinitas');
      return;
    }
    if (_selectedCategory.isEmpty || _selectedCategory == 'Select Category') {
      _showErrorDialog('Please select a valid category');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedRoutine = SkincareRoutine(
        id: widget.routine?.id,
        userId: currentUser.uid,
        avatarUrl: _categoryAvatars[
            _selectedCategory]!, // Use predefined category avatar
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

      final routinesRef = _firestore.collection('skincare_routines');

      if (widget.routine == null) {
        // Tambah routine baru
        DocumentReference docRef =
            await routinesRef.add(updatedRoutine.toMap());
        updatedRoutine.id =
            docRef.id; // Update ID routine dengan ID dokumen Firebase
      } else {
        // Update routine yang sudah ada
        await routinesRef
            .doc(widget.routine!.id)
            .update(updatedRoutine.toMap());
      }

      _showSuccessDialog('Rutinitas Skincare Berhasil Disimpan');
    } catch (e) {
      _showErrorDialog('Gagal menyimpan rutinitas: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        // Ganti halaman saat ini dengan halaman utama
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SkincareRoutineListPage()),
        );
      },
    )..show();
}
}
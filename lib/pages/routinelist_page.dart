import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'routine_page.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SkincareRoutineListPage extends StatefulWidget {
  @override
  _SkincareRoutineListPageState createState() =>
      _SkincareRoutineListPageState();
}

class _SkincareRoutineListPageState extends State<SkincareRoutineListPage> {
  List<SkincareRoutine> routines = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  void _fetchRoutines() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        routines = [];
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('skincare_routines')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        routines = querySnapshot.docs.map((doc) {
          return SkincareRoutine(
            id: doc.id,
            userId: currentUser.uid,
            avatarUrl: doc['avatarUrl'] ?? '',
            category: doc['category'] ?? '',
            note: doc['note'] ?? '',
            mondayMorning: doc['mondayMorning'] ?? '',
            mondayNight: doc['mondayNight'] ?? '',
            tuesdayMorning: doc['tuesdayMorning'] ?? '',
            tuesdayNight: doc['tuesdayNight'] ?? '',
            wednesdayMorning: doc['wednesdayMorning'] ?? '',
            wednesdayNight: doc['wednesdayNight'] ?? '',
            thursdayMorning: doc['thursdayMorning'] ?? '',
            thursdayNight: doc['thursdayNight'] ?? '',
            fridayMorning: doc['fridayMorning'] ?? '',
            fridayNight: doc['fridayNight'] ?? '',
            saturdayMorning: doc['saturdayMorning'] ?? '',
            saturdayNight: doc['saturdayNight'] ?? '',
            sundayMorning: doc['sundayMorning'] ?? '',
            sundayNight: doc['sundayNight'] ?? '',
          );
        }).toList();
      });
    });
  }

  final Map<String, String> _categoryAvatars = {
    'Cleansing': 'assets/cleansing.png',
    'Toner': 'assets/toner.png',
    'Exfoliator': 'assets/exfoliator.png',
    'Serum': 'assets/serum.png',
    'Moisturizer': 'assets/moisturizer.png',
    'Sunscreen': 'assets/sunscreen.png',
    'Face Mask': 'assets/face_mask.png',
    'Eye Cream': 'assets/eye_cream.png',
    'Face Oil': 'assets/face_oil.png',
    'Spot Treatment': 'assets/spot_treatment.png',
    'Lip Care': 'assets/lip_care.png',
    'Neck Cream': 'assets/neck_cream.png',
    'Toning Mist': 'assets/toning_mist.png',
  };

  void _deleteRoutine(String routineId) async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog('Silakan login terlebih dahulu');
      return;
    }

    await FirebaseFirestore.instance
        .collection('skincare_routines')
        .doc(routineId)
        .delete();

    setState(() {
      routines.removeWhere((routine) => routine.id == routineId);
    });

    _showSuccessDialog('Rutinitas berhasil dihapus');
  } catch (e) {
    _showErrorDialog('Gagal menghapus rutinitas: ${e.toString()}');
  }
}

  // Show dialog when login is required
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('Please log in to add or view skincare routines.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  void _showSuccessDialog(String message) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.rightSlide,
    title: 'Sukses',
    desc: message,
    btnOkOnPress: () {
      // Optional: Add any additional actions you want to perform after dismissing the dialog
      // If you want to navigate to another page, you can do it here
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => SomeOtherPage()),
      // );
    },
  )..show();
}
  void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Build the schedule table for the routine
  Widget _buildScheduleTable(SkincareRoutine routine) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.pink[50]?.withOpacity(0.5),
        border: Border.all(
          color: Colors.pink[100]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1.5), // Time column wider
          1: FlexColumnWidth(1), // Day columns equal
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1),
          6: FlexColumnWidth(1),
          7: FlexColumnWidth(1),
        },
        children: [
          _buildTableHeader(),
          _buildMorningNightRow(
              'Morning',
              routine.mondayMorning,
              routine.tuesdayMorning,
              routine.wednesdayMorning,
              routine.thursdayMorning,
              routine.fridayMorning,
              routine.saturdayMorning,
              routine.sundayMorning),
          _buildMorningNightRow(
              'Night',
              routine.mondayNight,
              routine.tuesdayNight,
              routine.wednesdayNight,
              routine.thursdayNight,
              routine.fridayNight,
              routine.saturdayNight,
              routine.sundayNight),
        ],
        border: TableBorder.all(
          color: Colors.transparent,
          width: 0,
        ),
      ),
    );
  }

// Helper to build table header
  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.pink[100]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _buildHeaderCell('Time'),
        _buildHeaderCell('Mon'),
        _buildHeaderCell('Tue'),
        _buildHeaderCell('Wed'),
        _buildHeaderCell('Thu'),
        _buildHeaderCell('Fri'),
        _buildHeaderCell('Sat'),
        _buildHeaderCell('Sun'),
      ],
    );
  }

// Helper to create header cell with consistent styling
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.pink[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

// Helper to build Morning and Night rows
  TableRow _buildMorningNightRow(
      String timeOfDay,
      bool mondayChecked,
      bool tuesdayChecked,
      bool wednesdayChecked,
      bool thursdayChecked,
      bool fridayChecked,
      bool saturdayChecked,
      bool sundayChecked) {
    return TableRow(
      decoration: BoxDecoration(
        color: timeOfDay == 'Morning'
            ? Colors.white.withOpacity(0.7)
            : Colors.pink[50]?.withOpacity(0.3),
      ),
      children: [
        _buildTimeCell(timeOfDay),
        _buildCheckboxCell(mondayChecked),
        _buildCheckboxCell(tuesdayChecked),
        _buildCheckboxCell(wednesdayChecked),
        _buildCheckboxCell(thursdayChecked),
        _buildCheckboxCell(fridayChecked),
        _buildCheckboxCell(saturdayChecked),
        _buildCheckboxCell(sundayChecked),
      ],
    );
  }

// Helper to create time cell
  Widget _buildTimeCell(String timeOfDay) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        timeOfDay,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.pink[700],
          fontSize: 12,
        ),
      ),
    );
  }

// Helper to build a checkbox for morning and night
  Widget _buildCheckboxCell(bool isChecked) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? Colors.green[700] : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  // Build avatar with improved error handling
  Widget _buildAvatar(String category) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.pink.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(
            _categoryAvatars[category] ?? 'assets/default_avatar.png'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromRGBO(255, 255, 255, 1), // Soft pastel pink background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Skincare Routines',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        backgroundColor:
            const Color.fromRGBO(252, 228, 236, 1), // Soft hot pink
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                _showLoginRequiredDialog();
                return;
              }
              Widget build(BuildContext context) {
                return Scaffold(
                  backgroundColor: Color.fromRGBO(
                      255, 255, 255, 1), // Soft pastel pink background
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      'My Skincare Routines',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(136, 14, 79, 1),
                      ),
                    ),
                    backgroundColor:
                        const Color.fromRGBO(252, 228, 236, 1), // Soft hot pink
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () async {
                          User? currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            _showLoginRequiredDialog();
                            return;
                          }

                          final newRoutine = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SkincareRoutineInputPage(),
                            ),
                          );
                          if (newRoutine != null) {
                            setState(() {
                              routines.add(newRoutine);
                            });
                          }
                        },
                        icon: Icon(Icons.add,
                            color: Color.fromRGBO(136, 14, 79, 1)),
                        tooltip: 'Add Routine',
                      ),
                    ],
                  ),
                  body: routines.isEmpty
                      ? _buildEmptyState()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ListView.builder(
                            itemCount: routines.length,
                            itemBuilder: (context, index) {
                              final routine = routines[index];
                              return _buildRoutineCard(routine);
                            },
                            physics:
                                const BouncingScrollPhysics(), // Smooth scrolling
                          ),
                        ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _showCameraGuide,
                    backgroundColor: const Color.fromRGBO(
                        136, 14, 79, 1), // Slightly darker pink
                    child:
                        Icon(Icons.camera_alt, color: Colors.white, size: 30),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: CustomBottomNavigation(initialIndex: 2),
                );
              }

              final newRoutine = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkincareRoutineInputPage(),
                ),
              );
              if (newRoutine != null) {
                setState(() {
                  routines.add(newRoutine);
                });
              }
            },
            icon: Icon(Icons.add, color: Color.fromRGBO(136, 14, 79, 1)),
            tooltip: 'Add Routine',
          ),
        ],
      ),
      body: routines.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListView.builder(
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return _buildRoutineCard(routine);
                },
                physics: const BouncingScrollPhysics(), // Smooth scrolling
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
              context, '/camera'); // Navigation for camera action
        },
        backgroundColor:
            const Color.fromRGBO(136, 14, 79, 1), // Slightly darker pink
        child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 2),
    );
  }

  // Empty state with more elegant design
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face,
            size: 120,
            color: Colors.pink[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Skincare Routines Yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.pink[800]),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first routine and start tracking\nyour skincare journey',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: Colors.pink[600],
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(SkincareRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(routine.category),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.category,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.pink[800]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routine.note.isNotEmpty
                                ? routine.note
                                : 'No additional notes',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: routine.note.isNotEmpty
                                  ? Colors.pink[600]
                                  : Colors.pink[400]?.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                              fontStyle: routine.note.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildScheduleTable(routine),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.pink[100],
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit Routine',
                  icon: Icon(Icons.edit,
                      color: const Color.fromRGBO(136, 14, 79, 1)),
                  onPressed: () async {
                    final updatedRoutine = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkincareRoutineInputPage(
                          routine: routine,
                        ),
                        fullscreenDialog:
                            true, // This helps prevent data covering
                      ),
                    );
                    if (updatedRoutine != null) {
                      setState(() {
                        int index = routines
                            .indexWhere((r) => r.id == updatedRoutine.id);
                        if (index != -1) {
                          routines[index] = updatedRoutine;
                        }
                      });
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Delete Routine',
                  icon: Icon(Icons.delete,
                      color: const Color.fromRGBO(136, 14, 79, 1)),
                  onPressed: () {
                    // Show a confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Routine'),
                          content: Text(
                              'Are you sure you want to delete this skincare routine?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                _deleteRoutine(routine.id!);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

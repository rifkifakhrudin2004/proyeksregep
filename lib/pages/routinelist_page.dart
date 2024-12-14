import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'routine_page.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:proyeksregep/widgets/panduan.dart';
import 'package:proyeksregep/widgets/routine/emptyroutinelist_widget.dart';
import 'package:proyeksregep/widgets/routine/routinecardlist_widget.dart';
import 'package:proyeksregep/widgets/routine/dialog_widget.dart';

class SkincareRoutineListPage extends StatefulWidget {
  @override
  _SkincareRoutineListPageState createState() =>
      _SkincareRoutineListPageState();
}

class _SkincareRoutineListPageState extends State<SkincareRoutineListPage> {
  List<SkincareRoutine> routines = [];
  late DialogHelper _dialogHelper;

  @override
  void initState() {
    super.initState();
     _dialogHelper = DialogHelper(context);
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
    'Cleansing': 'assets/cleansing.jpg',
    'Toner': 'assets/toner.jpg',
    'Exfoliator': 'assets/exfoliator.jpg',
    'Serum': 'assets/serum.jpg',
    'Moisturizer': 'assets/moisturizer.jpg',
    'Sunscreen': 'assets/sunscreen.jpg',
    'Face Mask': 'assets/face mask.jpg',
    'Eye Cream': 'assets/eye cream.jpg',
    'Face Oil': 'assets/face oil.jpg',
    'Spot Treatment': 'assets/spot treatment.jpg',
    'Neck Cream': 'assets/neck cream.jpg',
    'Toning Mist': 'assets/toning mist.jpg',
  };

  void _deleteRoutine(String routineId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _dialogHelper.showLoginRequiredDialog();
        return;
      }

      await FirebaseFirestore.instance
          .collection('skincare_routines')
          .doc(routineId)
          .delete();

      setState(() {
        routines.removeWhere((routine) => routine.id == routineId);
      });

      _dialogHelper.showSuccessDialog('Rutinitas berhasil dihapus');
    } catch (e) {
      _dialogHelper.showErrorDialog('Gagal menghapus rutinitas: ${e.toString()}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1), // Soft pastel pink
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
                _dialogHelper.showLoginRequiredDialog();
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
            icon: Icon(Icons.add, color: Color.fromRGBO(136, 14, 79, 1)),
            tooltip: 'Add Routine',
          ),
        ],
      ),
      body: routines.isEmpty
          ? SkincareRoutineEmptyState()
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListView.builder(
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return SkincareRoutineCard(
                    routine: routine,
                    onDelete: (routine) {
                      if (routine.id != null) {
                        _deleteRoutine(routine.id!);
                      }
                    },
                    onEdit: (updatedRoutine) {
                      setState(() {
                        int index = routines
                            .indexWhere((r) => r.id == updatedRoutine.id);
                        if (index != -1) {
                          routines[index] = updatedRoutine;
                        }
                      });
                    },
                  );
                },
                physics: const BouncingScrollPhysics(), // Smooth scrolling
              ),
            ),
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CameraGuideHelper(context).showCameraGuide();
        },
        backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

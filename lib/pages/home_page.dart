import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyeksregep/models/article.dart';
import 'profile_page.dart';
import 'package:proyeksregep/widgets/article_widget.dart';
import 'storage_page.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SkincareRoutine> routines = [];
  String? lastPhotoUrl;
  String? userName;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutines() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        routines = [];
      });
      return Future.value();
    }

    return FirebaseFirestore.instance
        .collection('skincare_routines')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((querySnapshot) {
      setState(() {
        routines = querySnapshot.docs.map((doc) {
          return SkincareRoutine(
            id: doc.id,
            userId: currentUser.uid,
            avatarUrl: doc['avatarUrl'] ?? '',
            category: doc['category'],
            note: doc['note'],
            mondayMorning: doc['mondayMorning'],
            mondayNight: doc['mondayNight'],
            tuesdayMorning: doc['tuesdayMorning'],
            tuesdayNight: doc['tuesdayNight'],
            wednesdayMorning: doc['wednesdayMorning'],
            wednesdayNight: doc['wednesdayNight'],
            thursdayMorning: doc['thursdayMorning'],
            thursdayNight: doc['thursdayNight'],
            fridayMorning: doc['fridayMorning'],
            fridayNight: doc['fridayNight'],
            saturdayMorning: doc['saturdayMorning'],
            saturdayNight: doc['saturdayNight'],
            sundayMorning: doc['sundayMorning'],
            sundayNight: doc['sundayNight'],
          );
        }).toList();
      });
    });
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
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(248, 187, 208, 1),
          elevation: 0,
          flexibleSpace: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('profiles')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;
                userName = data != null && data.containsKey('name')
                    ? data['name']
                    : null;
                List<dynamic> photoUrls =
                    data != null && data.containsKey('photoUrl')
                        ? data['photoUrl']
                        : [];
                if (photoUrls.isNotEmpty) {
                  lastPhotoUrl = photoUrls.last;
                }

                return Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 40.0, 8.0, 9.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (lastPhotoUrl != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(lastPhotoUrl!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: lastPhotoUrl != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(lastPhotoUrl!),
                                  foregroundColor: Colors.transparent,
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      const Color.fromRGBO(252, 228, 236, 1),
                                  child: Icon(Icons.person,
                                      size: 40,
                                      color:
                                          const Color.fromRGBO(136, 14, 79, 1)),
                                ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                userName != null && userName!.isNotEmpty
                                    ? 'Halo, $userName!'
                                    : 'Halo!',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(136, 14, 79, 1),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sudah cek kulitmu hari ini?',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: const Color.fromRGBO(136, 14, 79, 1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
      body: routines.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildRoutineCard(routines[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: routines.length,
                    effect: WormEffect(
                      dotColor: Colors.pink[200]!,
                      activeDotColor: Colors.pink[800]!,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 1.0),
        child: FloatingActionButton(
          onPressed: _showCameraGuide,
          backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
          child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 400),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      fontSize: 18,
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
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        _navigateToPage(index);
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index
                  ? const Color.fromRGBO(236, 64, 122, 1)
                  : const Color.fromRGBO(136, 14, 79, 1),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index
                    ? const Color.fromRGBO(236, 64, 122, 1)
                    : const Color.fromRGBO(136, 14, 79, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StoragePage(),
              ));
          break;
        case 2:
          Navigator.pushNamed(context, '/routine');
          break;
        case 3:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }
  }

  Widget _buildAvatar(String avatarUrl) {
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
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : AssetImage('assets/default_avatar.png') as ImageProvider,
        backgroundColor: Colors.pink[50],
        onBackgroundImageError: (_, __) {
          // Fallback to default image if network image fails
        },
      ),
    );
  }

  Widget _buildRoutineCard(SkincareRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 300),
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
                    _buildAvatar(routine.avatarUrl),
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
        ],
      ),
    );
  }
}

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

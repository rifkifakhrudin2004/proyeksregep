import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyeksregep/models/article.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';
import 'package:proyeksregep/services/article_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:proyeksregep/widgets/panduan.dart';
import 'package:proyeksregep/widgets/home/home_appbar.dart';
import 'package:proyeksregep/widgets/home/routinecard_widget.dart';
import 'package:proyeksregep/widgets/home/emptyroutine_widget.dart';
import 'package:proyeksregep/widgets/home/articleDialog_widget.dart';

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
  List<Article> articles = [];
  final ArticleService _articleService = ArticleService();
  bool _isLoading = true;
  late ArticleDialog _articleDialog;

  @override
  void initState() {
    super.initState();
    _articleDialog = ArticleDialog(context);
    _fetchRoutines();
    _fetchArticles();
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

  Future<void> _fetchArticles() async {
    try {
      final fetchedArticles = await _articleService.fetchArticles();
      setState(() {
        articles = fetchedArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load articles: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // Define screenWidth

    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 255, 255, 1),
      appBar: HomeAppBar(screenWidth: screenWidth),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Rutinitas Harian',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(136, 14, 79, 1),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (routines.isNotEmpty)
                    Expanded(
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: routines.length,
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: RoutineCard(
                                  routine: routines[index],
                                  pageController: _pageController,
                                  totalPages: routines.length,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: EmptyRoutineState(),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artikel Skincare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(136, 14, 79, 1),
                    ),
                  ),
                  SizedBox(height: 8),
                  _isLoading
                      ? Center()
                      : Expanded(
                          child: articles.isEmpty
                              ? Center(
                                  child: Text(
                                    'No articles found',
                                    style: TextStyle(
                                      color: Color.fromRGBO(136, 14, 79, 1),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: articles.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _articleDialog.show(articles[index]);
                                      },
                                      child: Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl: articles[index].imageUrl,
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(), // Empty container instead of CircularProgressIndicator
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: FloatingActionButton(
          onPressed: () {
            CameraGuideHelper(context).showCameraGuide();
          },
          backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
          child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 0),
    );
  }
}

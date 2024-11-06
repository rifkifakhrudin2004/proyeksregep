import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyeksregep/models/article.dart';
import 'profile_page.dart';
import 'package:proyeksregep/widgets/article_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> articles = [];
  String? lastPhotoUrl;
  String? userName;
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    // Simulasi pengambilan data artikel
    setState(() {
      articles = [
        Article(
          title: 'Artikel 1',
          imageUrl: 'assets/Olivia.png',
          content: 'Konten artikel 1',
        ),
        Article(
          title: 'Artikel 2',
          imageUrl: 'assets/PenyebabKeriput.png',
          content: 'Konten artikel 2',
        ),
        Article(
          title: 'Artikel 3',
          imageUrl: 'assets/logo.jpg',
          content: 'Konten artikel 3',
        ),
        Article(
          title: 'Artikel 4',
          imageUrl: 'assets/logo.jpg',
          content: 'Konten artikel 4',
        ),
        Article(
          title: 'Artikel 5',
          imageUrl: 'assets/logo.jpg',
          content: 'Konten artikel 5',
        ),
        Article(
          title: 'Artikel 6',
          imageUrl: 'assets/logo.jpg',
          content: 'Konten artikel 6',
        ),
      ];
    });
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
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: ClipOval(
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(lastPhotoUrl!),
                                                fit: BoxFit.cover,
                                              ),
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
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, size: 40, color: Colors.grey),
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
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sudah cek kerutan wajahmu hari ini?',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black54,
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
      body: articles.isEmpty 
           ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (articles.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child: ArticleWidget(article: articles[0]),
                      ),
                    SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 220,
                      ),
                      itemCount: articles.length - 1,
                      itemBuilder: (context, index) {
                        return ArticleWidget(article: articles[index + 1]);
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 1.0), 
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/camera'),
          backgroundColor: const Color.fromRGBO(236, 64, 122, 1),
          child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
bottomNavigationBar: BottomAppBar(
  color: const Color.fromRGBO(248, 187, 208, 1),
  shape: CircularNotchedRectangle(),
  notchMargin: 20,
  child: Container(
    height: 80.0,
    padding: const EdgeInsets.symmetric(horizontal: 0.1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
      children: [
        Expanded(
          child: _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
          ),
        ),
        Expanded(
          child: _buildNavItem(
            icon: Icons.photo_library,
            label: 'Gallery',
            index: 1,
          ),
        ),
        SizedBox(width: 90),
        Expanded(
          child: _buildNavItem(
            icon: Icons.history,
            label: 'History',
            index: 2,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
              Navigator.pushNamed(context, '/profile');
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              alignment: Alignment.center,
              child: lastPhotoUrl != null
                  ? CircleAvatar(
                      radius: 23, 
                      backgroundImage: NetworkImage(lastPhotoUrl!),
                    )
                  : CircleAvatar(
                      radius: 23, 
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 24, color: Colors.grey),
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/storage');
            break;
          case 2:
            Navigator.pushNamed(context, '/history');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: _selectedIndex == index
                    ? const Color.fromRGBO(236, 64, 122, 1)
                    : Colors.black, size: 30),
                    
            if (index != 3) // Hapus label untuk profil
              Text(
                label,
                style: TextStyle(
                  color: _selectedIndex == index
                      ? const Color.fromRGBO(236, 64, 122, 1)
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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
          imageUrl: 'assets/logo.jpg',
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
        // Article(
        //   title: 'Artikel 7',
        //   imageUrl: 'assets/logo.jpg',
        //   content: 'Konten artikel 7',
        // ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 230, 184, 209),
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
                // Cast data to a Map
                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;

                // Check if 'name' and 'photoUrl' fields exist
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
              return Container(); // Fallback if no data
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
                    // First article spans full width
                    if (articles.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child: ArticleWidget(article: articles[0]),
                      ),
                    SizedBox(height: 16),
                    // Remaining articles in two columns
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 220, // Adjust this value to control item height
                      ),
                      itemCount: articles.length - 1, // Exclude the first article
                      itemBuilder: (context, index) {
                        // Add 1 to index since we're skipping the first article
                        return ArticleWidget(article: articles[index + 1]);
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildNavItem(
                icon: Icons.person,
                label: 'Profil',
                onTap: () => _onItemTapped(2),
              ),
            ),
            Expanded(
              child: _buildCameraButton(),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.storage,
                label: 'Galeri',
                onTap: () => _onItemTapped(1),
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/camera');
        break;
      case 1:
        Navigator.pushNamed(context, '/storage');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        _logout();
        break;
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30),
            Text(label, style: TextStyle(color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(0),
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 194, 114, 114),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.add_a_photo, size: 30.0, color: Colors.white),
      ),
    );
  }
}

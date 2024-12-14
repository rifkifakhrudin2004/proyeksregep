import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double screenWidth;

  const HomeAppBar({Key? key, required this.screenWidth}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      elevation: 0,
      flexibleSpace: _buildFlexibleSpace(context),
    );
  }

  Widget _buildFlexibleSpace(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
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
          String? userName = data != null && data.containsKey('name')
              ? data['name']
              : null;
          List<dynamic> photoUrls =
              data != null && data.containsKey('photoUrl')
                  ? data['photoUrl']
                  : [];
          String? lastPhotoUrl = photoUrls.isNotEmpty ? photoUrls.last : null;

          return _buildUserProfileContent(
            context, 
            userName, 
            lastPhotoUrl, 
            screenWidth
          );
        }
        return Container();
      },
    );
  }

  Widget _buildUserProfileContent(
    BuildContext context, 
    String? userName, 
    String? lastPhotoUrl, 
    double screenWidth
  ) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 40.0, 8.0, 9.0),
        child: Row(
          children: [
            _buildUserAvatar(context, lastPhotoUrl),
            SizedBox(width: 10),
            _buildUserGreeting(userName, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, String? lastPhotoUrl) {
    return GestureDetector(
      onTap: () => _showEnlargedProfileImage(context, lastPhotoUrl),
      child: lastPhotoUrl != null
          ? CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(lastPhotoUrl),
              foregroundColor: Colors.transparent,
            )
          : CircleAvatar(
              radius: 40,
              backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
              child: Icon(Icons.person,
                  size: 40, color: const Color.fromRGBO(252, 228, 236, 1)),
            ),
    );
  }

  void _showEnlargedProfileImage(BuildContext context, String? lastPhotoUrl) {
    if (lastPhotoUrl != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(lastPhotoUrl),
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
  }

  Widget _buildUserGreeting(String? userName, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            userName != null && userName.isNotEmpty
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
    );
  }
}
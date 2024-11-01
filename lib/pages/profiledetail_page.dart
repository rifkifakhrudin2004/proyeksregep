// import 'package:flutter/material.dart';
// import 'package:proyeksregep/models/Userprofile.dart'; // Model UserProfile
// import 'editprofile_page.dart'; // Import the EditProfilePage
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for data handling
// import 'home_page.dart'; // Import HomePage for navigation

// class ProfileDetailPage extends StatefulWidget {
//   final UserProfile userProfile;
//   final Function(UserProfile) onEdit; // Function to handle editing
//   final Function() onClear; // Function to handle clearing profile

//   ProfileDetailPage({
//     required this.userProfile,
//     required this.onEdit,
//     required this.onClear,
//   });

//   @override
//   _ProfileDetailPageState createState() => _ProfileDetailPageState();
// }

// class _ProfileDetailPageState extends State<ProfileDetailPage> {
//   // Function to show confirmation dialog
//   void _showDeleteConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Deletion"),
//           content: Text("Are you sure you want to clear this profile?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//               },
//               child: Text("No"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close dialog
//                 widget.onClear(); // Call onClear function if user confirms
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Profile data cleared successfully!")),
//                 );
//               },
//               child: Text("Yes"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to show the larger profile image
//   void _showProfileImage() {
//     showDialog(
//       context: context,
//       barrierDismissible: true, // Allow dismissing by tapping outside
//       builder: (BuildContext context) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(context).pop(); // Close dialog on tap
//           },
//           child: Center(
//             child: ClipOval(
//               child: Image.network(
//                 widget.userProfile.photoUrl?.isNotEmpty ?? false
//                     ? widget.userProfile.photoUrl!
//                     : 'https://via.placeholder.com/300', // Fallback image URL
//                 fit: BoxFit.cover,
//                 height: 300,
//                 width: 300,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Profile Details')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Display profile picture
//             GestureDetector(
//               onTap: _showProfileImage, // Show larger image on tap
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage: (widget.userProfile.photoUrl?.isNotEmpty ?? false)
//                     ? NetworkImage(widget.userProfile.photoUrl!) // Display image from URL
//                     : null,
//                 child: (widget.userProfile.photoUrl?.isEmpty ?? true)
//                     ? Icon(Icons.camera_alt, size: 50) // Default icon when no image
//                     : null,
//               ),
//             ),
//             SizedBox(height: 20),
//             Text("Name: ${widget.userProfile.name}", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             Text("Age: ${widget.userProfile.age}", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             Text("Date of Birth: ${widget.userProfile.dateOfBirth}", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final updatedUserProfile = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditProfilePage(userProfile: widget.userProfile),
//                   ),
//                 );
//                 if (updatedUserProfile != null) {
//                   // Update displayed data using setState
//                   setState(() {
//                     widget.userProfile.name = updatedUserProfile.name;
//                     widget.userProfile.age = updatedUserProfile.age;
//                     widget.userProfile.dateOfBirth = updatedUserProfile.dateOfBirth;
//                     widget.userProfile.photoUrl = updatedUserProfile.photoUrl; // Update photo URL
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Profile updated successfully!")),
//                   );
//                 }
//               },
//               child: Text("Edit Profile"),
//             ),
//             ElevatedButton(
//               onPressed: () => _showDeleteConfirmationDialog(context), // Show confirmation dialog
//               child: Text("Clear Data"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

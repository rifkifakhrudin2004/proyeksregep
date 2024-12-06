import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyeksregep/pages/detailStorage_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyeksregep/widgets/custom_bottom_navigation.dart';

class StoragePage extends StatefulWidget {
  final XFile? imageFile;
  final String predictedClass;
  final String persentase;
  final String handling;
  final String skincare;

  const StoragePage({
    Key? key,
    this.imageFile,
    this.predictedClass = '',
    this.persentase = '',
    this.handling = '',
    this.skincare = '',
  }) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  List<Map<String, dynamic>> storedResults = [];
  final String storageKey = 'skin_analysis_results';

  @override
  void initState() {
    super.initState();
    _loadStoredResults();
  }

  Future<void> _loadStoredResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(storageKey);

    if (storedData != null) {
      final List<dynamic> decodedData = json.decode(storedData);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      setState(() {
        storedResults = decodedData
            .where((item) => item['userId'] == currentUserId) // Filter by userId
            .map((item) {
              if (item['image'] != null) {
                item['image'] = XFile(item['image']);
              }
              return item;
            })
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }

    // Tambahkan hasil baru jika tersedia
    if (widget.imageFile != null) {
      final newResult = {
        'userId': FirebaseAuth.instance.currentUser?.uid, // userId dari akun
        'image': widget.imageFile,
        'prediction': widget.predictedClass,
        'persentase': widget.persentase,
        'handling': widget.handling,
        'skincare': widget.skincare,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        storedResults.add(newResult);
      });
      _saveResults();
    }
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final dataToStore = storedResults.map((item) {
      final Map<String, dynamic> storableItem = Map.from(item);
      if (item['image'] != null) {
        storableItem['image'] = (item['image'] as XFile).path;
      }
      return storableItem;
    }).toList();

    await prefs.setString(storageKey, json.encode(dataToStore));
  }

  void _deleteResult(int index) {
    setState(() {
      storedResults.removeAt(index);
      _saveResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skin Analysis Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromRGBO(248, 187, 208, 0.3),
              const Color.fromRGBO(241, 104, 152, 0.1),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: storedResults.length,
          itemBuilder: (context, index) {
            final result = storedResults[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: result['image'] != null
                          ? DecorationImage(
                              image: FileImage(File(result['image'].path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: result['image'] == null
                        ? const Icon(Icons.image, color: Colors.grey)
                        : null,
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['prediction'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(241, 104, 152, 1),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            result['timestamp'].toString().substring(0, 16),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailStoragePage(result: result),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(241, 104, 152, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () => _deleteResult(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(241, 104, 152, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(initialIndex: 1),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 1.0),
        child: FloatingActionButton(
          onPressed: () {
            // Camera guide or navigation logic
            Navigator.pushNamed(context, '/camera');
          },
          backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
          child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
);
}
}

import 'package:flutter/material.dart';
import 'dart:io';

class DetailStoragePage extends StatelessWidget {
  final Map<String, dynamic> result;

  const DetailStoragePage({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analysis Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
        elevation: 5,
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image display
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: result['image'] != null
                      ? Image.file(
                          File(result['image'].path),
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 100),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Big Box containing the Detail Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(252, 228, 236, 1),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailCard(
                      icon: Icons.medical_information,
                      title: 'Prediction',
                      content: result['prediction'],
                    ),
                    const SizedBox(height: 15),
                    _buildDetailCard(
                      icon: Icons.percent,
                      title: 'Percentage',
                      content: result['persentase'],
                    ),
                    const SizedBox(height: 15),
                    _buildDetailCard(
                      icon: Icons.medical_services,
                      title: 'Handling',
                      content: result['handling'],
                    ),
                    const SizedBox(height: 15),
                    _buildDetailCard(
                      icon: Icons.spa,
                      title: 'Skincare',
                      content: result['skincare'],
                    ),
                    const SizedBox(height: 15),
                    _buildDetailCard(
                      icon: Icons.calendar_today,
                      title: 'Timestamp',
                      content: result['timestamp'].toString().substring(0, 19),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromRGBO(136, 14, 79, 1)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
        ),
        subtitle: Text(
          content,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
 
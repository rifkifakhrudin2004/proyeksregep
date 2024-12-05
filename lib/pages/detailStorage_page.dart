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
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(241, 104, 152, 1),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image display
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
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
                          color: Colors.grey,
                          child: const Icon(Icons.image, size: 100),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Details Card
              _buildDetailCard(
                icon: Icons.medical_information,
                title: 'Prediction',
                content: result['prediction'],
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.percent,
                title: 'Percentage',
                content: result['persentase'],
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.medical_services,
                title: 'Handling',
                content: result['handling'],
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.spa,
                title: 'Skincare',
                content: result['skincare'],
              ),
              const SizedBox(height: 10),
              _buildDetailCard(
                icon: Icons.calendar_today,
                title: 'Timestamp',
                content: result['timestamp'].toString().substring(0, 19),
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
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromRGBO(241, 104, 152, 1)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          content,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
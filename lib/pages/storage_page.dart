import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert'; 
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.persentase ='',
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
      setState(() {
        storedResults = decodedData.map((item) {
          // Konversi path gambar ke XFile
          if (item['image'] != null) {
            item['image'] = XFile(item['image']);
          }
          return item;
        }).cast<Map<String, dynamic>>().toList();
      });
    }

    // Tambahkan data baru jika ada
    if (widget.imageFile != null) {
      final newResult = {
        'image': widget.imageFile,
        'prediction': widget.predictedClass,
        'persentase' : widget.persentase,
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
      // Simpan path gambar saja
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
      _saveResults(); // Simpan perubahan setelah menghapus
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: storedResults.length,
          itemBuilder: (context, index) {
            final result = storedResults[index];
            return Dismissible(
              key: Key(result['timestamp'].toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _deleteResult(index),
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: result['image'] != null
                        ? Image.file(
                            File(result['image'].path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey,
                            child: Icon(Icons.image),
                          ),
                  ),
                  title: Text(
                    result['prediction'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(241, 104, 152, 1),
                    ),
                  ),
                  subtitle: Text(
                    result['timestamp'].toString().substring(0, 16),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Persentase', result['persentase']),
                            const SizedBox(height: 10),
                            _buildDetailRow('Handling', result['handling']),
                            const SizedBox(height: 10),
                            _buildDetailRow('Skincare', result['skincare']),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
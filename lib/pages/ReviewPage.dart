import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyeksregep/pages/storage_page.dart';
import 'package:shimmer/shimmer.dart';


class ReviewPage extends StatefulWidget {
  final XFile imageFile;
  final String? predictedClass;
  final String? persentase;
  final String? handling;
  final String? skincare;
  
 

  const ReviewPage({
    Key? key,
    required this.imageFile,
    this.predictedClass,
    this.persentase,
    this.handling,
    this.skincare,
  }) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    _checkDataReadiness();
  }
  Future<void> _checkDataReadiness() async {
    // Tambahkan pengecekan tambahan jika diperlukan
    await Future.delayed(Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Skin Analysis Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(252, 228, 236, 1),
          ),
        ),
        backgroundColor: Color.fromRGBO(136, 14, 79, 1),
        centerTitle: true,
        elevation: 0,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isLoading
                    ? _buildLoadingSkeleton(context)
                    : _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Skeleton untuk gambar
        Container(
          width: 250,
          height: 250,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Skeleton untuk prediction
        _buildSkeletonSection(),
        const SizedBox(height: 15),

        // Skeleton untuk handling
        _buildSkeletonSection(),
        const SizedBox(height: 15),

        // Skeleton untuk skincare
        _buildSkeletonSection(),
        const SizedBox(height: 25),

        // Skeleton untuk button
        Container(
          width: 150,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 50,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'skin_image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              File(widget.imageFile.path),
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailSection(
          context,
          'Prediction',
          widget.predictedClass ?? 'N/A',
          color: const Color.fromRGBO(241, 104, 152, 1),
        ),
        const SizedBox(height: 15),
        _buildHiddenDetailSection(
            context, 'Persentase', widget.persentase ?? '%'),
        const SizedBox(height: 15),
        _buildHiddenDetailSection(
            context, 'Handling', widget.handling ?? 'N/A'),
        const SizedBox(height: 15),
        _buildHiddenDetailSection(
            context, 'Recommended Skincare', widget.skincare ?? 'N/A'),
        const SizedBox(height: 25),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoragePage(
                  imageFile: widget.imageFile,
                  predictedClass: widget.predictedClass ??'Unknown', 
                  persentase : widget.persentase ?? '%',
                  handling: widget.handling ?? 'No handling information',
                  skincare: widget.skincare ?? 'No skincare recommendation',
                ),
              ),
            );
          },
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(241, 104, 152, 1),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color ?? Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenDetailSection(
    BuildContext context,
    String label,
    String value,
  ) {
    return GestureDetector(
      onTap: () {
        _showFullDetailsDialog(context, label, value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showFullDetailsDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(241, 104, 152, 1),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

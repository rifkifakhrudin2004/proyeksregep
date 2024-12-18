import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageProcessingService {
  static const String _baseUrl = 'http://192.168.0.102:5000/upload';

  static Future<Map<String, dynamic>> sendImageData({
    required String userId, 
    required String imageFilename
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'image_filename': imageFilename,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return _processImageResult(responseData);
      } else {
        throw Exception('Failed to send image data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sendImageData: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _processImageResult(Map<String, dynamic> responseData) {
    final String predictedClass = responseData['prediction']['predicted_class'];
    final String persentase = 
      '${responseData['prediction']['predicted_probability'].toString()}%';

    return _getSkinCareRecommendation(predictedClass, persentase);
  }

  static Map<String, dynamic> _getSkinCareRecommendation(String predictedClass, String persentase) {
    String handling = '';
    String skincare = '';
    double percentage = double.parse(persentase.replaceAll('%', ''));

    switch (predictedClass) {
      case 'dry':
        if (percentage >= 50) {
          handling = 'Kulit kering berat! Gunakan pelembab super intensif';
          skincare = 'Ceramide Cream, Hyaluronic Acid, Barrier Repair Serum';
        } else if (percentage >= 20 && percentage < 50) {
          handling = 'Kulit kering sedang! Gunakan pelembab khusus';
          skincare = 'Rich Moisturizer, Niacinamide Serum';
        } else {
          handling = 'Kulit kering ringan! Gunakan pelembab ringan';
          skincare = 'Hydrating Lotion, Gentle Moisturizer';
        }
        break;
      case 'oily':
        if (percentage >= 50) {
          handling = 'Kulit sangat berminyak! Kontrol produksi sebum';
          skincare = 'Salicylic Acid Cleanser, Oil-free Mattifying Moisturizer';
        } else if (percentage >= 20 && percentage < 50) {
          handling = 'Kulit berminyak sedang! Gunakan produk pembersih khusus';
          skincare = 'Gentle Foaming Cleanser, Lightweight Gel Moisturizer';
        } else {
          handling = 'Kulit berminyak ringan! Gunakan produk kontrol minyak';
          skincare = 'Mild Cleanser, Water-based Moisturizer';
        }
        break;
      case 'normal':
        handling = 'Kulit normal! Gunakan produk seimbang';
        skincare = 'Gentle Cleanser, Hydrating Lotion';
        break;
      default:
        handling = 'Tidak dapat mengenali jenis kulit';
        skincare = 'Konsultasikan dengan ahli kecantikan';
    }
    return {
      'predictedClass': predictedClass,
      'persentase': persentase,
      'handling': handling,
      'skincare': skincare
    };
  }
}
class ImageData {
  int? id;
  String imagePath;
  String usia;
  String jenisKulit;
  String kandungan;

  ImageData({
    this.id,
    required this.imagePath,
    required this.usia,
    required this.jenisKulit,
    required this.kandungan,
  });

  // Convert object to Map to store in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'usia': usia,
      'jenisKulit': jenisKulit,
      'kandungan': kandungan,
    };
  }

  // Convert Map back to object
  static ImageData fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'],
      imagePath: map['imagePath'],
      usia: map['usia'],
      jenisKulit: map['jenisKulit'],
      kandungan: map['kandungan'],
    );
  }
}
class SkincareRoutine {
  String? id;
  final String userId;
  final String avatarUrl;
  final String category;
  final String note;
  final bool mondayMorning;
  final bool mondayNight;
  final bool tuesdayMorning;
  final bool tuesdayNight;
  final bool wednesdayMorning;
  final bool wednesdayNight;
  final bool thursdayMorning;
  final bool thursdayNight;
  final bool fridayMorning;
  final bool fridayNight;
  final bool saturdayMorning;
  final bool saturdayNight;
  final bool sundayMorning;
  final bool sundayNight;

  SkincareRoutine({
    this.id,
    required this.userId,
    required this.avatarUrl,
    required this.category,
    required this.note,
    required this.mondayMorning,
    required this.mondayNight,
    required this.tuesdayMorning,
    required this.tuesdayNight,
    required this.wednesdayMorning,
    required this.wednesdayNight,
    required this.thursdayMorning,
    required this.thursdayNight,
    required this.fridayMorning,
    required this.fridayNight,
    required this.saturdayMorning,
    required this.saturdayNight,
    required this.sundayMorning,
    required this.sundayNight,
  });
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'avatarUrl': avatarUrl,
      'category': category,
      'note': note,
      'mondayMorning': mondayMorning,
      'mondayNight': mondayNight,
      'tuesdayMorning': tuesdayMorning,
      'tuesdayNight': tuesdayNight,
      'wednesdayMorning': wednesdayMorning,
      'wednesdayNight': wednesdayNight,
      'thursdayMorning': thursdayMorning,
      'thursdayNight': thursdayNight,
      'fridayMorning': fridayMorning,
      'fridayNight': fridayNight,
      'saturdayMorning': saturdayMorning,
      'saturdayNight': saturdayNight,
      'sundayMorning': sundayMorning,
      'sundayNight': sundayNight,
    };
}
}

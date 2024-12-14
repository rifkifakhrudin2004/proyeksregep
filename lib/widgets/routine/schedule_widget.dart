import 'package:flutter/material.dart';
import 'package:proyeksregep/models/skincare_model.dart';

class ScheduleTableWidget extends StatelessWidget {
  final SkincareRoutine routine;

  const ScheduleTableWidget({Key? key, required this.routine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.pink[50]?.withOpacity(0.5),
        border: Border.all(
          color: Colors.pink[100]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1.6), // Time column wider
          1: FlexColumnWidth(1), // Day columns equal
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1),
          6: FlexColumnWidth(1),
          7: FlexColumnWidth(1),
        },
        children: [
          _buildTableHeader(),
          _buildMorningNightRow(
              'Morning',
              routine.mondayMorning,
              routine.tuesdayMorning,
              routine.wednesdayMorning,
              routine.thursdayMorning,
              routine.fridayMorning,
              routine.saturdayMorning,
              routine.sundayMorning),
          _buildMorningNightRow(
              'Night',
              routine.mondayNight,
              routine.tuesdayNight,
              routine.wednesdayNight,
              routine.thursdayNight,
              routine.fridayNight,
              routine.saturdayNight,
              routine.sundayNight),
        ],
        border: TableBorder.all(
          color: Colors.transparent,
          width: 0,
        ),
      ),
    );
  }

  // Helper to build table header
  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.pink[100]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _buildHeaderCell('Time'),
        _buildHeaderCell('Mon'),
        _buildHeaderCell('Tue'),
        _buildHeaderCell('Wed'),
        _buildHeaderCell('Thu'),
        _buildHeaderCell('Fri'),
        _buildHeaderCell('Sat'),
        _buildHeaderCell('Sun'),
      ],
    );
  }

  // Helper to create header cell with consistent styling
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.pink[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper to build Morning and Night rows
  TableRow _buildMorningNightRow(
      String timeOfDay,
      bool mondayChecked,
      bool tuesdayChecked,
      bool wednesdayChecked,
      bool thursdayChecked,
      bool fridayChecked,
      bool saturdayChecked,
      bool sundayChecked) {
    return TableRow(
      decoration: BoxDecoration(
        color: timeOfDay == 'Morning'
            ? Colors.white.withOpacity(0.7)
            : Colors.pink[50]?.withOpacity(0.3),
      ),
      children: [
        _buildTimeCell(timeOfDay),
        _buildCheckboxCell(mondayChecked),
        _buildCheckboxCell(tuesdayChecked),
        _buildCheckboxCell(wednesdayChecked),
        _buildCheckboxCell(thursdayChecked),
        _buildCheckboxCell(fridayChecked),
        _buildCheckboxCell(saturdayChecked),
        _buildCheckboxCell(sundayChecked),
      ],
    );
  }

  // Helper to create time cell
  Widget _buildTimeCell(String timeOfDay) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        timeOfDay,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.pink[700],
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper to build a checkbox for morning and night
  Widget _buildCheckboxCell(bool isChecked) {
    return Center(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? Colors.green[700] : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }
}
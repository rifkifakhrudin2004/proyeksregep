import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:proyeksregep/widgets/routine/avatar_widget.dart';
import 'package:proyeksregep/widgets/routine/schedule_widget.dart';

class RoutineCard extends StatelessWidget {
  final SkincareRoutine routine;
  final PageController pageController;
  final int totalPages;

  const RoutineCard({
    Key? key, 
    required this.routine, 
    required this.pageController,
    required this.totalPages
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(252, 228, 236, 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(136, 14, 79, 1).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomAvatar(avatarUrl: routine.avatarUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.category,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.pink[800]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routine.note.isNotEmpty
                                ? routine.note
                                : 'No additional notes',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: routine.note.isNotEmpty
                                  ? Colors.pink[600]
                                  : Colors.pink[400]?.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                              fontStyle: routine.note.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 0.8),
                ScheduleTableWidget(routine: routine),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SmoothPageIndicator(
              controller: pageController,
              count: totalPages,
              effect: ExpandingDotsEffect(
                dotHeight: 4.0,
                dotWidth: 4.0,
                spacing: 4.0,
                activeDotColor: Color.fromRGBO(136, 14, 79, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
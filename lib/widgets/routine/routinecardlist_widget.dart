import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:proyeksregep/models/skincare_model.dart';
import 'package:proyeksregep/widgets/routine/avatar_widget.dart';
import 'package:proyeksregep/widgets/routine/schedule_widget.dart';
import 'package:proyeksregep/pages/routine_page.dart';

class SkincareRoutineCard extends StatelessWidget {
  final SkincareRoutine routine;
  final Function(SkincareRoutine) onDelete;
  final Function(SkincareRoutine) onEdit;

  const SkincareRoutineCard({
    Key? key,
    required this.routine,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  void _showSuccessDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Sukses',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(136, 14, 79, 1).withOpacity(0.1),
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
                const SizedBox(height: 16),
                ScheduleTableWidget(routine: routine),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.pink[100],
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Edit Routine',
                  icon: Icon(Icons.edit,
                      color: const Color.fromRGBO(136, 14, 79, 1)),
                  onPressed: () async {
                    final updatedRoutine = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkincareRoutineInputPage(
                          routine: routine,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                    if (updatedRoutine != null) {
                      onEdit(updatedRoutine);
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Delete Routine',
                  icon: Icon(Icons.delete,
                      color: const Color.fromRGBO(136, 14, 79, 1)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Routine'),
                          content: Text(
                              'Are you sure you want to delete this skincare routine?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                onDelete(routine);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
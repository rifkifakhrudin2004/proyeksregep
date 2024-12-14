import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String fieldKey;
  final bool isDateField;
  final Function(bool) onEditToggle;
  final VoidCallback? onSave;

  const ProfileCard({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.fieldKey,
    this.isDateField = false,
    required this.onEditToggle,
    this.onSave,
  }) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Color.fromRGBO(252, 228, 236, 1),
          child: Icon(widget.icon, color: Color.fromRGBO(136, 14, 79, 1)),
        ),
        title: widget.isDateField
            ? _isEditing
                ? TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: widget.label,
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color.fromRGBO(136, 14, 79, 1),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        setState(() {
                          widget.controller.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/"
                              "${pickedDate.month.toString().padLeft(2, '0')}/"
                              "${pickedDate.year}";
                        });
                      }
                    },
                  )
                : GestureDetector(
                    onTap: () {},
                    child: Text(
                      widget.controller.text.isEmpty
                          ? 'Pilih Tanggal Lahir'
                          : widget.controller.text,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(136, 14, 79, 1),
                      ),
                    ),
                  )
            : _isEditing
                ? TextField(
                    controller: widget.controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: widget.label,
                    ),
                  )
                : Text(
                    widget.controller.text,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(136, 14, 79, 1),
                    ),
                  ),
        trailing: IconButton(
          icon: Icon(
            _isEditing ? Icons.check : Icons.edit,
            color: Color.fromRGBO(136, 14, 79, 1),
          ),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
            widget.onEditToggle(_isEditing);
            if (!_isEditing && widget.onSave != null) {
              widget.onSave!();
            }
          },
        ),
      ),
    );
  }
}
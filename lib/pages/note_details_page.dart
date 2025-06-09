import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:note_keeper/models/note_model.dart';
import 'package:note_keeper/utils/database_helper.dart';

class NoteDetailsPage extends StatefulWidget {
  NoteDetailsPage({
    super.key,
    required this.pageTitle,
    required this.noteModel,
  });
  String pageTitle;
  NoteModel noteModel;

  @override
  State<NoteDetailsPage> createState() => _NoteDetailsPageState();
}

class _NoteDetailsPageState extends State<NoteDetailsPage> {
  TextEditingController noteTitleController = TextEditingController();
  TextEditingController noteDescriptionController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    List<String> _priorities = ["High", "Low"];

    void changePriorityIntoInt(String value) {
      switch (value) {
        case "High":
          widget.noteModel.priority = 1;
          break;
        case "Low":
          widget.noteModel.priority = 2;
          break;
      }
    }

    String changePriorityIntoString(int value) {
      String priority;
      switch (value) {
        case 1:
          priority = _priorities[0];
          break;
        case 2:
          priority = _priorities[1];
          break;
        default:
          priority = _priorities[1];
      }
      return priority;
    }

    void _showSnackBar(String msg, Color clr) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: clr));
    }

    void _goBackScreen() {
      Navigator.pop(context, true);
    }

    void saveNote() async {
      if (_formkey.currentState!.validate()) {
        int result;
        if (widget.noteModel.id != null) {
          result = await databaseHelper.updataNote(widget.noteModel);
        } else {
          result = await databaseHelper.insertNote(widget.noteModel);
        }
        if (result != 0) {
          _goBackScreen();
          _showSnackBar("Note successfully updated", Colors.green);
        }
      }
    }

    void clearNote() {
      noteTitleController.clear();
      noteDescriptionController.clear();
    }

    void updateTitle() {
      widget.noteModel.title = noteTitleController.text;
    }

    void updateDescription() {
      widget.noteModel.description = noteDescriptionController.text;
    }

    noteTitleController.text = widget.noteModel.title;
    noteDescriptionController.text = widget.noteModel.description!;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.pageTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Form(
        key: _formkey,
        child: Column(
          children: [
            ListTile(
              title: DropdownButton(
                items:
                    _priorities.map((dropDownPriotiy) {
                      return DropdownMenuItem(
                        value: dropDownPriotiy,
                        child: Text(dropDownPriotiy),
                      );
                    }).toList(),
                value: changePriorityIntoString(widget.noteModel.priority),
                onChanged: (value) {
                  setState(() {
                    log("drop down selected item is $value");
                    changePriorityIntoInt(value!);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  } else {
                    return null;
                  }
                },
                controller: noteTitleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  updateTitle();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                minLines: 5,
                maxLines: 45,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description";
                  } else {
                    return null;
                  }
                },
                controller: noteDescriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  updateDescription();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        saveNote();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        clearNote();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

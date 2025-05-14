import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:note_keeper/models/note_model.dart';
import 'package:note_keeper/pages/note_add_page.dart';
import 'package:note_keeper/pages/note_details_page.dart';
import 'package:note_keeper/utils/database_helper.dart';

class Notespage extends StatefulWidget {
  const Notespage({super.key});

  @override
  State<Notespage> createState() => _NotespageState();
}

class _NotespageState extends State<Notespage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<NoteModel>? noteModelList;

  @override
  void initState() {
    super.initState();
    _updateNotelist();
  }

  void _updateNotelist() async {
    final noteMapList = await databaseHelper.getNoteMapList();
    log(noteMapList.toString());
    final tempList =
        noteMapList.map((noteMap) => NoteModel.fromMap(noteMap)).toList();
    setState(() {
      noteModelList = tempList;
    });
  }

  Color getpriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  IconData getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.play_arrow;
      case 2:
        return Icons.keyboard_arrow_right;
      default:
        return Icons.keyboard_arrow_right;
    }
  }

  void deleteNoteFromNoteList(NoteModel note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _updateNotelist();
      _showSnackBar("Successfully deleted the note", 0);
    } else {
      _showSnackBar("Failed to delete the note", 1);
    }
  }

  void _showSnackBar(String val, int intval) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(val),
        backgroundColor: intval == 0 ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteAddPage(pageTitle: "Add Note"),
            ),
          );
          // final note = NoteModel(
          //   DateTime.timestamp().millisecondsSinceEpoch,
          //   "Dummy Note",
          //   "No description",
          //   DateTime.now().toString(),
          //   1,
          // );
          // await databaseHelper.insertNote(note);
          if (result == true) {
            _updateNotelist();
          }
        },
        shape: CircleBorder(),
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: noteList(),
    );
  }

  Widget noteList() {
    if (noteModelList == null || noteModelList!.isEmpty) {
      return Center(
        child: Text(
          "No Notes Yet!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          final note = noteModelList![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NoteDetailsPage(
                            pageTitle: "Edit Note",
                            noteModel: note,
                          ),
                    ),
                  );

                  if (result == true) {
                    _updateNotelist();
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: getpriorityColor(note.priority),
                  child: Icon(
                    getPriorityIcon(note.priority),
                    color: Colors.white,
                  ),
                ),
                title: Text(note.title),
                subtitle: Text(note.date),
                trailing: IconButton(
                  onPressed: () {
                    deleteNoteFromNoteList(note);
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
            ),
          );
        },
        itemCount: noteModelList!.length,
      );
    }
  }
}

class NoteModel {
  int? id;
  String title;
  String? description;
  String date;
  int priority;

  NoteModel(this.id, this.title, this.description, this.date, this.priority);

  // toMap function to convert dart objects to map because the sqflite plugin saves map object to the sqlit database. //
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;
    map["description"] = description;
    map["date"] = date;
    map["priority"] = priority;

    return map;
  }



  // This is a factory constructor that act as a fromMap function.
  // this will take map value in its parameter and inside the factory constructor it call default constructor and assing value then return

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      map["id"],
      map["title"],
      map["description"],
      map["date"],
      map["priority"],
    );
  }
}

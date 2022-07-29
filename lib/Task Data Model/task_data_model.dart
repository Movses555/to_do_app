import 'dart:convert';

class TaskModel{


  var title;

  var description;

  var color;

  var isCompleted;

  TaskModel({this.title, this.description, this.color, this.isCompleted});

  void setCompleted(bool isCompleted){
    this.isCompleted = isCompleted;
  }

  bool get getCompleted => isCompleted;


  // Create fromJson, toMap, encode and decode functions to serialize TaskModel data to Json(String) to save in SharedPreferences

  TaskModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        color = json['color'],
        isCompleted = json['is_completed'];

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'color': color,
    'is_completed' : isCompleted
  };


}
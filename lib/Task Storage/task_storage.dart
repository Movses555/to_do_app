import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/Task%20Data%20Model/task_data_model.dart';

class TaskStorage{

  static late SharedPreferences prefs;

  static const String _key = 'TASKS';

  // Init shared preferences
  static Future<SharedPreferences> init() async {
    return prefs = await SharedPreferences.getInstance();
  }

  // Saving task data
  static void saveTask(List<TaskModel> tasks) async {
    await prefs.setString(_key, jsonEncode(tasks));
  }

  // Getting all tasks
  static List<TaskModel> getTasks(){
    String? data = prefs.getString(_key);

    // Converting List of dynamic objects to List of 'TaskModel' objects
    List<TaskModel> taskList = [];
    if(data != null){
      List<dynamic> dynamicList = jsonDecode(data);
      taskList = dynamicList.map((task) => TaskModel.fromJson(task)).toList();
    }
    
    return taskList;
  }

  static void clear(){
    prefs.clear();
  }
}
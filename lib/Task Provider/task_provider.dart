import 'package:flutter/cupertino.dart';
import 'package:to_do_app/Task%20Storage/task_storage.dart';

import '../Task Data Model/task_data_model.dart';

class TaskProvider extends ChangeNotifier{


  List<TaskModel> _taskList = []; //Tasks list


  // Getters for complete and incomplete tasks
  List<TaskModel> get getAllTasks => _taskList;
  List<TaskModel> get getCompletedTasks => _taskList.where((task) => task.isCompleted).toList();  // Getting completed tasks
  List<TaskModel> get getIncompleteTasks => _taskList.where((task) => !task.isCompleted).toList(); // Getting incomplete tasks


  // Setter for task list
  void setTasksList(List<TaskModel>? _taskList){
    this._taskList = _taskList!;
  }


  // Adding task to list
  void addTask(TaskModel task){
    _taskList.add(task);

    TaskStorage.saveTask(_taskList);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }


  // Set whether task is completed or not
  void setCompleted(bool isCompleted, TaskModel taskModel){
    _taskList.where((task) => task == taskModel).first.setCompleted(isCompleted);

    TaskStorage.saveTask(_taskList);

    notifyListeners();
  }


  // Editing tasks
  void editTask(TaskModel oldTask, TaskModel newTask, int index){
    _taskList.remove(oldTask);
    _taskList.insert(index, newTask);

    TaskStorage.saveTask(_taskList);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }


  // Deleting tasks
  void deleteTask(TaskModel task){
    _taskList.remove(task);

    TaskStorage.saveTask(_taskList);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }

}
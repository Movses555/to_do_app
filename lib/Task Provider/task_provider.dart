import 'package:flutter/cupertino.dart';
import 'package:to_do_app/Task%20Storage/task_storage.dart';

import '../Task Data Model/task_data_model.dart';

class TaskProvider extends ChangeNotifier{


  List<TaskModel> taskList = []; //Tasks list


  // Getters for complete and incomplete tasks
  List<TaskModel> get getCompletedTasks => taskList.where((task) => task.isCompleted).toList();  // Getting completed tasks
  List<TaskModel> get getIncompleteTasks => taskList.where((task) => !task.isCompleted).toList(); // Getting incomplete tasks


  // Setter for task list
  void setTasksList(List<TaskModel>? taskList){
    this.taskList = taskList!;
  }

  // Adding task to list
  void addTask(TaskModel task){
    taskList.add(task);

    TaskStorage.saveTask(taskList);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }

  void setCompleted(bool isCompleted, int index){
    taskList[index].setCompleted(isCompleted);

    notifyListeners();
  }

  // Editing tasks
  void editTask(TaskModel editedTask, int index){
    taskList.removeAt(index);
    taskList.insert(index, editedTask);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }

  // Deleting tasks
  void deleteTask(int index){
    taskList.removeAt(index);

    notifyListeners(); // Notifying that list is changed and the listeners will update their states
  }

}
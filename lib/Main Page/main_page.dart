import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/Task%20Data%20Model/task_data_model.dart';
import 'package:to_do_app/Task%20Provider/task_provider.dart';
import 'package:to_do_app/Task%20Storage/task_storage.dart';

class MainPage extends StatefulWidget{
  const MainPage({Key? key}) : super(key: key);


  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage>{

  late double height;
  late double width;
  late StateSetter taskStatusFilterState;

  bool showCompleted = false;


  // Define colors of task
  bool isRedColorSelected = true; // Red is true by default
  bool isOrangeColorSelected = false;
  bool isPurpleColorSelected = false;
  bool isBlueColorSelected = false;
  bool isGreenColorSelected = false;


  // Define text field controllers
  TextEditingController titleFieldController = TextEditingController();
  TextEditingController descriptionFieldController = TextEditingController();


  // Define tasks list
  List<TaskModel> completedTasks = [];
  List<TaskModel> incompleteTasks = [];

  @override
  void initState() {

    // Calling this function when build is finished

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(TaskStorage.getTasks().isNotEmpty){
        Provider.of<TaskProvider>(context, listen: false).setTasksList(TaskStorage.getTasks());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers after closing the app to free up memory

    titleFieldController.dispose();
    descriptionFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        height = constraints.maxHeight; // Getting device screen max height
        width = constraints.maxWidth; // Getting device screen max width
        return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light, // Set the toolbar color to white
            title: const Text('To Do App'),
            backgroundColor: Colors.tealAccent[400],
            centerTitle: false,
            elevation: 0,
            actions: [
              StatefulBuilder(
                builder: (context, setState){
                  taskStatusFilterState = setState;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Center(
                      child: Text(showCompleted ? 'Completed' : 'Incomplete', style: const TextStyle(fontSize: 18)),
                    ),
                  );
                },
              )
            ],
          ),
          body: mainBody(),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 35),
                child: FloatingActionButton(
                  onPressed: (){
                    setState((){
                      showCompleted = !showCompleted;
                    });
                  },
                  backgroundColor: Colors.tealAccent[400],
                  child: const Icon(Icons.filter_list_alt),
                ),
              ),
              FloatingActionButton(
                onPressed: (){

                  // Showing add task bottom sheet
                  showCupertinoModalBottomSheet(
                      context: context,
                      duration: const Duration(milliseconds: 250),
                      builder: (context){
                        return addTaskWidget(null, false, 0);
                      }
                  );
                },
                backgroundColor: Colors.tealAccent[400],
                child: const Icon(Icons.add),
              ),
            ],
          )
        );
      },
    );
  }



  // Application main body
  Widget mainBody(){
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Consumer<TaskProvider>( // Consumer is updating its child state when notifyListeners() is called
        builder: (context, viewModel, child){
          List<TaskModel> tasksList = [];
          if(!showCompleted){
            tasksList = viewModel.getIncompleteTasks;
          }else{
            tasksList = viewModel.getCompletedTasks;
          }
          return ListView.separated(
            itemCount: tasksList.length,
            separatorBuilder: (context, index){
              return const Divider(color: Colors.white);
            },
            itemBuilder: (context, index){
              TaskModel task = tasksList[index];
              return Slidable(
                  key: ValueKey(index),
                  endActionPane: ActionPane(
                    extentRatio: 1,
                    dragDismissible: true,
                    motion: DrawerMotion(),
                    children: [
                      SlidableAction(
                          icon: task.getCompleted ? Icons.close_sharp : CupertinoIcons.checkmark,
                          backgroundColor: task.getCompleted ? Colors.deepOrange : Colors.green,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          label: task.getCompleted ? 'Not completed' : 'Complete',
                          onPressed: (context){
                            // Setting task status to completed
                            if(task.getCompleted){
                              Provider.of<TaskProvider>(context, listen: false).setCompleted(false, index);
                            }else{
                              Provider.of<TaskProvider>(context, listen: false).setCompleted(true, index);
                            }
                          }
                      ),
                      SlidableAction(
                        icon: CupertinoIcons.pen,
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        label: 'Edit',
                        onPressed: (context){
                          showCupertinoModalBottomSheet(
                              context: context,
                              duration: const Duration(milliseconds: 250),
                              builder: (context){
                                return addTaskWidget(task, true, index);
                              }
                          );
                        },
                      ),
                      SlidableAction(
                        icon: CupertinoIcons.delete,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        label: 'Delete',
                        onPressed: (context){
                          // Deleting task
                          Provider.of<TaskProvider>(context, listen: false).deleteTask(index);
                        },
                      ),
                    ],
                  ),
                  child: Container(
                      height: 100,
                      width: width,
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      decoration: BoxDecoration(
                          color: Color(int.parse('0x${task.color}')).withOpacity(0.4),
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                      ), // Container inner padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${task.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text('${task.description}')
                              ],
                            ),
                          ),
                          task.isCompleted ? Container(
                            margin: EdgeInsets.only(right: 20, bottom: 10),
                            child: Icon(Icons.check, color: Colors.green, size: 30),
                          ) : SizedBox()
                        ],
                      )
                  )
              );
            },
          );
        },
      )
    );
  }






  Widget addTaskWidget(TaskModel? task, bool isEditing, int index){

    // If user edits the task fill up fields with selected task data
    if(isEditing){
      titleFieldController.value = titleFieldController.value.copyWith(text: task!.title);
      descriptionFieldController.value = descriptionFieldController.value.copyWith(text: task.description);
    }

    return Material(
        child: StatefulBuilder(     // Create StatefulBuilder under cupertino modal bottom sheet to control its state and change task color
          builder: (context, sheetState){
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(fontSize: 17, color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: (){
                          if(!isEditing){
                            // Add task to list
                            TaskModel task = TaskModel(
                                title: titleFieldController.text,
                                description: descriptionFieldController.text,
                                color: isRedColorSelected
                                    ? Colors.red.value.toRadixString(16)
                                    : isOrangeColorSelected
                                    ? Colors.orange.value.toRadixString(16)
                                    : isPurpleColorSelected
                                    ? Colors.purple.value.toRadixString(16)
                                    : isBlueColorSelected
                                    ? Colors.lightBlueAccent.value.toRadixString(16)
                                    : isGreenColorSelected
                                    ? Colors.green.value.toRadixString(16) : null,
                                isCompleted: false
                            );

                            Provider.of<TaskProvider>(context, listen: false).addTask(task);


                            // Saving task to storage
                            Navigator.pop(context); // Close the sheet

                            titleFieldController.clear(); // Clear title field data
                            descriptionFieldController.clear(); // Clear description field data
                          }else{

                            // Updating task
                            TaskModel edited = TaskModel(
                                title: titleFieldController.text,
                                description: descriptionFieldController.text,
                                color: isRedColorSelected
                                    ? Colors.red.value.toRadixString(16)
                                    : isOrangeColorSelected
                                    ? Colors.orange.value.toRadixString(16)
                                    : isPurpleColorSelected
                                    ? Colors.purple.value.toRadixString(16)
                                    : isBlueColorSelected
                                    ? Colors.lightBlueAccent.value.toRadixString(16)
                                    : isGreenColorSelected
                                    ? Colors.green.value.toRadixString(16) : null,
                                isCompleted: task!.getCompleted
                            );

                            Provider.of<TaskProvider>(context, listen: false).editTask(edited, index);

                            // Update state of the app
                            Navigator.pop(context); // Close the sheet

                            titleFieldController.clear(); // Clear title field data
                            descriptionFieldController.clear(); // Clear description field data
                          }
                        },
                        child: Text('Done', style: TextStyle(fontSize: 17, color: Colors.tealAccent[400])),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Title text field
                      TextFormField(
                        controller: titleFieldController,
                        cursorColor: Colors.tealAccent[400],
                        decoration: InputDecoration(
                            hintText: 'Title',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))
                            )
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Description text field
                      TextFormField(
                        controller: descriptionFieldController,
                        cursorColor: Colors.tealAccent[400],
                        decoration: InputDecoration(
                            hintText: 'Description',
                            enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5))
                            )
                        ),
                      ),

                      const SizedBox(height: 30),

                      //Define colors or task
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                              onTap: (){
                                sheetState(() {
                                  isRedColorSelected = true;

                                  isOrangeColorSelected = false;
                                  isPurpleColorSelected = false;
                                  isBlueColorSelected = false;
                                  isGreenColorSelected = false;
                                });
                              },
                              child: ClipOval(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.red.withOpacity(0.7),
                                  child: isRedColorSelected ? const Center(
                                    child: Icon(CupertinoIcons.checkmark, color: Colors.white,),
                                  ) : null,
                                ),
                              )
                          ),
                          GestureDetector(
                            onTap: (){
                              sheetState(() {
                                isOrangeColorSelected = true;

                                isRedColorSelected = false;
                                isPurpleColorSelected = false;
                                isBlueColorSelected = false;
                                isGreenColorSelected = false;
                              });
                            },
                            child: ClipOval(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.orange.withOpacity(0.7),
                                  child: AnimatedOpacity(   // Lets animate the checkmark change with opacity
                                    duration: const Duration(milliseconds: 150),
                                    opacity: isOrangeColorSelected ? 1 : 0,
                                    child: const Center(
                                      child: Icon(CupertinoIcons.checkmark, color: Colors.white),
                                    ),
                                  )
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              sheetState(() {
                                isPurpleColorSelected = true;

                                isOrangeColorSelected = false;
                                isRedColorSelected = false;
                                isBlueColorSelected = false;
                                isGreenColorSelected = false;
                              });
                            },
                            child: ClipOval(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.purple.withOpacity(0.7),
                                  child: AnimatedOpacity( // Lets animate the checkmark change with opacity
                                    duration: const Duration(milliseconds: 150),
                                    opacity: isPurpleColorSelected ? 1 : 0,
                                    child: const Center(
                                      child: Icon(CupertinoIcons.checkmark, color: Colors.white),
                                    ),
                                  )
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              sheetState(() {
                                isBlueColorSelected = true;

                                isPurpleColorSelected = false;
                                isOrangeColorSelected = false;
                                isRedColorSelected = false;
                                isGreenColorSelected = false;
                              });
                            },
                            child: ClipOval(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.lightBlueAccent.withOpacity(0.7),
                                  child: AnimatedOpacity(  // Lets animate the checkmark change with opacity
                                    duration: const Duration(milliseconds: 150),
                                    opacity: isBlueColorSelected ? 1 : 0,
                                    child: const Center(
                                      child: Icon(CupertinoIcons.checkmark, color: Colors.white),
                                    ),
                                  )
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              sheetState(() {
                                isGreenColorSelected = true;

                                isBlueColorSelected = false;
                                isPurpleColorSelected = false;
                                isOrangeColorSelected = false;
                                isRedColorSelected = false;
                              });
                            },
                            child: ClipOval(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.green.withOpacity(0.7),
                                  child: AnimatedOpacity( // Lets animate the checkmark change with opacity
                                    duration: const Duration(milliseconds: 150),
                                    opacity: isGreenColorSelected ? 1 : 0,
                                    child: const Center(
                                      child: Icon(CupertinoIcons.checkmark, color: Colors.white),
                                    ),
                                  )
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          },
        )
    );
  }
}
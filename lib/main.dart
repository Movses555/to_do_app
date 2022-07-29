import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/Task%20Provider/task_provider.dart';
import 'package:to_do_app/Task%20Storage/task_storage.dart';

import 'Main Page/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskStorage.init();  // Initialize shared preferences
  runApp(ChangeNotifierProvider<TaskProvider>(
    create: (context) => TaskProvider(),
    child: const MaterialApp(
      home: MainPage(),
    ),
  ));
}


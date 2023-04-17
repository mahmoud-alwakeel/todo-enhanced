import 'package:get/get.dart';
import 'package:todo_enhanced/db/dp_helper.dart';
import 'package:todo_enhanced/models/task.dart';

class TaskController extends GetxController{
  final RxList<Task> taskList = <Task>[].obs;

  Future<int> addTask({Task? task}){
    return DBHelper.insert(task);
  }

  // to get data from database
  getTasks() async{
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }
  // to update data in database
  markTaskCompleted(int id) async{
    await DBHelper.update(id);
    getTasks();
  }

  // to delete data in database
  deleteTask(Task task) async{
    await DBHelper.delete(task);
    getTasks();
  }

  deleteAllTask() async{
    await DBHelper.deleteAll();
    getTasks();
  }
}
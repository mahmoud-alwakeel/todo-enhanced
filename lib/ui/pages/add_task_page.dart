import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_enhanced/controllers/task_controller.dart';
import 'package:todo_enhanced/ui/theme.dart';
import 'package:todo_enhanced/ui/widgets/button.dart';

import '../../models/task.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _endTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();

  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = "None";
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputField(
                title: 'title',
                hint: 'enter something',
                controller: _titleController,
              ),
              InputField(
                title: 'note',
                hint: 'enter note ',
                controller: _noteController,
              ),
              InputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'Start time',
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: Icon(
                          Icons.alarm,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: InputField(
                      title: 'End time',
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: Icon(
                          Icons.alarm,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                title: 'remind',
                hint: "$_selectedRemind minutes early",
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                      items: remindList
                          .map<DropdownMenuItem<String>>(
                            (int value) => DropdownMenuItem<String>(
                              value: value.toString(),
                              child: Text(
                                "$value",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      style: subTitleStyle,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                    ),
                    const SizedBox(width: 8,)
                  ],
                ),
              ),
              InputField(
                title: 'repeat',
                hint: _selectedRepeat,
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueAccent,
                      items: repeatList
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                "$value",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      style: subTitleStyle,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                        });
                      },
                    ),
                    const SizedBox(width: 8,)
                  ],
                ),

              ),
              const SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(label: "create task", onTap: () {
                    _validate();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar(){
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      backgroundColor: context.theme.colorScheme.background,
      title: Text(
        "Add task",
        style: TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr),
      ),
      actions: const [
         CircleAvatar(
          // it's preferable to put an icon instead of the image as it have less size
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        const SizedBox(width: 18,)
      ],
    );
  }

  _validate(){
    if(_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDB();
      Get.back();
    }
    else if (_titleController.text.isEmpty || _noteController.text.isEmpty){
      Get.snackbar(
        'required',
        'please fill all fields',
        colorText: Colors.deepPurpleAccent,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.deepPurpleAccent,),
        duration: Duration(milliseconds: 5000),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    else {
      print("############ SOMETHING BAD HAPPENED ############");
    }
  }

  _addTaskToDB() async{
    try{
      int value = await _taskController.addTask(
        task: Task(
          title: _titleController.text,
          note: _noteController.text,
          isCompleted: 0,
          date: DateFormat.yMd().format(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          color: _selectedColor,
          remind: _selectedRemind,
          repeat: _selectedRepeat,
        ),
      );
      print("$value");
    }
    catch (e){
      print("error");
    }
  }

  Column _colorPalette() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
        "Color",
        style: subHeadingStyle,
      ),
      const SizedBox(height: 8,),
      Wrap(
        children: List.generate(
          3,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = index;
                print("color selected");
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                child: _selectedColor == index ? const Icon(
                        Icons.done,
                        size: 20,
                        color: Colors.white,
                      ): null,
                backgroundColor: index == 0
                    ? primaryClr
                    : index == 1
                        ? pinkClr
                        : orangeClr,
                radius: 16,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  _getDateFromUser () async{
    DateTime? _pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
    );

    // if(_pickedDate != null)
    setState(() {
      _selectedDate = _pickedDate!;
    });

  }


  _getTimeFromUser({required bool isStartTime}) async {

    TimeOfDay? _pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: isStartTime
            ? TimeOfDay.fromDateTime(DateTime.now())
            : TimeOfDay.fromDateTime(
            DateTime.now().add(const Duration(minutes: 15))) ,
    );

    // as pickTime is not string as a result we must change to be a string
    String _formattedTime = _pickedTime!.format(context);

    if(isStartTime) {
      setState(() => _startTime = _formattedTime);
    }
    else if(!isStartTime) {
      setState(() => _startTime = _formattedTime);
    } else {
      print(" a");
    }


  }

}


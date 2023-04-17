import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_enhanced/db/dp_helper.dart';
import 'package:todo_enhanced/models/task.dart';
import 'package:todo_enhanced/services/notification_services.dart';
import 'package:todo_enhanced/services/theme_services.dart';
import 'package:todo_enhanced/ui/size_config.dart';
import 'package:todo_enhanced/ui/widgets/button.dart';
import 'package:intl/intl.dart';
import 'package:todo_enhanced/ui/widgets/task_tile.dart';
import '../../controllers/task_controller.dart';
import '../theme.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: _appBar(),
      // there was an error here when the body was a SingleChildScrollView
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(
            height: 10,
          ),
          _showTasks(),
        ],
      ),
    );
  }

  // here we are duplicating code , that's initial and i'll be
  // back correcting it
  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          ThemeServices().switchTheme();
        },
        icon: Icon(Get.isDarkMode
            ? Icons.wb_sunny_outlined
            : Icons.nightlight_round_outlined),
      ),
      backgroundColor: context.theme.colorScheme.background,
      title: Text(
        "",
        style: TextStyle(color: Get.isDarkMode ? Colors.white : darkGreyClr),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _taskController.deleteAllTask();
            notifyHelper.cancelAllNotification();
          },
          icon: Icon(
            Icons.cleaning_services_outlined,
          ),
        ),
        const CircleAvatar(
          // it's preferable to put an icon instead of the image as it have less size
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        const SizedBox(
          width: 18,
        )
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                "Today",
                style: headingStyle,
              ),
            ],
          ),
          MyButton(
            label: "+ add task",
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
          ),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 6),
      child: DatePicker(
        DateTime.now(),
        width: 65,
        height: 100,
        initialSelectedDate: _selectedDate,
        selectedTextColor: Get.isDarkMode ? Colors.black : Colors.white,
        selectionColor: primaryClr,
        onDateChange: (newDate) => setState(() {
          _selectedDate = newDate;
        }),
        // also here is  duplicated code
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(child: Obx(() {
      if (_taskController.taskList.isEmpty) {
        //_taskController.taskList.isEmpty
        return _noTaskMsg();
      } else {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            scrollDirection: SizeConfig.orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              var task = _taskController.taskList[index];

              if (task.repeat == "Daily" ||
                  task.date == DateFormat.yMd().format(_selectedDate) ||
                  (task.repeat == "Weekly" &&
                      _selectedDate
                                  .difference(
                                      DateFormat.yMd().parse(task.date!))
                                  .inDays %
                              7 ==
                          0) ||
                  (task.repeat == "Monthly" &&
                      DateFormat.yMd().parse(task.date!).day ==
                          _selectedDate.day)) {
                var hour = task.startTime.toString().split(':')[0];
                var minutes = task.startTime.toString().split(':')[1];

                debugPrint("my time is : " + hour);
                debugPrint("my time is : " + minutes);

                var date = DateFormat.jm().parse(task.startTime!);
                var myTime = DateFormat("HH:mm").format(date);

                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(':')[0]),
                    int.parse(myTime.toString().split(':')[1]),
                    task);
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 325),
                  child: SlideAnimation(
                    horizontalOffset: 300,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          _showBottomSheet(context, task);
                        },
                        child: TaskTile(task),
                      ),
                    ),
                  ),
                );
              } else
                return Container();
            },
            itemCount: _taskController.taskList.length,
          ),
        );
      }
    }));
  }

  _noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              //scrollDirection: Axis.vertical,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 120,
                        ),
                  SvgPicture.asset(
                    "images/task.svg",
                    height: 220,
                    color: primaryClr.withOpacity(0.7),
                    semanticsLabel: "task",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    child: Text(
                      "You don't have any tasks yet!\n Add new tasks to make your day productive",
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.30
                : SizeConfig.screenHeight * 0.39),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(
          children: [
            Flexible(
              child: Container(
                height: 6,
                width: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    label: "task completed",
                    onTap: () {
                      _taskController.markTaskCompleted(task.id!);
                      // as we mark task completed then we don't want notification for it
                      notifyHelper.cancelNotification(task);
                      Get.back();
                    },
                    clr: primaryClr,
                  ),
            _buildBottomSheet(
              label: "delete task",
              onTap: () {
                // cancel the notification with id value of zero
                //await flutterLocalNotificationsPlugin.cancel(0);
                _taskController.deleteTask(task);
                notifyHelper.cancelNotification(task);
                Get.back();
              },
              clr: Colors.red,
            ),
            Divider(
              color: Get.isDarkMode ? Colors.grey : darkGreyClr,
            ),
            _buildBottomSheet(
              label: "cancel",
              onTap: () {
                Get.back();
              },
              clr: primaryClr,
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    ));
  }

  _buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[200]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

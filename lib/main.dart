import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_enhanced/db/dp_helper.dart';
import 'package:todo_enhanced/services/notification_services.dart';
import 'package:todo_enhanced/services/theme_services.dart';
import 'package:todo_enhanced/ui/pages/home_page.dart';
import 'package:todo_enhanced/ui/pages/notifications_screen.dart';
import 'package:todo_enhanced/ui/theme.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  await  GetStorage.init();
  //NotifyHelper().initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo enhanced',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      home: const HomePage(),//NotificationsScreen(payLoad:'Title|Desc|10:33'),
    );
  }
}

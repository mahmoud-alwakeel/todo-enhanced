import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_enhanced/models/task.dart';
import 'package:todo_enhanced/ui/size_config.dart';
import 'package:todo_enhanced/ui/theme.dart';

class TaskTile extends StatelessWidget {
  const TaskTile(this.task, {Key? key}) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(
            SizeConfig.orientation == Orientation.landscape ?
            4 : 20
        ),
      ),
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      width: SizeConfig.orientation == Orientation.landscape ?
      SizeConfig.screenWidth/2 :
      SizeConfig.screenWidth,

      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task.color)
        ),
        child: Row(

          children: [
            Expanded(child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title!,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),),
                  const SizedBox(height: 12,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded,
                      color: Colors.white,
                      size: 18,),
                      const SizedBox(width: 12,),
                      Text("${task.startTime} - ${task.endTime}",
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),)
                    ],
                  ),
                  const SizedBox(height: 12,),
                  Text(task.note!,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),),
                ],
              ),
            ),),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey,
            ),
            RotatedBox(quarterTurns: 3,
              child: Text(task.isCompleted == 0 ? "TODO" : "Completed",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getBGClr(int? color) {
    switch(color){
      case 0:
        return primaryClr;
      case 1:
        return pinkClr;
      case 2:
        return orangeClr ;
      default:
        return primaryClr;
    }
  }
}

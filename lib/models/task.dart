class Task {
  int? id;
  String? title;
  String? note;
  int? isCompleted;
  String? date;
  String? startTime;
  String? endTime;
  int? color;
  int? remind;
  String? repeat;

  Task({
    this.color,
    this.endTime,
    this.startTime,
    this.note,
    this.title,
    this.isCompleted,
    this.date,
    this.id,
    this.remind,
    this.repeat,
  });

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'title':title,
      'note':note,
      'isCompleted':isCompleted,
      'date':date,
      'startTime':startTime,
      'endTime':endTime,
      'color':color,
      'remind':remind,
      'repeat':repeat,
    };
  }

   Task.fromJson(Map<String, dynamic> json){

      id= json['id'];
      title= json['title'];
      note= json['note'];
      isCompleted= json['isCompleted'];
      date= json['date'];
      startTime= json['startTime'];
      endTime= json['endTime'];
      color= json['color'];
      remind= json['remind'];
      repeat= json['repeat'];

  }




}

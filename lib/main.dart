import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<Task> tasks = [
    Task(title: "Odkurzyć mieszkanie", deadline: "piątek", done: false, priority: "średni"),
    Task(title: "Zrobić pranie", deadline: "jutro",done: true, priority: "niski"),
    Task(title: "Nauka do kolokwium", deadline: "do końca tygodnia", done: false, priority: "wysoki"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow")
        ),
        body: Center(
          child: Column(
        children: [
          Text("Masz dzisiaj ${tasks.length} zadania"),
          SizedBox(height: 12),
          Text("Zrobiono ${done} zadanie"),
          SizedBox(height: 12),
          Text(
          "Dzisiejsze zadania",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
          return TaskCard(title: tasks[index].title,
          subtitle: tasks[index].deadline,
              icon:
              tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked);
          },
        )
      )
          ],
    ),
        )
      )
    );
  }
}
class Task {
  final String title;
  final String deadline;
  final String priority;
  final bool done;
  Task({
    required this.title,
    required this.deadline,
    required this.priority,
    required this.done,});
}
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
       child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
      children:[
      Padding(
        padding: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    ),
    ],
      )
    );
  }
}

import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  home: EkranGlowny()
  );
  }
  }
class EkranGlowny extends StatefulWidget{
  const EkranGlowny({super.key});
  @override
  State<EkranGlowny> createState() => _EkranGlownyState();}

class _EkranGlownyState extends State<EkranGlowny>{
  @override
  Widget build(BuildContext context) {
    int doneCount = TaskRepository.tasks.where((task) => task.done).length;
    return Scaffold(
      appBar: AppBar(
          title: Text("KrakFlow")
      ),
      body: Center(
        child: Column(
            children: [
        Text("Masz dzisiaj ${TaskRepository.tasks.length} zadania"),
        SizedBox(height: 12),
        Text("Zrobiono $doneCount zadanie"),
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
          itemCount: TaskRepository.tasks.length,
          itemBuilder: (context, index) {
            return TaskCard(title: TaskRepository.tasks[index].title,
            subtitle:"Termin: ${TaskRepository.tasks[index].deadline} | Priorytet: ${TaskRepository.tasks[index].priority}",
            icon:
            TaskRepository.tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked);
      },
    ),
    ),
    ],
    ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTaskScreen()),
          );
              if (newTask != null){
                setState((){
                  TaskRepository.tasks.add(newTask);
          });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
        ),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet (wysoki/średni/niski)",
                border: OutlineInputBorder(),
              ),
            ),
        ElevatedButton(
            onPressed: () {
              final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
              );
              Navigator.pop(context, newTask);
            },
            child: Text("Zapisz"),
            ),
          ],
        ),
      )
    );
  }
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

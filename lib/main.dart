import 'package:flutter/material.dart';
import 'models/task.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: EkranGlowny());
  }
}

class EkranGlowny extends StatefulWidget {
  const EkranGlowny({super.key});
  @override
  State<EkranGlowny> createState() => _EkranGlownyState();
}

class _EkranGlownyState extends State<EkranGlowny> {
  String selectedFilter = "wszystkie";
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Potwierdzenie"),
                    content: Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Anuluj"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await TaskLocalDatabase.deleteAllTasks();
                          setState(() {
                            tasksFuture = loadTasks();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Usunięto wszystkie zadania")),
                          );
                        },
                        child: Text("Usuń"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wszystkie";
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selectedFilter == "wszystkie"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: Text("Wszystkie"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "do zrobienia";
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selectedFilter == "do zrobienia" ? Colors
                        .blue : Colors.grey,
                  ),
                  child: Text("Do zrobienia"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wykonane";
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selectedFilter == "wykonane"
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: Text("Wykonane"),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Błąd: ${snapshot.error}"),
                    );
                  }
                  final tasks = snapshot.data!;
                  return ListView(
                    children: tasks.map((task) {
                      return Dismissible(
                        key: ValueKey(task.title),
                        onDismissed: (direction) async {
                          await TaskLocalDatabase.deleteTask(task.id);
                          setState(() {
                            tasksFuture = loadTasks();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Zadanie usunięte")),
                          );
                        },
                        child: TaskCard(
                          title: task.title,
                          subtitle: "Termin: ${task.deadline} | Priorytet: ${task.priority}",
                          done: task.done,
                          onChanged: (value) async {
                            final updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              deadline: task.deadline,
                              priority: task.priority,
                              done: value ?? false,
                            );
                            await TaskLocalDatabase.updateTask(updatedTask);
                            setState(() {
                              tasksFuture = loadTasks();
                            });
                          },
                          onTap: () async {
                            final Task? updatedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTaskScreen(task: task),
                              ),
                            );if (updatedTask != null) {
                              await TaskLocalDatabase.updateTask(updatedTask);
                              setState(() {
                                tasksFuture = loadTasks();
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            await TaskLocalDatabase.addTask(newTask);
            setState(() {
              tasksFuture = loadTasks();
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
                    id: Random().nextInt(1000000),
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
        ));
  }
}
class EditTaskScreen extends StatelessWidget {
  final Task task;
  EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
    TextEditingController(text: task.title);
    final TextEditingController deadlineController =
    TextEditingController(text: task.deadline);
    final TextEditingController priorityController =
    TextEditingController(text: task.priority);

    return Scaffold(
        appBar: AppBar(
          title: Text("Edytuj zadanie"),
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
                  final updatedTask = Task(
                    id: task.id,
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                    done: task.done,
                  );
                  Navigator.pop(context, updatedTask);
                },
                child: Text("Zapisz"),
              ),
            ],
          ),
        ));
  }
}
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: ListTile(
                onTap: onTap,
                leading: Checkbox(
                  value: done,
                  onChanged: onChanged,
                ),
                title: Text(title,
                  style: TextStyle(
                    decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                    color: done ? Colors.grey : null,
                  ),
                ),
                subtitle: Text(subtitle),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ));
  }
}

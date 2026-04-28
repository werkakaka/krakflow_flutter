class Task {
  final String title;
  final String deadline;
  final String priority;
  bool done;
  Task({
    required this.title,
    required this.deadline,
    required this.priority,
    required this.done,});
}
class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Odkurzyć mieszkanie",
        deadline: "piątek",
        done: false,
        priority: "średni"),
    Task(title: "Zrobić pranie",
        deadline: "jutro",
        done: true,
        priority: "niski"),
    Task(title: "Nauka do kolokwium",
        deadline: "do końca tygodnia",
        done: false,
        priority: "wysoki"),
  ];
}
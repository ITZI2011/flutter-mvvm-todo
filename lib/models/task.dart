enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  bool isDone;
  TaskPriority priority;
  DateTime? dueDate;
  List<String> tags;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    List<String>? tags,
  }) : tags = tags ?? [];

  Task copy() => Task(
        id: id,
        title: title,
        isDone: isDone,
        priority: priority,
        dueDate: dueDate,
        tags: List<String>.from(tags),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isDone": isDone,
        "priority": priority.name,
        "dueDate": dueDate?.millisecondsSinceEpoch,
        "tags": tags,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json["id"] as String,
        title: json["title"] as String,
        isDone: (json["isDone"] as bool?) ?? false,
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == (json["priority"] as String? ?? "medium"),
          orElse: () => TaskPriority.medium,
        ),
        dueDate: (json["dueDate"] as int?) == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json["dueDate"] as int),
        tags: ((json["tags"] as List?) ?? []).map((e) => e.toString()).toList(),
      );
}

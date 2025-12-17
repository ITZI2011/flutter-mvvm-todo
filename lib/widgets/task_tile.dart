import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;

  const TaskTile({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData prIcon;
    String prLabel;
    switch (task.priority) {
      case TaskPriority.high:
        prIcon = Icons.priority_high;
        prLabel = "Haute";
        break;
      case TaskPriority.medium:
        prIcon = Icons.remove;
        prLabel = "Moyenne";
        break;
      case TaskPriority.low:
        prIcon = Icons.arrow_downward;
        prLabel = "Basse";
        break;
    }

    final dueText = task.dueDate == null
        ? null
        : "${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}";

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      onDismissed: (_) {
        context.read<TaskProvider>().deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Tâche supprimée"),
            action: SnackBarAction(
              label: "Annuler",
              onPressed: () => context.read<TaskProvider>().undoDelete(),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => context.read<TaskProvider>().toggleTask(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? Colors.black45 : null,
            ),
          ),
          subtitle: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text("Priorité: $prLabel"),
                avatar: Icon(prIcon, size: 18),
              ),
              if (dueText != null)
                Chip(
                  label: Text("Due: $dueText"),
                  avatar: const Icon(Icons.event_outlined, size: 18),
                ),
              for (final tag in task.tags.take(3)) Chip(label: Text("#$tag")),
              if (task.tags.length > 3) Chip(label: Text("+${task.tags.length - 3}")),
            ],
          ),
          trailing: IconButton(
            tooltip: "Modifier",
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}

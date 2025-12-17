import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/filter_bar.dart';
import '../widgets/task_tile.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openEditor({Task? task}) async {
    final provider = context.read<TaskProvider>();

    final titleCtrl = TextEditingController(text: task?.title ?? "");
    TaskPriority priority = task?.priority ?? TaskPriority.medium;
    DateTime? dueDate = task?.dueDate;
    final tagsCtrl = TextEditingController(text: task?.tags.join(", ") ?? "");

    Future<void> pickDate() async {
      final now = DateTime.now();
      final res = await showDatePicker(
        context: context,
        initialDate: dueDate ?? now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
      if (res != null) setState(() => dueDate = res);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(task == null ? "Nouvelle tâche" : "Modifier la tâche",
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: "Titre",
                  prefixIcon: Icon(Icons.task_alt_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<TaskPriority>(
                      segments: const [
                        ButtonSegment(value: TaskPriority.low, label: Text("Basse")),
                        ButtonSegment(value: TaskPriority.medium, label: Text("Moyenne")),
                        ButtonSegment(value: TaskPriority.high, label: Text("Haute")),
                      ],
                      selected: {priority},
                      onSelectionChanged: (s) {
                        priority = s.first;
                        (ctx as Element).markNeedsBuild();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagsCtrl,
                      decoration: const InputDecoration(
                        hintText: "Tags (séparés par virgules) ex: travail, urgent",
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(dueDate == null
                          ? "Ajouter une date limite"
                          : "Date: ${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: "Supprimer la date",
                    onPressed: dueDate == null
                        ? null
                        : () {
                            dueDate = null;
                            (ctx as Element).markNeedsBuild();
                          },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final tags = tagsCtrl.text
                            .split(",")
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toSet()
                            .toList();

                        if (task == null) {
                          provider.addTask(title: title, priority: priority, dueDate: dueDate, tags: tags);
                        } else {
                          final updated = task.copy()
                            ..title = title
                            ..priority = priority
                            ..dueDate = dueDate
                            ..tags = tags;
                          provider.updateTask(updated);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(task == null ? "Créer" : "Enregistrer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        actions: [
          IconButton(
            tooltip: provider.darkMode ? "Mode clair" : "Mode sombre",
            icon: Icon(provider.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => provider.toggleDarkMode(),
          ),
          PopupMenuButton<TaskSort>(
            tooltip: "Trier",
            onSelected: (s) => provider.setSort(s),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: TaskSort.manual, child: Text("Tri manuel")),
              PopupMenuItem(value: TaskSort.priority, child: Text("Par priorité")),
              PopupMenuItem(value: TaskSort.dueDate, child: Text("Par date limite")),
            ],
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: "Supprimer les complétées",
            onPressed: provider.completedCount == 0 ? null : () => provider.clearCompleted(),
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              children: [
                // Stats
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Complétées: ${provider.completedCount} / ${provider.totalCount}  •  Actives: ${provider.activeCount}",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            value: provider.totalCount == 0 ? 0 : provider.completedCount / provider.totalCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Search
                SearchBar(
                  controller: _search,
                  hintText: "Rechercher (titre ou tag)…",
                  leading: const Icon(Icons.search),
                  onChanged: (v) => provider.setQuery(v),
                  trailing: [
                    if (provider.query.isNotEmpty)
                      IconButton(
                        tooltip: "Effacer",
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          provider.setQuery("");
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter
                const FilterBar(),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: tasks.isEmpty
                        ? Center(
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: const Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inbox_outlined, size: 42),
                                    SizedBox(height: 10),
                                    Text("Aucune tâche pour le moment", style: TextStyle(fontWeight: FontWeight.w700)),
                                    SizedBox(height: 6),
                                    Text("Ajoute ta première tâche pour commencer."),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : (provider.sort == TaskSort.manual
                            ? ReorderableListView.builder(
                                itemCount: tasks.length,
                                onReorder: (oldIndex, newIndex) => provider.reorder(oldIndex, newIndex),
                                itemBuilder: (context, index) {
                                  final t = tasks[index];
                                  return Padding(
                                    key: ValueKey(t.id),
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TaskTile(
                                      task: t,
                                      onEdit: () => _openEditor(task: t),
                                    ),
                                  );
                                },
                              )
                            : ListView.separated(
                                itemCount: tasks.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final t = tasks[index];
                                  return TaskTile(
                                    task: t,
                                    onEdit: () => _openEditor(task: t),
                                  );
                                },
                              )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

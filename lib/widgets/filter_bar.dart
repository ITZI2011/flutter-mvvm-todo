import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SegmentedButton<TaskFilter>(
          segments: const [
            ButtonSegment(value: TaskFilter.all, label: Text("Toutes"), icon: Icon(Icons.list_alt_outlined)),
            ButtonSegment(value: TaskFilter.active, label: Text("Actives"), icon: Icon(Icons.playlist_add_check_circle_outlined)),
            ButtonSegment(value: TaskFilter.completed, label: Text("Complétées"), icon: Icon(Icons.verified_outlined)),
          ],
          selected: {provider.filter},
          onSelectionChanged: (set) => context.read<TaskProvider>().setFilter(set.first),
          showSelectedIcon: true,
        ),
      ),
    );
  }
}

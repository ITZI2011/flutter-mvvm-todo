import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

enum TaskFilter { all, active, completed }
enum TaskSort { manual, priority, dueDate }

class TaskProvider extends ChangeNotifier {
  static const _storageKey = "todo_provider_tasks_v1";
  static const _themeKey = "todo_provider_theme_dark_v1";

  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.manual;
  String _query = "";
  bool _darkMode = false;

  // Undo delete
  Task? _lastDeleted;
  int? _lastDeletedIndex;

  TaskProvider() {
    _load();
  }

  // Getters
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;
  String get query => _query;
  bool get darkMode => _darkMode;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get activeCount => _tasks.where((t) => !t.isDone).length;

  List<Task> get tasks {
    Iterable<Task> list = _tasks;

    // filter
    switch (_filter) {
      case TaskFilter.active:
        list = list.where((t) => !t.isDone);
        break;
      case TaskFilter.completed:
        list = list.where((t) => t.isDone);
        break;
      case TaskFilter.all:
        break;
    }

    // search
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) {
        final inTitle = t.title.toLowerCase().contains(q);
        final inTags = t.tags.any((tag) => tag.toLowerCase().contains(q));
        return inTitle || inTags;
      });
    }

    // sort
    final out = list.toList();
    if (_sort == TaskSort.priority) {
      out.sort((a, b) => _priorityRank(b.priority).compareTo(_priorityRank(a.priority)));
    } else if (_sort == TaskSort.dueDate) {
      out.sort((a, b) {
        final ad = a.dueDate?.millisecondsSinceEpoch ?? 9999999999999;
        final bd = b.dueDate?.millisecondsSinceEpoch ?? 9999999999999;
        return ad.compareTo(bd);
      });
    }
    return out;
  }

  int _priorityRank(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  // CRUD
  void addTask({
    required String title,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String>? tags,
  }) {
    final cleaned = title.trim();
    if (cleaned.isEmpty) return;

    _tasks.add(
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: cleaned,
        priority: priority,
        dueDate: dueDate,
        tags: (tags ?? []).where((t) => t.trim().isNotEmpty).map((t) => t.trim()).toSet().toList(),
      ),
    );
    _save();
    notifyListeners();
  }

  void updateTask(Task updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    _tasks[idx] = updated;
    _save();
    notifyListeners();
  }

  void toggleTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx].isDone = !_tasks[idx].isDone;
    _save();
    notifyListeners();
  }

  void deleteTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    _lastDeleted = _tasks[idx].copy();
    _lastDeletedIndex = idx;

    _tasks.removeAt(idx);
    _save();
    notifyListeners();
  }

  void undoDelete() {
    if (_lastDeleted == null || _lastDeletedIndex == null) return;
    final index = _lastDeletedIndex!.clamp(0, _tasks.length);
    _tasks.insert(index, _lastDeleted!);
    _lastDeleted = null;
    _lastDeletedIndex = null;
    _save();
    notifyListeners();
  }

  void clearCompleted() {
    _tasks.removeWhere((t) => t.isDone);
    _save();
    notifyListeners();
  }

  // Filters/search/sort
  void setFilter(TaskFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setSort(TaskSort s) {
    _sort = s;
    notifyListeners();
  }

  // Reorder (only meaningful when sort = manual)
  void reorder(int oldIndex, int newIndex) {
    if (_sort != TaskSort.manual) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    _save();
    notifyListeners();
  }

  // Theme
  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _darkMode);
    notifyListeners();
  }

  // Persistence
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool(_themeKey) ?? false;

    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List;
      _tasks
        ..clear()
        ..addAll(decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}

import 'package:flutter/material.dart';

class Task {
  String title;
  bool isDone;
  Task({required this.title, this.isDone = false});
}

enum FilterType { all, active, done }

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  FilterType _filterType = FilterType.all;

  Task? _lastRemovedTask;
  int? _lastRemovedIndex;

  List<Task> get tasks {
    switch (_filterType) {
      case FilterType.active:
        return _tasks.where((task) => !task.isDone).toList();
      case FilterType.done:
        return _tasks.where((task) => task.isDone).toList();
      case FilterType.all:
        return _tasks;
    }
  }

  int get activeTaskCount => _tasks.where((task) => !task.isDone).length;

  void setFilter(FilterType filterType) {
    _filterType = filterType;
    notifyListeners();
  }

  void addTask(String title) {
    _tasks.add(Task(title: title));
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void deleteTask(Task task) {
    _lastRemovedIndex = _tasks.indexOf(task);
    _lastRemovedTask = task;
    _tasks.remove(task);
    notifyListeners();
  }

  void undoDelete() {
    if (_lastRemovedTask != null && _lastRemovedIndex != null) {
      _tasks.insert(_lastRemovedIndex!, _lastRemovedTask!);
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    final TextEditingController textFieldController = TextEditingController();

    void addTask() {
      if (textFieldController.text.length >= 3) {
        context.read<TaskProvider>().addTask(textFieldController.text);
        Navigator.of(context).pop();
      }
    }

    void showAddTaskDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Tugas Baru'),
            content: TextField(
              controller: textFieldController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas (min. 3 karakter)',
              ),
              onSubmitted: (_) => addTask(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(onPressed: addTask, child: const Text('Tambah')),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To-Do Mini'),
            // Jumlah tugas aktif
            Text(
              '${taskProvider.activeTaskCount} tugas belum selesai',
              style: const TextStyle(fontSize: 14.0, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Tombol filter
          PopupMenuButton<FilterType>(
            onSelected: (filter) {
              context.read<TaskProvider>().setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: FilterType.all, child: Text('Semua')),
              const PopupMenuItem(
                value: FilterType.active,
                child: Text('Aktif'),
              ),
              const PopupMenuItem(
                value: FilterType.done,
                child: Text('Selesai'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (_) {
                context.read<TaskProvider>().toggleTask(task);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone ? Colors.grey : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                context.read<TaskProvider>().deleteTask(task);

                // Snackbar + tombol undo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tugas dihapus'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        context.read<TaskProvider>().undoDelete();
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

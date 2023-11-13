import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tasks/data.dart';

const taskBoxName = 'tasks';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _box = Hive.box<Task>(taskBoxName);
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditTask()));
          },
          label: const Text('Add New Task')),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, box, child) {
          return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                final task = box.values.toList()[index];
                return Text(task.name);
              });
        },
      ),
    );
  }
}

class EditTask extends StatelessWidget {
  EditTask({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final task = Task();
            task.name = _controller.text;
            task.priority = Priority.low;
            if (task.isInBox) {
              task.save();
            } else {
              final Box<Task> box = Hive.box(taskBoxName);
              box.add(task);
            }
            Navigator.of(context).pop();
          },
          label: const Text('SAVE')),
      body: Column(
        children: [
          TextField(
              decoration:
                  const InputDecoration(label: Text('Add Task For Today')),
              controller: _controller)
        ],
      ),
    );
  }
}

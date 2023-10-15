import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'main_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = myApp_theme.dark();
    return MaterialApp(
      title: 'Task Manager',
      theme: theme,
      home: MyHomePage(),
    );
  }
}

// CLAIRE MAHON
class MyAppState extends ChangeNotifier {
  var tasks = <Task>[];
  var tasksCompleted = <Task>[];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime today = DateTime.now();
  final TextEditingController dateController = TextEditingController();

  void addTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
              ),
              onSubmitted: (value) {
                FocusScope.of(context).nextFocus();
              },
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Enter Date",
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      pickedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    }
                    String formattedDate =
                        DateFormat('yyyy-MM-dd, HH:mm').format(pickedDate);
                    dateController.text = formattedDate;
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final description = descriptionController.text;
              final date = dateController.text;
              final task =
                  Task(title: title, description: description, date: date);

              tasks.add(task);
              notifyListeners(); // Notify listeners to update the UI
              Navigator.pop(context);
              titleController.clear();
              descriptionController.clear();
              dateController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void moveToCompleted(Task task) {
    tasks.remove(task);
    tasksCompleted.add(task);
    notifyListeners();
  }

  void moveToPending(Task task) {
    tasksCompleted.remove(task);
    tasks.add(task);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = pending_actions();
        break;
      case 1:
        page = completed_tasks();
        break;
      default:
        throw UnimplementedError("No page found for index $selectedIndex");
    }
    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return LayoutBuilder(
      builder: (context, constrains) {
        final bool isLargeScreen = constrains.maxWidth > 600;
        if (constrains.maxWidth < 600) {
          return MaterialApp(
            home: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: page,
                  ),
                  BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.pending_actions),
                        label: 'Pending Actions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.task_alt),
                        label: 'Completed Tasks',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: onItemTapped,
                  ),
                ],
              ),
              appBar: AppBar(
                title: Text('Task Manager'),
              ),
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NavigationRail(
                    extended: isLargeScreen,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.pending_actions),
                        label: Text('Pending Actions'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.task_alt),
                        label: Text('Completed Tasks'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                  Expanded(child: page),
                ],
              ),
              appBar: AppBar(
                title: Text('Task Manager'),
              ),
            ),
          );
        }
      },
    );
  }
}

class pending_actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var tasks = appState.tasks;

    return Theme(
      data: myApp_theme.light(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            appState.addTask(context);
          },
          label: const Text('Add'),
          icon: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return SizedBox(
              height: 82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigCard(
                    task: task,
                    trailing: IconButton(
                      icon: const Icon(Icons.check_box_outline_blank),
                      onPressed: () {
                        appState.moveToCompleted(task);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class completed_tasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var tasksCompleted = appState.tasksCompleted;

    return Theme(
      data: myApp_theme.light(),
      child: Scaffold(
        body: ListView.builder(
          itemCount: tasksCompleted.length,
          itemBuilder: (context, index) {
            final task = tasksCompleted[index];
            return SizedBox(
              height: 82,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigCard(
                    task: task,
                    trailing: IconButton(
                      icon: const Icon(Icons.check_box),
                      onPressed: () {
                        appState.moveToPending(task);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String description;
  final String date;

  Task({required this.title, required this.description, required this.date});
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.task,
    required this.trailing,
  });

  final Task task;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = myApp_theme.dark();
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: Color.fromARGB(255, 33, 143, 179),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${task.title}', style: style),
              Text('Description: ${task.description}', style: style),
              Text('Date: ${task.date}', style: style)
            ],
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}

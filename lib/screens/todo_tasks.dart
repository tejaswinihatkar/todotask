import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences package
import 'pomodoro_timer.dart';

class TodoTasksScreen extends StatefulWidget {
  const TodoTasksScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoTasksScreenState createState() => _TodoTasksScreenState();
}

class _TodoTasksScreenState extends State<TodoTasksScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<String>> _diaryNotes = {};

  // Method to load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTasks = prefs.getStringList('tasks');
    if (storedTasks != null) {
      setState(() {
        _tasks.clear();
        _tasks.addAll(
            storedTasks.map((taskString) => Map<String, dynamic>.from(
                jsonDecode(taskString) as Map<String, dynamic>)));
      });
    }
  }

  // Method to save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings = _tasks
        .map((task) => jsonEncode(task)) // Convert task to JSON string
        .toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  // Add a new task and save it locally
  void _addTask(String task, int duration) {
    setState(() {
      _tasks.add({'taskName': task, 'completed': false, 'duration': duration});
    });
    _taskController.clear();
    _durationController.clear();
    _saveTasks(); // Save updated tasks list locally
  }

  // Start the task (Pomodoro timer)
  void _startTask(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PomodoroTimer(
          taskName: _tasks[index]['taskName'],
          duration: _tasks[index]['duration'],
        ),
      ),
    );
  }

  // Toggle task completion status
  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
    _saveTasks(); // Save updated tasks list locally
  }

  // Delete a task and update local storage
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks(); // Save updated tasks list locally
  }

  // Save diary note for the selected day
  void _saveDiaryNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        if (_diaryNotes[_selectedDate] == null) {
          _diaryNotes[_selectedDate] = [];
        }
        _diaryNotes[_selectedDate]?.add(_noteController.text);
        _noteController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do Tasks'),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.teal[50],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                      });
                    },
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your note for the day...',
                          filled: true,
                          fillColor: Color.fromARGB(255, 89, 224, 210),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveDiaryNote,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        child: const Text('Save Note'),
                      ),
                      const SizedBox(height: 10),
                      if (_diaryNotes[_selectedDate] != null &&
                          _diaryNotes[_selectedDate]!.isNotEmpty)
                        ..._diaryNotes[_selectedDate]!
                            .map((note) => ListTile(
                                  title: Text(note),
                                  tileColor: Colors.teal[100],
                                )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Add a task',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Duration (min)',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.teal),
                        onPressed: () {
                          if (_taskController.text.isNotEmpty &&
                              _durationController.text.isNotEmpty) {
                            _addTask(
                              _taskController.text,
                              int.parse(_durationController.text),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _tasks[index]['taskName'],
                          style: TextStyle(
                            color: Colors.black,
                            decoration: _tasks[index]['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          '${_tasks[index]['duration']} minutes',
                          style: const TextStyle(color: Colors.black),
                        ),
                        leading: Checkbox(
                          value: _tasks[index]['completed'],
                          onChanged: (value) => _toggleTaskCompletion(index),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.green),
                              onPressed: () => _startTask(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                      );
                    },
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

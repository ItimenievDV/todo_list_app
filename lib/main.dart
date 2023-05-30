import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const TodoListApp());
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _todoList = [];
  final List<String> _completedList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moveToCompleted(int index) {
    setState(() {
      String task = _todoList.removeAt(index);
      _completedList.add(task);
    });
  }

  void _moveToTodoList(int index) {
    setState(() {
      String task = _completedList.removeAt(index);
      _todoList.add(task);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return picked;
  }

  Widget _buildTaskItem(String task, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _moveToCompleted(index);
            },
            backgroundColor: Colors.green,
            icon: Icons.done,
            label: 'Done',
          ),
          SlidableAction(
            onPressed: (context) {},
            backgroundColor: Colors.grey,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              _deleteTask(index);
            },
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: Card(
        child: ListTile(
          title: Text(_todoList[index]),
          // subtitle: Text('Date: ${_selectDate(context).toString()}'),
        ),
      ),
    );
  }

  Widget _buildDoneTaskItem(String task, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _moveToTodoList(index);
            },
            backgroundColor: Colors.blue,
            icon: Icons.undo,
            label: 'Undo',
          )
        ],
      ),
      child: Card(
        child: ListTile(title: Text(_completedList[index])),
        // subtitle: Text('Date: ${task.date.toString()}'),
      ),
    );
  }

  Widget _buildTodoTaskList(List<String> taskList) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(taskList[index], index);
      },
    );
  }

  Widget _buildDoneTaskList(List<String> taskList) {
    return ListView.builder(
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return _buildDoneTaskItem(taskList[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[200],
      appBar: AppBar(
        backgroundColor: Colors.purple[400],
        title: const Text('Todo List'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To do'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodoTaskList(_todoList),
          _buildDoneTaskList(_completedList),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController textEditingController =
                        TextEditingController();
                    DateTime? selectedDate;
                    return AlertDialog(
                      title: const Text('Add task'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: textEditingController,
                            decoration: const InputDecoration(
                              labelText: 'write here',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Date:'),
                              Text(
                                selectedDate != null
                                    ? selectedDate.toString()
                                    : 'Chose date',
                              ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  DateTime? date = await _selectDate(context);
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (textEditingController.text.isNotEmpty &&
                                selectedDate != null) {
                              setState(() {
                                _todoList.add(textEditingController.text);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

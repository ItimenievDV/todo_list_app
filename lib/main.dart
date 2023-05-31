import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  List<TodoItem> todoItems = [];
  List<TodoItem> completedItems = [];

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

  void markAsDone(TodoItem item) {
    setState(() {
      todoItems.remove(item);
      completedItems.add(item);
    });
  }

  void moveToTodoList(TodoItem item) {
    setState(() {
      completedItems.remove(item);
      todoItems.add(item);
    });
  }

  void deleteItem(TodoItem item) {
    setState(() {
      if (todoItems.contains(item)) {
        todoItems.remove(item);
      } else if (completedItems.contains(item)) {
        completedItems.remove(item);
      }
    });
  }

  void addNewTodoItem(String title, String description, File? image) {
    setState(() {
      todoItems.add(TodoItem(title, description, image: image));
    });
  }

  void updateTodoItem(
      TodoItem item, String newTitle, String newDescription, File? newImage) {
    setState(() {
      item.title = newTitle;
      item.description = newDescription;
      item.image = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            ListView.builder(
              itemCount: todoItems.length,
              itemBuilder: (BuildContext context, int index) {
                TodoItem item = todoItems[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        label: 'Done',
                        backgroundColor: Colors.green,
                        icon: Icons.done,
                        onPressed: (context) {
                          markAsDone(item);
                        },
                      ),
                      SlidableAction(
                        label: 'Edit',
                        backgroundColor: Colors.grey,
                        icon: Icons.edit,
                        onPressed: (context) {
                          final picker = ImagePicker();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController titleController =
                                  TextEditingController(text: item.title);
                              TextEditingController descriptionController =
                                  TextEditingController(text: item.description);
                              File? newImage;
                              Future<void> getImage() async {
                                final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    newImage = File(pickedFile.path);
                                  });
                                }
                              }

                              return AlertDialog(
                                title: const Text('Edit task'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Title',
                                      ),
                                    ),
                                    TextField(
                                      controller: descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: getImage,
                                    child: const Text('Change image'),
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      String newTitle = titleController.text;
                                      String newDescription =
                                          descriptionController.text;
                                      updateTodoItem(item, newTitle,
                                          newDescription, newImage);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      SlidableAction(
                        label: 'Delete',
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        onPressed: (context) {
                          deleteItem(item);
                        },
                      )
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.description),
                      leading: item.getImageWidget(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoDetailScreen(item),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: completedItems.length,
              itemBuilder: (BuildContext context, int index) {
                TodoItem item = completedItems[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          moveToTodoList(item);
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.undo,
                        label: 'Undo',
                      )
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.description),
                        leading: item.getImageWidget()),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: () {
                  final picker = ImagePicker();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController titleController =
                          TextEditingController();
                      TextEditingController descriptionController =
                          TextEditingController();
                      File? image;

                      Future<void> getImage() async {
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            image = File(pickedFile.path);
                          });
                        }
                      }

                      return AlertDialog(
                        title: const Text('Add task'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (image != null) Image.file(image!),
                            ElevatedButton(
                              onPressed: getImage,
                              child: const Text('Upload image'),
                            ),
                            TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                              ),
                            ),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Add'),
                            onPressed: () {
                              String title = titleController.text;
                              String description = descriptionController.text;
                              addNewTodoItem(title, description, image);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}

class TodoDetailScreen extends StatelessWidget {
  final TodoItem item;

  const TodoDetailScreen(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task description')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.image != null) Image.file(item.image!),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoItem {
  String title;
  String description;
  File? image;

  TodoItem(this.title, this.description, {this.image});

  Widget getImageWidget() {
    if (image != null) {
      return Image.file(image!);
    }
    return const SizedBox.shrink();
  }
}

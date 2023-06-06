import 'package:flutter/material.dart';
import 'package:todo_list_app/todo_item.dart';

class TodoDetailScreen extends StatelessWidget {
  final TodoItem item;

  const TodoDetailScreen(this.item, {Key? key}) : super(key: key);

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

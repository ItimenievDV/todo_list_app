import 'dart:io';
import 'package:flutter/material.dart';

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

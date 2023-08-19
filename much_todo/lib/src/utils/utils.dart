import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/utils/globals.dart';

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

extension StringExtensions on String? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  bool isNotNullOrEmpty() {
    return this != null && this!.isNotEmpty;
  }
}

void showSnackbar(String message, BuildContext context, {int milliseconds = 1500}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: milliseconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String? validNewTag(String? tagName, List<Tag> tags) {
  if (tagName == null || tagName.isEmpty) {
    return 'Name is required.';
  } else if (tags.any((x) => x.name == tagName)) {
    return 'Tag already exists';
  } else {
    return null;
  }
}

String? validRoomName(String? name, List<Room> rooms) {
  if (name == null || name.isEmpty) {
    return 'Required';
  }
  if (rooms.any((r) => r.name == name)) {
    return 'Room name already exists';
  }
  return null;
}

String? validRoomEditName(String? name, String originalName, List<Room> rooms) {
  if (name != null && name == originalName) {
    return null;
  }

  if (name == null || name.isEmpty) {
    return 'Required';
  }
  if (rooms.any((r) => r.name == name)) {
    return 'Room name already exists';
  }
  return null;
}

String? validRoomNote(String? note) {
  if (note != null && note.length > Constants.maxRoomNoteLength) {
    return 'Note too large';
  }
  return null;
}

import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/utils/constants.dart';

String? validNewTag(String? tagName, List<Tag> tags) {
  if (tagName == null || tagName.isEmpty) {
    return 'Name is required.';
  } else if (tags.any((x) => x.name == tagName)) {
    return 'Tag already exists';
  } else {
    return null;
  }
}

String? validTaskName(String? name) {
  if (name == null || name.isEmpty) {
    return 'Required';
  }
  return null;
}

String? validTaskNote(String? note) {
  if (note == null && note!.length > Constants.maxTaskNoteLength) {
    return 'Required';
  }
  return null;
}

String? validRoomName(String? name) {
  if (name == null || name.isEmpty) {
    return 'Required';
  } else if (name.length > Constants.maxRoomNameLength) {
    return 'Name cannot be more than ${Constants.maxRoomNameLength} characters';
  }
  return null;
}

String? validRoomNote(String? note) {
  if (note != null && note.length > Constants.maxRoomNoteLength) {
    return 'Note too large';
  }
  return null;
}

String? validContactName(String? name) {
  if (name == null || name.isEmpty) {
    return 'Required';
  }
  return null;
}

String? validContactEmail(String? email) {
  if (email == null || email.isEmpty) {
    return null;
  }
  return null;
}

String? validContactPhoneNumber(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    return null;
  }
  return null;
}

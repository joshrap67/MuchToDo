import 'package:much_todo/src/repositories/api_request.dart';

class CreateRoomRequest implements ApiRequest {
  String name;
  String? note;

  CreateRoomRequest(this.name, this.note);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'CreateRoomRequest{name: $name, note: $note}';
  }
}

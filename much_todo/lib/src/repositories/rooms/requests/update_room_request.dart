import 'package:much_todo/src/repositories/api_request.dart';

class UpdateRoomRequest implements ApiRequest {
  String name;
  String? note;

  UpdateRoomRequest(this.name, this.note);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'note': note,
    };
  }

  @override
  String toString() {
	  return 'UpdateRoomRequest{name: $name, note: $note}';
  }
}

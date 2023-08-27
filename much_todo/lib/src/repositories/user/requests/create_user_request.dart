import 'package:much_todo/src/repositories/api_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';

class CreateUserRequest implements ApiRequest {
  List<CreateRoomRequest> rooms = [];

  CreateUserRequest(this.rooms);

  @override
  Map<String, dynamic> toJson() {
    return {
      'rooms': rooms.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CreateUserRequest{rooms: $rooms}';
  }
}

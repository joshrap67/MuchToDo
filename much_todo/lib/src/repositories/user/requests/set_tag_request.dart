import 'package:much_todo/src/repositories/api_request.dart';

class SetTagRequest implements ApiRequest {
  String name;

  SetTagRequest(this.name);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  @override
  String toString() {
    return 'SetTagRequest{name:$name}';
  }
}

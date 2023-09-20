import 'package:much_todo/src/repositories/api_request.dart';

class SetRoomFavoriteRequest implements ApiRequest {
  bool isFavorite;

  SetRoomFavoriteRequest(this.isFavorite);

  @override
  Map<String, dynamic> toJson() {
    return {'isFavorite': isFavorite};
  }

  @override
  String toString() {
    return 'SetRoomFavoriteRequest{isFavorite: $isFavorite}';
  }
}

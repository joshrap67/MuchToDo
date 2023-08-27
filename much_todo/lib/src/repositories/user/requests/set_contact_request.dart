import 'package:much_todo/src/repositories/api_request.dart';

class SetContactRequest implements ApiRequest {
  String name;
  String? email;
  String? phoneNumber;

  SetContactRequest(this.name, this.email, this.phoneNumber);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'SetContactRequest{name:$name, email: $email, phoneNumber: $phoneNumber}';
  }
}

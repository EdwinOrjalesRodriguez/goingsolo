import 'package:going_solo/main.dart';

class Friend {
  final String name;
  final String phone;
  final String email;
  final String avatarURL;
  final String type;
  final String cID;

  const Friend({this.name = "", required this.phone, required this.avatarURL, required this.type, required this.email, required this.cID});
  factory Friend.fromRTDB(Map<dynamic,dynamic> data, cID) {
    return Friend(
        name: data["name"],
        phone: data["phone"],
        email: data["email"] ?? "",
        avatarURL: data["avatarURL"] ?? defaultAvatarURL,
        type: data["type"] ?? "Mobile",
        cID: cID
    );
  }
}
import 'dart:io';

import 'package:uuid/uuid.dart';

class UserAvatar {
  UserAvatar({id, required this.email, required this.avatar})
      : id = id ?? Uuid().v4();

  final String id;
  final String email;
  final File avatar;
}

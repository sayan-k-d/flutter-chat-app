import 'dart:io';

import 'package:chat_app/models/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  // final dbFile = File(path.join(dbPath, 'userimages.db'));
  // if (await dbFile.exists()) {
  //   await dbFile.delete(); // Deletes the existing database
  //   print("Deleted DB");
  // }
  final db = sql.openDatabase(
    path.join(dbPath, 'userimages.db'),
    onCreate: (db, version) async {
      print("Creating Table");
      final table = await db.execute(
          'CREATE TABLE user_image(id TEXT PRIMARY KEY, email TEXT, image TEXT)');
      print("Table created successfully.");
      return table;
    },
    version: 1,
  );
  return db;
}

class AvatarNotifier extends StateNotifier<List<UserAvatar>> {
  AvatarNotifier() : super(const []);

  void saveImage({required File image, required String email}) async {
    final appPath = await getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    final copiedImage = await image.copy('${appPath.path}/$filename');
    final newImage = UserAvatar(email: email, avatar: copiedImage);

    final db = await _getDatabase();
    await db.insert('user_image', {
      'id': newImage.id,
      'email': newImage.email,
      'image': newImage.avatar.path,
    });
    state = [...state, newImage];
  }

  Future<List<UserAvatar>> loadImage({required String email}) async {
    final db = await _getDatabase();
    final data =
        await db.query('user_image', where: 'email =?', whereArgs: [email]);
    return data.map((row) {
      return UserAvatar(
        id: row['id'] as String,
        email: row['email'] as String,
        avatar: File(row['image'] as String),
      );
    }).toList();
  }
}

final avatarProvider = StateNotifierProvider<AvatarNotifier, List<UserAvatar>>(
  (ref) => AvatarNotifier(),
);

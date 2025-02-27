import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(this.email, {super.key});
  final String email;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // late Future<void> _images;
  // @override
  // void initState() {
  //   super.initState();
  //   _images = ref.read(avatarProvider.notifier).loadImage(email: widget.email);
  // }
  void getMessagesPermission() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token = await fcm.getToken();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    getMessagesPermission();
  }

  @override
  Widget build(BuildContext context) {
    // final images = ref.watch(avatarProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat Application"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: "Logout",
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessages(),
          ],
        )

        // FutureBuilder(
        //   future: _images,
        //   builder: (context, snapshot) {
        //     return snapshot.connectionState == ConnectionState.waiting
        //         ? const Text("Logged In Without Image..")
        //         : Center(
        //             child: Column(
        //               children: images.map((image) {
        //                 return CircleAvatar(
        //                   backgroundImage: FileImage(
        //                     image.avatar,
        //                   ),
        //                   radius: 40,
        //                 );
        //               }).toList(),
        //             ),
        //           );
        //   },
        // ),
        );
  }
}

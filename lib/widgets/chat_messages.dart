import 'dart:io';

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessages extends ConsumerWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Messages Found!"),
          );
        }
        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 20, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentUserId = chatMessage['userId'];
            final nextUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final isNextUserSame = currentUserId == nextUserId;
            final profilePicture = File(chatMessage['profilePicture']);
            // final userImageAsync = ref.watch(avatarProvider.notifier).loadImage(
            //       email: currentUser.email!,
            //     );

            if (isNextUserSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: currentUser.uid == currentUserId,
              );
            } else {
              return MessageBubble.first(
                message: chatMessage['text'],
                username: chatMessage['username'],
                isMe: currentUser.uid == currentUserId,
                profilePicture: profilePicture,
              );
            }
          },
        );
      },
    );
  }
}

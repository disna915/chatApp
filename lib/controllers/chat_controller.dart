import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  // Function to get chat ID (combination of both UIDs)
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '${user1}_$user2' : '${user2}_$user1';
  }

  // Fetch messages in real-time
  void loadMessages(String receiverId) {
    String chatId = getChatId(auth.currentUser!.uid, receiverId);
    firestore.collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    String chatId = getChatId(auth.currentUser!.uid, receiverId);
    Map<String, dynamic> messageData = {
      'senderId': auth.currentUser!.uid,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await firestore.collection('chats').doc(chatId).collection('messages').add(messageData);
  }
}

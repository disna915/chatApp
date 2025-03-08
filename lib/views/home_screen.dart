import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import '../../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF219ebc),
      appBar: AppBar(
        title: const Text("Chat App",style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF219ebc)
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((user) {
              bool isCurrentUser = user['email'] == authController.emailse;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF023047),
                    child: Text(
                      user['email'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    isCurrentUser ? "${user['email']} (You)" : user['email'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF023047),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        user['status'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: user['status'] == "Online" ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.message, color: Color(0xFFfb8500)),
                  onTap: () {
                    if (!isCurrentUser) {
                      Get.to(() => ChatScreen(
                        receiverId: user['uid'],
                        receiverEmail: user['email'],
                      ));
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/auth/login_screen.dart';
import '../views/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  String emailse= "";

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    firebaseUser.bindStream(auth.authStateChanges());
    super.onInit();
  }

  void register(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'status': 'Online',
      });

      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .update({'status': 'Online'});
      emailse = email;
      Get.offAll(() => HomeScreen());
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
      print("hhhhhhhhhhhhhhh"+e.toString());
    }
  }



  void logout() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'status': 'Offline'});
    await auth.signOut();
    Get.offAll(() => LoginScreen());
  }
}

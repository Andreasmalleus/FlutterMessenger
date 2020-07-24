import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{

  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> signOut();

  Future<void> updateEmail(String email,);

  Future<void> reAuthenticate(String password, String email);
}

class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async{
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    ).catchError((error) => print("Sign in error: $error"));
    return result.user.uid;
  }

  Future<String> signUp(String email, String password) async{
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password
    ).catchError((error) => print("Sign up error: $error"));
    return result.user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateEmail(String email) async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.updateEmail(email).catchError((error) => print("updateEmail error: $error"));
  }

  Future<void> reAuthenticate(String password, String email) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).
    catchError((error) => print("reAuthenticate error: $error"));
  }

}
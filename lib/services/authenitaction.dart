import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{

  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> signOut();

  Future<void> updateEmail(String email);

}

class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async{
    String errorMessage;
    String userId;

    try{
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    userId = result.user.uid;
    }catch(error){
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }
    if(errorMessage != null){
      return Future.error(errorMessage);
    }
    return userId;
  }

  Future<String> signUp(String email, String password) async{
    String errorMessage;
    String userId;

    try{
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password);
      userId = result.user.uid;
    }catch(error){
      switch (error.code) {
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Anonymous accounts are not enabled";
          break;
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Your password is too weak";
          break;
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email is invalid";
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = "Email is already in use on different account";
          break;
        case "ERROR_INVALID_CREDENTIAL":
          errorMessage = "Your email is invalid";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }

    if(errorMessage != null){
      return Future.error(errorMessage);
    }
    return userId;
  }

  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateEmail(String email) async{
    FirebaseUser user;
    String errorMessage;
    try{
      FirebaseUser user = await _firebaseAuth.currentUser();
      await user.updateEmail(email);
    }catch(error){
      switch (error.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
          errorMessage = "Email is already in use on different account";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
    }
    
    if(errorMessage != null){
      return Future.error(errorMessage);
    }
    return user;

  }

}
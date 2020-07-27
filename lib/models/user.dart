import 'package:firebase_database/firebase_database.dart';

class User{
  final String id;
  final String email;
  final String username;
  final String createdAt;
  final String imageUrl;

  User({
    this.id,
    this.email,
    this.username,
    this.createdAt,
    this.imageUrl
  });

  factory User.fromFirebase(DataSnapshot snapshot){
    Map data = snapshot.value;
    return User(
      id: snapshot.key,
      imageUrl: data["imageUrl"],
      createdAt: data["createdAt"],
      username: data["username"],
      email: data["email"]
    );
  }

}


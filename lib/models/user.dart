import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory User.fromFirestore(DocumentSnapshot snapshot){
    return User(
      id: snapshot.documentID ?? '',
      imageUrl: snapshot["imageUrl"] ?? '',
      createdAt: snapshot["createdAt"]?? '',
      username: snapshot["username"]?? '',
      email: snapshot["email"]?? ''
    );
  }

  toJson(){
    return {
      "imageUrl" : imageUrl,
      "createdAt": createdAt,
      "username": username,
      "email": email
    };
  }

}


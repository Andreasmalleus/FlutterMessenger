import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';

class Message{
  final String id;
  final String type;
  final User sender;
  final String time; //DateTime
  final String content;
  final bool isRead;
  final bool isLiked;

  Message({
    this.id,
    this.type,
    this.sender,
    this.time,
    this.content,
    this.isRead,
    this.isLiked
  });

  factory Message.fromFirestore(DocumentSnapshot data){
    User sender = User(
      id: data["sender"]["id"]?? '',
      username: data["sender"]["username"]?? '',
      email: data["sender"]["email"]?? '',
      imageUrl : data["sender"]["imageUrl"]?? '',
      createdAt: data["sender"]["createdAt"]?? '',
    );
    Message message = Message(
      id: data.documentID,
      type: data["type"]?? '',
      sender : sender?? '',
      time : data["time"]?? '',
      content : data["content"]?? '',
      isRead : data["isRead"]?? '',
      isLiked : data["isLiked"]?? '',
    );
    return message;
  }

  toJson(){
    return {
      "type" : type,
      "sender" : {
        "id" : sender.id,
        "username": sender.username,
        "email" : sender.email,
        "imageUrl" : sender.imageUrl,
        "createdAt" : sender.createdAt
      },
      "time" : time,
      "content" : content,
      "isRead" : isRead,
      "isLiked" : isLiked
    };

  }

}
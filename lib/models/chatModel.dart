import 'package:firebase_database/firebase_database.dart';

class Chat{
  String id;
  String lastMessage;
  String lastMessageTime;
  String participant;

  Chat({
    this.id,
    this.lastMessage,
    this.lastMessageTime,
    this.participant,
  });

  factory Chat.fromFirebase(DataSnapshot snapshot){
    Map data = snapshot.value;
    return Chat(
      id: snapshot.key,
      lastMessage: data["lastMessage"],
      lastMessageTime: data["lastMessageTime"],
      participant:  data["particpants"]
    );
  }
}
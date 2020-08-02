import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  String id;
  String lastMessage;
  String lastMessageTime;
  List<String> participants;

  Chat({
    this.id,
    this.lastMessage,
    this.lastMessageTime,
    this.participants,
  });

  factory Chat.fromFirestore(DocumentSnapshot data){
    return  Chat(
      id: data.documentID,
      lastMessage: data["lastMessage"] ?? '',
      lastMessageTime: data["lastMessageTime"] ?? '',
      participants: List.from(data["participants"]) ?? '',
    );
  }

  toJson(){
      return {
        "lastMessage" : lastMessage,
        "lastMessageTime" : lastMessageTime,
        "participants" : participants
      };
    }
}
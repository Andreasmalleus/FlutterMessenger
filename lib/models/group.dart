import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  String id;
  String name;
  String lastMessage;
  String lastMessageTime;
  String imageUrl;
  List<String> participants;
  List<String> admins;

  Group({
    this.id,
    this.name,
    this.lastMessage,
    this.lastMessageTime,
    this.imageUrl,
    this.participants,
    this.admins
  });

  factory Group.fromFirestore(DocumentSnapshot data){
    return  Group(
      id: data.documentID,
      name: data["name"] ?? '',
      lastMessage: data["lastMessage"] ?? '',
      lastMessageTime: data["lastMessageTime"] ?? '',
      imageUrl: data["imageUrl"] ?? '',
      participants: List.from(data["participants"]) ?? '',
      admins: List.from(data["admins"]) ?? '',
    );
  }

  toJson(){
      return {
        "name" : name,
        "lastMessage" : lastMessage,
        "lastMessageTime" : lastMessageTime,
        "imageUrl" : imageUrl,
        "participants" : participants,
        "admins" : admins
      };
    }

}
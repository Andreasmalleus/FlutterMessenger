import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';

abstract class BaseDb{
  Future<void> addUser(String userId,String email, String username, String createdAt, String imageUrl);

  Future<List> getAllUsers();

  Future<User> getCurrentUserObject(String id);

  Future<void> addMessage(String text, User sender, bool isRead, bool isLiked, String time);

  Future<Map> getAllMessages();

  Future<String> getLastMessage();

  Future<void> addFriends(String firstUserId, String secondUserId);

  Future<void> updateFriends(String firstUserId, String secondUserId);
    
  Future<List> getFriendsIds(String userId);

  Future<List> getFriends(String userId);
}

class Database implements BaseDb{
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child("users");
  final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child("messages");
  final DatabaseReference _friendsRef = FirebaseDatabase.instance.reference().child("friends");
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.reference().child("chats");
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.reference().child("groups");



  Future<void> addUser(String userId,String email, String username, String createdAt, String imageUrl) async{ 
    await _userRef.child(userId).set({
      "email" : email,
      "username" : username,
      "createdAt" : createdAt,
      "imageUrl" : imageUrl,
    });
    debugPrint("User added to database");
  }

  Future<List> getAllUsers() async{
    List<User> users = [];
    await _userRef.once().then((DataSnapshot snapshot) => { 
      snapshot.value.forEach((key, value){ 
          User user = User(
            id: key,
            email: value["email"],
            username: value["username"],
            createdAt: value["createdAt"],
            imageUrl: value["imageUrl"]
            );
          users.add(user);
      })
    }).catchError((error)  => print("getAllUsers error: $error"));
    print("All users received");
    return users;
  }

  Future<User> getCurrentUserObject(String id)async{
    User user;
    await _userRef.orderByKey().equalTo(id).once().then((DataSnapshot snapshot) =>{
      snapshot.value.forEach((key,value)=> {
        user = User(
          id: key,
          createdAt: value["createdAt"],
          username: value["username"],
          email: value["email"]
          )
      })
    });
    return user;
  }

  Future<void> addMessage(String text, User sender, bool isRead, bool isLiked, String time) async{
    await _messageRef.push().set({
      "text" : text,
      "sender" : {
        "id": sender.id,
        "email": sender.email,
        "username": sender.username,
        "createdAt": sender.createdAt,
        "imageUrl": sender.imageUrl
      },
      "isRead" : isRead,
      "isLiked" : isLiked,
      "time" : time,
    }).catchError((error) => print("addmessage error: $error"));
    print("Message added");
  }

  Future<Map> getAllMessages() async{
    Map<dynamic, dynamic> messages;
    await _messageRef.once().then((DataSnapshot snapshot) => {
      messages = snapshot.value
    }).catchError((error)  => print("getAllMessages error: $error"));
    print("All messages received");
    return messages;
  }

  Future<String> getLastMessage() async {
    String message = "";
    await _messageRef.orderByKey().limitToLast(1).once().then((DataSnapshot snapshot) => {
      snapshot.value.forEach((key, value) => message = value["message"])
    });
    return message;
  }

  Future<void> addFriends(String firstUserId, String secondUserId)async{
    String first = firstUserId;
    String second = secondUserId;
    for(var i= 0; i < 2; i++){
      await _friendsRef.child('$first/$second').set(
        true
      );
      first = secondUserId;
      second = firstUserId;
    }
  }

  Future<void> updateFriends(String firstUserId, String secondUserId)async{
    
  }

  Future<List> getFriendsIds(String userId)async{
    List<String> ids =List<String>();
    await _friendsRef.orderByKey().equalTo(userId).once().then((DataSnapshot snapshot) => {
      snapshot.value.forEach((key,value) => {
        value.forEach((key,value) => ids.add(key))
      }),
    });
    return ids;
  }

  Future<List> getFriends(String userId)async{
    List<User> friends = List<User>();
    List<String> ids = await getFriendsIds(userId);
    User user;
    for(var id in ids){
      await _userRef.orderByKey().equalTo(id).once().then((DataSnapshot snapshot) => {
        snapshot.value.forEach((key,value) =>{
          user = User(
            id: value["id"],
            username: value["username"],
            email: value["email"],
            createdAt: value["createdAt"],
            imageUrl: value["imageUrl"]
           ),
           friends.add(user)
        })
      });
    }
    return friends;
  }
}
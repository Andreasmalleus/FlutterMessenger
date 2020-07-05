import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chatModel.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/userModel.dart';

abstract class BaseDb{

  DatabaseReference getGroupRef();

  DatabaseReference getChatRef();

  DatabaseReference getMessageRef();

  Future<void> addUser(String userId,String email, String username, String createdAt, String imageUrl);

  Future<List> getAllUsers();

  Future<User> getUserObject(String id);

  Future<void> addMessage(String text, User sender, bool isRead, bool isLiked, String time, String key);

  Future<Map> getAllMessages(String key);

  Future<String> getLastMessage();

  Future<void> addFriends(String firstUserId, String secondUserId);

  Future<void> unFriend(String firstUserId, String secondUserId);

  Future<void> updateFriends(String firstUserId, String secondUserId);
    
  Future<List> getFriendsIds(String userId);

  Future<List> getFriends(String userId);

  Future<void> createChat(String firstUserId, String secondUserId);

  Future<List> getChatsIdsWhereCurrentUserIs(String currentUserId);

  Future<List> getChats(String userId);

  Future<void> updateLastMessageAndTime(String key, String message, String time, bool typeCheck);

  Future<void> createGroup(List<String> ids,String groupName);

  Future<List> getGroupsIdsWhereCurrentUserIs(String currentUserId);
  
  Future<List> getGroups(String userId);

  Future<String> uploadImage(File file, String userId);

  Future<String> fetchImageUrl(String userId);

}

class Database implements BaseDb{
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child("users");
  final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child("messages");
  final DatabaseReference _friendsRef = FirebaseDatabase.instance.reference().child("friends");
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.reference().child("chats");
  final DatabaseReference _groupRef = FirebaseDatabase.instance.reference().child("groups");
  final StorageReference _storageRef = FirebaseStorage.instance.ref();
  

  DatabaseReference getGroupRef(){
    return _groupRef;
  }

  DatabaseReference getChatRef(){
    return _chatsRef;
  }

  DatabaseReference getMessageRef(){
    return _messageRef;
  }

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

  Future<User> getUserObject(String id)async{
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

  Future<void> addMessage(String text, User sender, bool isRead, bool isLiked, String time, String key) async{
    await _messageRef.child(key).push().set({
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

  Future<Map> getAllMessages(String key) async{
    Map<dynamic, dynamic> messages;
    await _messageRef.child(key).once().then((DataSnapshot snapshot) => {
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

  Future<void> unFriend(String firstUserId, String secondUserId) async{
    String first = firstUserId;
    String second = secondUserId;
    for(var i= 0; i < 2; i++){
      await _friendsRef.child(first).child(second).remove();
      first = secondUserId;
      second = firstUserId;
    }
    print("Friend removed");
  }

  Future<void> updateFriends(String firstUserId, String secondUserId)async{
    
  }

  Future<List> getFriendsIds(String userId)async{
    List<String> ids =List<String>();
    await _friendsRef.orderByKey().equalTo(userId).once().then((DataSnapshot snapshot) => {
      snapshot.value.forEach((key,value) => {
        value.forEach((id,value) => {
            ids.add(id),
        }),
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
            id: key,
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

  Future<void> createChat(String firstUserId, String secondUserId) async{
    String key = _chatsRef.push().key;
    await _chatsRef.child(key).set({
      "lastMessage" : "",
      "lastMessageTime" : "",
      "participants" : {
        firstUserId : true,
        secondUserId : true
      }
    });
    print("created $key");
  }

  Future<List> getChatsIdsWhereCurrentUserIs(String currentUserId) async{
    List<String> chatIds = List<String>();
    await _chatsRef.once().then((DataSnapshot snapshot) => {
      snapshot.value.forEach((id, value) => {
        value["participants"].forEach((key, value) => {
          if(key == currentUserId){
            print("found $id"),
            chatIds.add(id)
          }
        })
      })
    });
    return chatIds;
  }

  

  Future<List> getChats(String userId) async{
    List<String> chatIds = await getChatsIdsWhereCurrentUserIs(userId);
    List<Chat> chats = List<Chat>();
    Chat chat;
    for(var id in chatIds){
        await _chatsRef.orderByKey().equalTo(id).once().then((DataSnapshot snapshot) => {
        snapshot.value.forEach((key,val) =>{
          val["participants"].forEach((id, value) => {
            if(id != userId){
              chat = Chat(
                id: key,
                lastMessage: val["lastMessage"],
                lastMessageTime: val["lastMessageTime"],
                participant: id
            ),
            }
          }),
          chats.add(chat)
        })
      });
    }
    print("All chats received");
    return chats;
  } 

  Future<void> updateLastMessageAndTime(String key, String message, String time, bool typeCheck) async{
    if(typeCheck){
      await _chatsRef.child(key).update({
        "lastMessage" : message,
        "lastMessageTime" : time
      }).catchError((error) => print("updateLastMessageAndTime: $error"));
      print("Chat updated");
    }else{
      await _groupRef.child(key).update({
        "lastMessage" : message,
        "lastMessageTime" : time
      }).catchError((error) => print("updateLastMessageAndTime: $error"));
      print("Group updated");
    }
  }

  Future<void> createGroup(List<String> ids, String name) async{
    print(ids.toString());
    String key = _groupRef.push().key;
    print(key);
    await _groupRef.child(key).set(
      {
        "name" : name,
        "lastMessage" : "",
        "lastMessageTime" : "",
      }
    );
    for(String id in ids){
      _groupRef.child(key).child("participants/$id").set(
        true
      );
    }
    print("Group created");
  }

    Future<List> getGroupsIdsWhereCurrentUserIs(String currentUserId) async{
    List<String> groupIds = List<String>();
    await _groupRef.once().then((DataSnapshot snapshot) => {
      snapshot.value.forEach((id, value) => {
        value["participants"].forEach((key, value) => {
            print("found $id"),
            groupIds.add(id)
        })
      })
    });
    return groupIds;
  }

  Future<List> getGroups(String userId) async{
    List<String> groupIds = await getGroupsIdsWhereCurrentUserIs(userId);
    List<String> participantIds = List<String>();
    List<Group> groups = List<Group>();
    Group group;
    for(var id in groupIds){
        await _chatsRef.orderByKey().equalTo(id).once().then((DataSnapshot snapshot) => {
        snapshot.value.forEach((key,val) =>{
          val["participants"].forEach((id, value) => {
            participantIds.add(id),
              group = Group(
                id: key,
                lastMessage: val["lastMessage"],
                lastMessageTime: val["lastMessageTime"],
                participants: participantIds
            ),
          }),
          groups.add(group)
        })
      });
    }
    print("All chats received");
    return groups;
  } 

  Future<String> uploadImage(File file, String userId) async{
    StorageUploadTask uploadTask = _storageRef.child("users/$userId/images/profileImage").putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = await downloadUrl.ref.getDownloadURL();
    print("download url is $url");
    return url;
  }

  Future<String> fetchImageUrl(String userId) async{
    String url = await _storageRef.child("users/$userId/images/profileImage").getDownloadURL();
    return url;
  }

}
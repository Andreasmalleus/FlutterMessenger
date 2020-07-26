import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chatModel.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/storageFile.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/utils/utils.dart';

abstract class BaseDb{

  DatabaseReference getGroupRef();

  DatabaseReference getChatRef();

  DatabaseReference getMessageRef();

  DatabaseReference getUserRef();

  Future<void> addUser(String userId,String email, String username, String createdAt, String imageUrl);

  Future<void> updateUsername(String userId, String newUsername);

  Future<bool> checkIfValueAlreadyExists(String newValue, String key);

  Future<void> updateEmail(String userId, String newEmail); 

  Future<List> getAllUsers();

  Future<User> getUserObject(String id);

  Future<void> addMessage(String message, User sender, bool isRead, bool isLiked, String time, String key, String type);

  Future<Map> getAllMessages(String key);

  Future<String> getLastMessage();

  Future<void> updateLastMessageAndTime(String key, String message, String time, bool typeCheck);

  Future<void> likeMessage(String chatId, String messageId);

  Future<void> dislikeMessage(String chatId, String messageId);

  Future<void> addFriends(String firstUserId, String secondUserId);

  Future<void> unFriend(String firstUserId, String secondUserId);

  Future<void> updateFriends(String firstUserId, String secondUserId);
    
  Future<List> getFriendsIds(String userId);

  Future<List> getFriends(String userId);

  Future<void> createChat(String firstUserId, String secondUserId);

  Future<List> getChatsIdsWhereCurrentUserIs(String currentUserId);

  Future<List> getChats(String userId);

  Future<void> removeChat(String userId);

  Future<void> createGroup(List<String> ids,String groupName, String adminId);

  Future<List> getGroupsIdsWhereCurrentUserIs(String currentUserId);
  
  Future<List> getGroups(String userId);

  Future<String> uploadUserImageToStorage(File file, String userId);

  Future<String> uploadGroupImageToStorage(File file, String groupId);

  Future<String> uploadFileToChatStorage(File file, String chatId, String userId,String fileName);

  Future<String> uploadFileToGroupStorage(File file, String chatId, String userId, String fileName);

  Future<String> fetchImageUrl(String userId);

  Future<void> updateUserImageUrl(String url, String userId);

  Future<void> updateGroupImageUrl(String url, String groupId);

  Future<List> listAllStorageFilesById(String chatId);

  Future<void> fileUrlToDatabase(String convId, String userId, String url, String fileName);

  Stream<User> streamUser(String id);

  Stream<dynamic> streamUsers();

}

class Database implements BaseDb{
  
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child("users");
  final DatabaseReference _messageRef = FirebaseDatabase.instance.reference().child("messages");
  final DatabaseReference _friendsRef = FirebaseDatabase.instance.reference().child("friends");
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.reference().child("chats");
  final DatabaseReference _groupRef = FirebaseDatabase.instance.reference().child("groups");
  final DatabaseReference _storageFilesRef = FirebaseDatabase.instance.reference().child("storageFiles");
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

  DatabaseReference getUserRef(){
    return _userRef;
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

  Future<void> updateUsername(String userId, String newUsername) async{
    await _userRef.child(userId).update({
      "username" : newUsername
    }).catchError((error) => print("updateUsername $error"));
  }

  
  Future<bool> checkIfValueAlreadyExists(String newValue, String key) async{
    bool _exists = false;
    await _userRef.once().then((DataSnapshot snapshot) => {
       snapshot.value.forEach((_, value) => { 
         if(value[key] == newValue){
           _exists = true
         }
      })
    });
    return _exists;
  }

  Future<void> updateEmail(String userId, String newEmail) async{
    await _userRef.child(userId).update({
      "email" : newEmail
    }).catchError((error) => print("updateEmail $error"));
  }

  Future<List> getAllUsers() async{
    List<User> users = [];
    User user;
    await _userRef.once().then((DataSnapshot snapshot) => { 
      snapshot.value.forEach((key, value) => { 
          user = User(
            id: key,
            email: value["email"],
            username: value["username"],
            createdAt: value["createdAt"],
            imageUrl: value["imageUrl"]
            ),
          users.add(user)
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
          imageUrl: value["imageUrl"],
          createdAt: value["createdAt"],
          username: value["username"],
          email: value["email"]
          )
      })
    });
    return user;
  }

  Future<void> addMessage(String message, User sender, bool isRead, bool isLiked, String time, String key, String type) async{
    await _messageRef.child(key).push().set({
      "type" : type,
      "message" : message,
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

  Future<void> likeMessage(String chatId, String messageId) async{
    await _messageRef.child(chatId).child(messageId).update({
      "isLiked" : true
    });
  }

  Future<void> dislikeMessage(String chatId, String messageId) async {
    await _messageRef.child(chatId).child(messageId).update({
      "isLiked" : false
    });
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

  Future<void> removeChat(String chatId) async{
    await _chatsRef.child(chatId).remove().catchError((e) => print("removeChat error: $e"));
    print("Chat removed");
  } 

  Future<void> createGroup(List<String> ids, String name, String adminId) async{
    print(ids.toString());
    String key = _groupRef.push().key;
    print(key);
    await _groupRef.child(key).set(
      {
        "name" : name,
        "lastMessage" : "",
        "lastMessageTime" : "",
        "imageUrl" : "",
        "createdAt" : getCurrentDate(),
        "admins" : {
          adminId : true
        }
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
                participants: participantIds,
                admins: val["admins"]
            ),
          }),
          groups.add(group)
        })
      });
    }
    print("All chats received");
    return groups;
  } 

  Future<String> uploadUserImageToStorage(File file, String userId) async{
    StorageUploadTask uploadTask = _storageRef.child("users/$userId/media/profileImage").putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadGroupImageToStorage(File file, String groupId) async{
    StorageUploadTask uploadTask = _storageRef.child("groups/$groupId/media/groupImage").putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadFileToChatStorage(File file, String chatId, String userId, String fileName) async{
    StorageUploadTask uploadTask = _storageRef.child("chats/$chatId/media/$userId/$fileName").putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadFileToGroupStorage(File file, String groupId, String userId, String fileName) async{
    StorageUploadTask uploadTask = _storageRef.child("groups/$groupId/media/$userId/$fileName").putFile(file);
    StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    String url = await downloadUrl.ref.getDownloadURL();
    return url;
  }

  Future<String> fetchImageUrl(String userId) async{
    String url = await _storageRef.child("users/$userId/media/profileImage").getDownloadURL();
    return url;
  }

  Future<void> updateUserImageUrl(String url, String userId) async {
    await _userRef.child(userId).update({
      "imageUrl" : url
    }).catchError((e) => print("uploadImageToDataBase: $e"));
  }

  Future<void> updateGroupImageUrl(String url, String groupId) async {
    await _groupRef.child(groupId).update({
      "imageUrl" : url
    }).catchError((e) => print("uploadImageToDataBase: $e"));
  }

  Future<void> fileUrlToDatabase(String convId, String userId, String url, String fileName) async{
    await _storageFilesRef.child("$convId/$userId/$fileName").set(url);
  }

  Future<List> listAllStorageFilesById(String chatId) async{
    List<StorageFile> files = List<StorageFile>();
    StorageFile file;
    DataSnapshot snapshot = await _storageFilesRef.orderByKey().equalTo(chatId).once();
    if(snapshot != null){
      snapshot.value.forEach((convId, val) => {
        val.forEach((userId, value) => {
          value.forEach((name, url) =>{
            file = StorageFile(
              userId: userId,
              name: name,
              url: url,
            ),
            files.add(file)
          })
        })
      });
    }
    return files;
  }


  Stream<User> streamUser(String id){
    return _userRef.child(id).onValue.map((event) => User.fromFirebase(event.snapshot));
  }

  Stream<dynamic> streamUsers(){
    return _userRef.onValue.map((list) => list.snapshot.value);
  }

}
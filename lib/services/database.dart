import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttermessenger/models/chat.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/message.dart';
import 'package:fluttermessenger/models/storage_file.dart';
import 'package:fluttermessenger/models/user.dart';
import 'dart:io';

abstract class BaseDb{

  Future<void> createUser(User user);

  Future<void> updateUsername(String userId, String username);

  Future<void> updateEmail(String userId, String email);

  Future<void> updateUserImageUrl(String userId, String imageUrl);

  Future<bool> checkIfValueAlreadyExists(String newValue, String key);

  Future<List> getAllUsers();

  Future<User> getUser(String id);

  Future<void> addMessage(String docId, Message message, bool isChat);

  Future<List> getAllMessages(String docId, bool isChat);

  Future<void> updateLastMessageAndTime(String docId, String message, String time, bool typeCheck);

  Future<void> likeMessage(String docId, String messageId, bool isChat);

  Future<void> dislikeMessage(String docId, String messageId, bool isChat);

  Future<void> addFriends(String firstUserId, String secondUserId);

  Future<void> unFriend(String firstUserId, String secondUserId);

  Future<List> getFriends(String userId);

  Future<void> createChat(Chat chat);

  Future<void> removeChat(String chatId);

  Future<void> createGroup(Group group);

  Future<void> leaveGroup(String groupId, String userId);

  Future<void> deleteGroup(String groupId);

  Future<void> kickMember(String groupId, String userId);
  
  Future<String> uploadUserImageToStorage(File file, String userId);

  Future<String> uploadGroupImageToStorage(File file, String groupId);

  Future<String> uploadFileToChatStorage(File file, String chatId, String userId,String fileName);

  Future<String> uploadFileToGroupStorage(File file, String chatId, String userId, String fileName);

  Future<String> fetchImageUrl(String userId);

  Future<void> updateGroupImageUrl(String imageUrl, String groupId);

  Future<void> fileUrlToDatabase(String docId, StorageFile storageFile, bool isChat);

  Future<List> listAllStorageFilesById(String docId, bool isChat);

  Stream<User> streamUser(String userId);

  Stream<List<User>> streamUsers();

  Stream<List<Chat>> streamChats(String userId);

  Stream<List<Group>> streamGroups(String userId);

  Stream<List<Message>> streamMessages(String id, bool isChat);

}

class Database implements BaseDb{
  
  final CollectionReference _userRef = Firestore.instance.collection("users");
  final CollectionReference _chatRef = Firestore.instance.collection("chats");
  final CollectionReference _groupRef = Firestore.instance.collection("group");
  final StorageReference _storageRef = FirebaseStorage.instance.ref();

  Future<void> createUser(User user) async{
    await _userRef.document(user.id).setData(user.toJson()).whenComplete(() => "User added");
  }

  Future<void> updateUsername(String userId, String username) async{
    await _userRef.document(userId).updateData({
      "username" : username
    }).whenComplete(() => "Username updated");
  }

  Future<void> updateEmail(String userId, String email) async{
    await _userRef.document(userId).updateData({
      "email" : email
    }).whenComplete(() => "Email updated");
  }

  Future<void> updateUserImageUrl(String userId, String imageUrl) async{
    await _userRef.document(userId).updateData({
      "imageUrl" : imageUrl
    }
    ).whenComplete(() => "ImageUrl updated");
  }

  Future<bool> checkIfValueAlreadyExists(String newValue, String key) async{
    bool _exists = false;
    final snap =  await _userRef.getDocuments();
    snap.documents.map((doc) => {
      doc[key] == newValue ? !_exists : _exists
    });
    return _exists;
  }

  Future<List> getAllUsers() async{
    final snapshot = await _userRef.getDocuments();
    return snapshot.documents.map((e) => User.fromFirestore(e)).toList();
  }

  Future<User> getUser(String userId) async{
    final doc = await _userRef.document(userId).get();
    return User.fromFirestore(doc);
  }

  Future<void> addMessage(String docId, Message message, bool isChat) async{
    if(isChat){
      await _chatRef.document(docId).collection("messages").add(message.toJson());
    }else{
      await _groupRef.document(docId).collection("messages").add(message.toJson());
    }
  }

  Future<List> getAllMessages(String docId, bool isChat) async{
    print("messages");
    List<Message> messages = List<Message>();
    QuerySnapshot snap;
    if(isChat){
      snap = await _chatRef.document(docId).collection("messages").getDocuments();
    }else{
      snap = await _groupRef.document(docId).collection("messages").getDocuments();
    }
    messages = snap.documents.map((doc) => Message.fromFirestore(doc)).toList();
    return messages;
  }

  Future<void> updateLastMessageAndTime(String docId, String message, String time, bool typeCheck) async{
    if(typeCheck){
      await _chatRef.document(docId).updateData({
        "lastMessage" : message,
        "lastMessageTime" : time
      });
    }else{
      await _groupRef.document(docId).updateData({
        "lastMessage" : message,
        "lastMessageTime" : time
      });
    }
  }

  Future<void> likeMessage(String docId, String messageId, bool isChat) async{
    if(isChat){
      await _chatRef.document(docId).collection("messages").document(messageId).updateData({
        "isLiked" : true
      });
    }else{
      await _groupRef.document(docId).collection("messages").document(messageId).updateData({
        "isLiked" : true
      });
    }
  }

  Future<void> dislikeMessage(String docId, String messageId, bool isChat) async{
    if(isChat){
      await _chatRef.document(docId).collection("messages").document(messageId).updateData({
        "isLiked" : false
      });
    }else{
      await _groupRef.document(docId).collection("messages").document(messageId).updateData({
        "isLiked" : false
      });
    }
  }

  Future<void> addFriends(String firstUserId, String secondUserId)async{
    await _userRef.document(firstUserId).collection("friends").document(secondUserId).setData(
      {"ref" : _userRef.document(secondUserId)});
    await _userRef.document(secondUserId).collection("friends").document(firstUserId).setData(
      {"ref" : _userRef.document(firstUserId)}
      );
  }

  Future<List> getFriends(String userId) async{
    List<User> friends = List<User>();
    User friend;
    final snap = await _userRef.document(userId).collection("friends").getDocuments();
    for(DocumentSnapshot doc in snap.documents){
      friend = User.fromFirestore(await doc["ref"].get());
      friends.add(friend);
    }
    return friends;
  }

  Future<void> unFriend(String firstUserId, String secondUserId) async{
    await _userRef.document(firstUserId).collection("friends").document(secondUserId).delete();
    await _userRef.document(firstUserId).collection("friends").document(secondUserId).delete();
  }

  Future<void> createChat(Chat chat) async{
    await _chatRef.document(chat.id).setData(chat.toJson())
    .whenComplete(() => "chat created");
  }

  Future<void> removeChat(String chatId) async{
    await _chatRef.document(chatId).delete()
    .whenComplete(() => "$chatId deleted");
  }

  Future<void> createGroup(Group group) async{
    await _groupRef.document(group.id).setData(group.toJson())
    .whenComplete(() => "group created");
  }

  Future<void> leaveGroup(String groupId, String userId) async{
    final doc = await _groupRef.document(groupId).get();
    if(doc.exists){
      List data = List.from(["participants"]);
      data.removeWhere((id) => id == userId);
      await _groupRef.document(groupId).setData({
        "participants" : data
      });
    }
  }

  Future<void> deleteGroup(String groupId) async{
    await _groupRef.document(groupId).delete()
    .whenComplete(() => "group created");
  }

  Future<void> kickMember(String groupId, String userId) async{
    final doc = await _groupRef.document(groupId).get();
    if(doc.exists){
      List data = List.from(["participants"]);
      data.removeWhere((id) => id == userId);
      await _groupRef.document(groupId).setData({
        "participants" : data
      });
    }
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

  Future<void> updateGroupImageUrl(String groupId, String imageUrl) async{
    await _groupRef.document(groupId).updateData({
      "imageUrl" : imageUrl
    }).whenComplete(() => "ImageUrl updated");
  }

  Future<void> fileUrlToDatabase(String docId, StorageFile storageFile, bool isChat) async{
    if(isChat){
      await _chatRef.document(docId).collection("media").add(storageFile.toJson());
    }else{
      await _groupRef.document(docId).collection("media").add(storageFile.toJson());
    }
  }

  Future<List> listAllStorageFilesById(String docId, bool isChat) async{
    List<StorageFile> files = List<StorageFile>();
    CollectionReference ref;
    print(docId);
    if(isChat){
      ref = _chatRef;
    }else{
      ref = _groupRef;
    }
    final snapshot = await ref.document(docId).collection("media").getDocuments();
    files = snapshot.documents.map((doc) => StorageFile.fromFirestore(doc)).toList();
    return files;
  }

  Stream<User> streamUser(String userId){
    return _userRef.document(userId).snapshots().map((DocumentSnapshot snapshot) => User.fromFirestore(snapshot));
  }

  Stream<List<User>> streamUsers(){
    return _userRef.snapshots().map((querySnap) => querySnap.documents.map((doc) => User.fromFirestore(doc)).toList());
  }

  Stream<List<Chat>> streamChats(String userId){
    return _chatRef.where("participants", arrayContains: userId).snapshots().map(
      (querySnap) => querySnap.documents.map<Chat>(
        (doc) => Chat.fromFirestore(doc)
      ).toList()
    );
  }

  Stream<List<Group>> streamGroups(String userId){
    return _groupRef.where("participants", arrayContains: userId).snapshots().map(
      (querySnap) => querySnap.documents.map<Group>(
        (doc) => Group.fromFirestore(doc)
      ).toList()
    );
  }

   Stream<List<Message>> streamMessages(String id, bool isChat){
    if(isChat){
      return _chatRef.document(id).collection("messages").snapshots().map((querySnap) =>querySnap.documents.map((doc) => Message.fromFirestore(doc)).toList());
    }else{
      return _groupRef.document(id).collection("messages").snapshots().map((querySnap) =>querySnap.documents.map((doc) => Message.fromFirestore(doc)).toList());
    }
  }
}
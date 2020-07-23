import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/database.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
//TODO create a page that fits for both groups and chats

class UserGroupPage extends StatefulWidget{

  final User user;
  final Group group;
  final BaseDb database;
  final String currentUserId;
  final String convTypeId;
  final bool isChat;
  

  UserGroupPage({this.user, this.database,this.currentUserId, this.convTypeId, this.isChat, this.group});

  @override
  _UserGroupPageState createState() => _UserGroupPageState();

}

class _UserGroupPageState extends State<UserGroupPage>{

  File file;

  void _unfriend() async{
    await widget.database.unFriend(widget.currentUserId, widget.user.id);
    await widget.database.removeChat(widget.convTypeId);
    _navigateToChatsPage();
  }

  void _navigateToChatsPage(){
    var nav = Navigator.of(context);
    nav.pop();
    nav.pop();
  }

  Widget _nicknamesButton(){
    return Container(
      child: Text("Nicknames"),
    );
  }

  Widget _peopleButton(){
    if(!widget.isChat){
      return Container(
        child: Text("People"),
      );  
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Widget _photosAndVideos(){
    return Container(
      child: Text("View photos and videos"),
    );
  }

  Widget _searchInConversation(){
    return Container(
      child: Text("Search in conversation"),
    );
  }

  Widget _block(){
    if(widget.isChat){
      return Container(
        child: Text("Block"),
      );  
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Widget _ignoreMessages(){
      return Container(
        child: Text("Ignore messages"),
      );  
  }

  Widget _unFriendOrLeave(){
    if(widget.isChat){
      return Container(
            child: RaisedButton(
              onPressed: () => {
                _unfriend()
              },
              child: Text("Unfriend", style: TextStyle(color: Colors.red),),
            ),
      );
    }else{
      return Container(
            child: RaisedButton(
              onPressed: () => {
                
              },
              child: Text("Leave", style: TextStyle(color: Colors.red),),
            ),
      );
    }
  }

  Widget _imageContainer(){
    if(widget.isChat){
      return Row(
        children: <Widget>[
        Container(
          child: 
            widget.user.imageUrl != ""
            ?  
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.user.imageUrl),
            )                 
            :
            Icon(Icons.account_circle, size: 90,)
          ),
        Container(
          child: Text(widget.user.username),
        )
      ],
      );
    }else{
      return Row(
        children: <Widget>[
        Container(
          child: 
            widget.group.imageUrl != ""
            ?  
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.group.imageUrl),
            )                 
            :
            Icon(Icons.account_circle, size: 90,)
          ),
        Container(
          child: Text(widget.group.name),
        )
      ],
      );
    }
  }

  void _uploadImage() async{
    String groupId = widget.group.id;
    String url = "";
    try{
      file = await FilePicker.getFile(type: FileType.image);
      url = await widget.database.uploadGroupImageToStorage(file, groupId);
      widget.database.updateGroupImageUrl(url, groupId);
      _navigateToChatsPage();
    }catch(e){
      print(e);
    }
  }

  Widget _uploadImageButton(){
    if(!widget.isChat){
      if(widget.group.admins.contains(widget.currentUserId)){
        return Container(
          child: RaisedButton(
            onPressed: () => _uploadImage(),
            child: Text("Upload image"),
          ),
        );
      }else{
        return Container(width: 0, height: 0,);
      }
    }else{
      return Container(width: 0, height: 0,);
    }
  }

  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
      return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isChat ? widget.user.username : widget.group.name
          ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _imageContainer(),
          _nicknamesButton(),
          _peopleButton(),
          Container(
            child: Text("More actions", style: TextStyle(color: Colors.grey, fontSize: 20),),
          ),
          _photosAndVideos(),
          _searchInConversation(),
          Container(
            child: Text("Privacy", style: TextStyle(color: Colors.grey, fontSize: 20),),
          ),
          _block(),
          _ignoreMessages(),
          _unFriendOrLeave(),
          _uploadImageButton(),
      ],),
    );
  }
}
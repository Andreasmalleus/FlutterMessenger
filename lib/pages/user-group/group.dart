import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/pages/user-group/media_collection.dart';
import 'package:fluttermessenger/pages/user-group/members.dart';
import 'package:fluttermessenger/pages/user-group/search_messages.dart';
import 'package:fluttermessenger/services/database.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
//TODO create a page that fits for both groups and chat

class GroupPage extends StatefulWidget{

  final Group group;
  final BaseDb database;
  final String currentUserId;  

  GroupPage({this.database,this.currentUserId, this.group});

  @override
  _GroupPageState createState() => _GroupPageState();

}

class _GroupPageState extends State<GroupPage>{

  File file;

  void _navigateToGroupsPage(){
    var nav = Navigator.of(context);
    nav.pop();
    nav.pop();
  }

  void _uploadImage() async{
    String groupId = widget.group.id;
    String url = "";
    try{
      file = await FilePicker.getFile(type: FileType.image);
      url = await widget.database.uploadGroupImageToStorage(file, groupId);
      widget.database.updateGroupImageUrl(groupId, url);
      _navigateToGroupsPage();
    }catch(e){
      print(e);
    }
  }

  void _leaveGroup() async{
    await widget.database.leaveGroup(widget.group.id, widget.currentUserId);
    _navigateToGroupsPage();
  }

  void _removeGroup() async{
    await widget.database.deleteGroup(widget.group.id);
    _navigateToGroupsPage();
  }

  Widget _uploadImageButton(){
    if(widget.group.admins.contains(widget.currentUserId)){
      return Container(
        alignment: Alignment.center,
        child: GestureDetector(
            onTap: () => _uploadImage(),
            child: Text("Upload a new image", style: TextStyle(fontSize: 15, color: Colors.white),),
        ),
      );
    }else{
      return Container(width: 0, height: 0,);
    }
  }

  Widget _removeGroupButton(){
    if(widget.group.admins.contains(widget.currentUserId)){
      return Container(
        child: GestureDetector(
          onTap: () => _removeGroup(),
          child: Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.remove, color: Colors.redAccent,),
                SizedBox(width: 5,),
                Text("Remove group", style: TextStyle(fontSize: 17, color: Colors.white),),
              ],
            ),
          ),
        )
      );
    }else{
      return Container(width: 0, height: 0,);
    }
  }

  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Color(0xff121212),
      appBar: AppBar(
        backgroundColor: Color(0xff2b2a2a),
        title: Text(
          widget.group.name
          ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  Icon(Icons.supervised_user_circle, size: 120, color: Colors.white,)
                ),
            ],),
          ),
          _uploadImageButton(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.grey,)
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MembersPage(database: widget.database, group: widget.group, currentUserId: widget.currentUserId,))),
                child: Container(
                  margin: EdgeInsets.only(left: 25, top: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.group, color: Colors.white,),
                      SizedBox(width: 5,),
                      Container(
                        child: Text("See group members", style: TextStyle(fontSize: 17, color: Colors.white),),
                      ),
                    ],
                  ),
                ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.grey,)
          ),
          Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            child: Text("More actions", style: TextStyle(color: Colors.white, fontSize: 20),),
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MediaCollectionPage(database: widget.database, typeId: widget.group.id, isChat: false,))),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.photo, color: Colors.white,),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("View photos and videos", style: TextStyle(fontSize: 17, color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => SearchMessagesPage(
                    title: widget.group.name,
                    database: widget.database,
                    typeId: widget.group.id,
                    isChat: false,
                    )
                )),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search, color: Colors.white,),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("Search in conversation", style: TextStyle(fontSize: 17, color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.grey,)
          ),
          Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            child: Text("Privacy", style: TextStyle(color: Colors.white, fontSize: 20),),
          ),
          Container(
            child: GestureDetector(
              onTap: () => print("Ignore Messages"),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.speaker_notes_off, color: Colors.redAccent,),
                    SizedBox(width: 5,),
                    Text("Ignore messages", style: TextStyle(fontSize: 17, color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () => _leaveGroup(),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.close, color: Colors.redAccent,),
                    SizedBox(width: 5,),
                    Text("Leave", style: TextStyle(fontSize: 17, color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
          _removeGroupButton()
      ],),
    );
  }
}
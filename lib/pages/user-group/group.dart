import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/pages/user-group/media_collection.dart';
import 'package:fluttermessenger/pages/user-group/nicknames.dart';
import 'package:fluttermessenger/pages/user-group/people.dart';
import 'package:fluttermessenger/pages/user-group/search_messages.dart';
import 'package:fluttermessenger/services/database.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
//TODO create a page that fits for both groups and chats

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
      widget.database.updateGroupImageUrl(url, groupId);
      _navigateToGroupsPage();
    }catch(e){
      print(e);
    }
  }

  Widget _uploadImageButton(){
    if(widget.group.admins.contains(widget.currentUserId)){
      return Container(
        alignment: Alignment.center,
        child: GestureDetector(
            onTap: () => _uploadImage(),
            child: Text("Upload a new image", style: TextStyle(fontSize: 15, color: Colors.blueAccent),),
        ),
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
      appBar: AppBar(
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
                  Icon(Icons.supervised_user_circle, size: 120, color: Colors.blueAccent,)
                ),
            ],),
          ),
          _uploadImageButton(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.blueAccent,)
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => NickNamesPage())),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Text("Aa", style: TextStyle(color: Colors.blueAccent,fontSize: 18, fontWeight: FontWeight.bold),),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("Nicknames", style: TextStyle(fontSize: 17),),
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
                  builder: (BuildContext context) => PeoplePage())),
                child: Container(
                  margin: EdgeInsets.only(left: 25, top: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.group, color: Colors.blueAccent,),
                      SizedBox(width: 5,),
                      Container(
                        child: Text("People", style: TextStyle(fontSize: 17),),
                      ),
                    ],
                  ),
                ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.blueAccent,)
          ),
          Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            child: Text("More actions", style: TextStyle(color: Colors.grey, fontSize: 20),),
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => MediaCollectionPage(database: widget.database, typeId: widget.group.id,))),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.photo, color: Colors.blueAccent,),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("View photos and videos", style: TextStyle(fontSize: 17),),
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
                    typeId: widget.group.id,)
                )),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search, color: Colors.blueAccent,),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("Search in conversation", style: TextStyle(fontSize: 17),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.blueAccent,)
          ),
          Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            child: Text("Privacy", style: TextStyle(color: Colors.grey, fontSize: 20),),
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
                    Text("Ignore messages", style: TextStyle(fontSize: 17),),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () => print("Leave"),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.close, color: Colors.redAccent,),
                    SizedBox(width: 5,),
                    Text("Leave", style: TextStyle(fontSize: 17),),
                  ],
                ),
              ),
            ),
          ),
      ],),
    );
  }
}
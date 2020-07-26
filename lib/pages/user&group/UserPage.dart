import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/pages/user&group/MediaCollection.dart';
import 'package:fluttermessenger/pages/user&group/Nicknames.dart';
import 'package:fluttermessenger/pages/user&group/SearchMessagesPage.dart';
import 'package:fluttermessenger/services/database.dart';
import 'dart:io';
//TODO create a page that fits for both groups and chats

class UserPage extends StatefulWidget{

  final User user;
  final BaseDb database;
  final String currentUserId;
  final String convTypeId;
  

  UserPage({this.user, this.database,this.currentUserId, this.convTypeId});

  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage>{

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

  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
      return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username
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
                  widget.user.imageUrl != ""
                  ?  
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.user.imageUrl),
                  )                 
                  :
                  Icon(Icons.account_circle, size: 120, color: Colors.blueAccent,)
                ),
            ],),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Divider(color: Colors.blueAccent,)
          ),
          Container(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => NickNames())),
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
                  builder: (BuildContext context) => MediaCollection(database: widget.database, typeId: widget.convTypeId,))),
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
                  builder: (BuildContext context) => SearchMessagesPage(title: widget.user.username, database: widget.database, typeId: widget.convTypeId,))),
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
              onTap: () => print("Block"),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.block, color: Colors.redAccent,),
                    SizedBox(width: 5,),
                    Container(
                      child: Text("Block", style: TextStyle(fontSize: 17),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () => print("Ignore messages"),
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
              onTap: () => _unfriend(),
              child: Container(
                margin: EdgeInsets.only(left: 25, top: 10),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.close, color: Colors.redAccent,),
                    SizedBox(width: 5,),
                    Text("Unfriend", style: TextStyle(fontSize: 17),),
                  ],
                ),
              ),
            ),
          ),
      ],),
    );
  }
}
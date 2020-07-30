import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chat.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/user-group/media_collection.dart';
import 'package:fluttermessenger/pages/user-group/search_messages.dart';
import 'package:fluttermessenger/services/database.dart';
import 'dart:io';
//TODO create a page that fits for both groups and chats

class UserPage extends StatefulWidget{

  final User user;
  final BaseDb database;
  final String currentUserId;
  final Chat chat;
  

  UserPage({this.user, this.database,this.currentUserId, this.chat});

  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage>{

  File file;

  void _unfriend() async{
    await widget.database.unFriend(widget.currentUserId, widget.user.id);
    await widget.database.removeChat(widget.chat.id);
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
        backgroundColor: Color(0xff121212),
        appBar: AppBar(
          backgroundColor: Color(0xff2b2a2a),
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
                    Icon(Icons.account_circle, size: 120, color: Colors.white,)
                  ),
              ],),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(color: Colors.grey,)
            ),
            Container(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => MediaCollectionPage(database: widget.database, typeId: widget.chat.id,))),
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
                    builder: (BuildContext context) => SearchMessagesPage(title: widget.user.username, database: widget.database, typeId: widget.chat.id,))),
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
                onTap: () => print("Block"),
                child: Container(
                  margin: EdgeInsets.only(left: 25, top: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.block, color: Colors.redAccent,),
                      SizedBox(width: 5,),
                      Container(
                        child: Text("Block", style: TextStyle(fontSize: 17 ,color: Colors.white),),
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
                      Text("Ignore messages", style: TextStyle(fontSize: 17, color: Colors.white),),
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
                      Text("Unfriend", style: TextStyle(fontSize: 17, color: Colors.white),),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
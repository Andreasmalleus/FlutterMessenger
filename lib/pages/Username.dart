import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/database.dart';

class Username extends StatefulWidget{

  final BaseDb database;
  final User user;

  Username({this.database, this.user});

  @override
  _UsernameState createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  String username = "";

  void _updateUsername(String username) async{
    if(username == "" || username.length < 5){
      print("Cant be empty and must be more than 5 characters long");
    }else{
      await widget.database.updateUsername(widget.user.id, username);
      Navigator.of(context).pop();
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Username"),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 17, right: 15),
            child: GestureDetector(
              child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 20),),
              onTap: () => _updateUsername(username),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text("Username")
            ),
            TextField(
              onChanged: (value) => username = value,
              decoration: InputDecoration(hintText: widget.user.username),
            ),
          ],
        ),
      ),
    );
  }
}
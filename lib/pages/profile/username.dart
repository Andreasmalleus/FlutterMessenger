import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class UsernamePage extends StatefulWidget{

  final BaseDb database;
  final User user;

  UsernamePage({this.database, this.user});

  @override
  _UsernamePageState createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  String username = "";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  void _updateUsername(String username) async{
    if(username == "" || username.length < 5){
      showSnackBar("Cant be empty and must be more than 5 characters long", _scaffoldKey);
    }else{
      _checkIfUsernameIsAlreadyInUse();
    }
  }

  Future<void> _checkIfUsernameIsAlreadyInUse() async {
    bool _exists = await widget.database.checkIfValueAlreadyExists(username, "username");
    print(_exists.toString());
    if(_exists){
      showSnackBar("User already in use", _scaffoldKey);
    }else{
      showSnackBar("Username updated", _scaffoldKey);
      await widget.database.updateUsername(widget.user.id, username);
      Navigator.of(context).pop();
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xff121212),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff2b2a2a),
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
              child: Text("Username", style: TextStyle(color: Colors.white),)
            ),
            Container(
            margin: EdgeInsets.only(top: 5),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                filled: true,
                hintText: widget.user.username,
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
              ),
                onChanged: (value) => setState((){
                  username = value;
                }),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
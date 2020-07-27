import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class Username extends StatefulWidget{

  final BaseDb database;
  final User user;

  Username({this.database, this.user});

  @override
  _UsernameState createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
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
      key: _scaffoldKey,
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
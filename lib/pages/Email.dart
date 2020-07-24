import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class Email extends StatefulWidget{

  final BaseDb database;
  final User user;
  final BaseAuth auth;

  Email({this.database, this.user, this.auth});

  @override
  _EmailState createState() => _EmailState();
}

class _EmailState extends State<Email> {
  String email = "";
  bool _isCorrect;
  String password = "";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  void _emailValidator(String email) async{
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(email == "" || email.length < 5 && !regex.hasMatch(email)){
      showSnackBar("Email should contain @ and cant be empty", _scaffoldKey);
    }else{
      setState(() {
        _isCorrect = true;
      });
    }
  }

  void _reAuthenitcateAndUpdateEmail() async{
    try{
      await widget.auth.reAuthenticate(password, widget.user.email);
      _updateEmail(email, widget.user.id);
    }catch(error){
      print(error);
    }
  }

  void _updateEmail(String email, String userId) async{
    await widget.auth.updateEmail(email);
    await widget.database.updateEmail(userId, email);
    Navigator.of(context).pop();
  }

  Widget _passwordContainer(){
    if(_isCorrect){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Text("Please re-enter your password")
          ),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  onChanged: (value) => setState((){
                    password = value;
                  }),
                  decoration: InputDecoration(hintText: "password")
                ),
              ),
            ],
          ),
          RaisedButton(
              onPressed: () => _reAuthenitcateAndUpdateEmail(),
              child: Text("Reauthenticate"),
            )
        ],
      );
    }else{
      return Container(
        width: 0, height: 0,
      );
    }
  }

  void initState(){
    _isCorrect = false;
    super.initState();
  }

  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Email"),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 17, right: 15),
            child: GestureDetector(
              child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 20),),
              onTap: () => _emailValidator(email),
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
              child: Text("Email")
            ),
            Container(
              child: TextField(
                onChanged: (value) => email = value,
                decoration: InputDecoration(hintText: widget.user.email),
              ),
            ),
            _passwordContainer()
          ],
        ),
      ),
    );
  }
}
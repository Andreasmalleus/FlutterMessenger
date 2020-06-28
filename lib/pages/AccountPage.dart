import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

class AccountPage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  final VoidCallback logOutCallback;

  AccountPage({this.database, this.auth, this.logOutCallback});

  @override
  _AccountPageState createState() => _AccountPageState();

}

class _AccountPageState extends State<AccountPage>{

  User currentUser;

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void _signOut() async {
    try{
      await widget.auth.signOut();
      widget.logOutCallback();
    }catch(e){
      print(e);
    }
  }

  @override
  void initState(){
    getCurrentUser();
    super.initState();
  }

  Widget build(BuildContext context){
    if(currentUser != null){
return Scaffold(
      appBar: AppBar(
        title: Text("Account page"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
            Container(
              child: Icon(
                Icons.android,
                size: 75,
                )
              ),
            Container(
              child: Text(currentUser.username),
            )
          ],),
          Container(child: Text("Account settings"),),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))
            ),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: currentUser.username),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))
            ),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: currentUser.email),
            ),
          ),
          Container(
            child: Text("Email will not be displayed publicly.."),
          ),
          Container(
            child: RaisedButton(
              child: Text("Sign out", style: TextStyle(color: Colors.red),),
              
              onPressed: () => _signOut
              ),
          )

      ],),
    );
    }else{
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }

  }
}
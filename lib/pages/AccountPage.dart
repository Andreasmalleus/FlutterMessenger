import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

class AccountPage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  final VoidCallback logOutCallback;
  final User user;

  AccountPage({this.database, this.auth, this.logOutCallback, this.user});

  @override
  _AccountPageState createState() => _AccountPageState();

}

class _AccountPageState extends State<AccountPage>{

  File file;
  String imageUrl = "";

  void _signOut() async {
    try{
      await widget.auth.signOut();
      widget.logOutCallback();
    }catch(e){
      print(e);
    }
  }

  void _uploadImage() async{
    String url = "";
    try{
      file = await FilePicker.getFile(type: FileType.image);
      url = await widget.database.uploadImageToStorage(file, widget.user.id);
      widget.database.uploadImageToDataBase(url, widget.user.id);
    }catch(e){
      print(e);
    }
    setState(() {
       imageUrl = url;
    });
  }

  @override
  void initState(){
    super.initState();
    imageUrl = widget.user.imageUrl;
  }

  Widget build(BuildContext context){
    if(widget.user.id != null){
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
              child: 
                imageUrl != ""
                ?  
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(imageUrl),
                )                 
                :
                Icon(Icons.android)
              ),
            Container(
              child: Text(widget.user.username),
            )
          ],),
          Container(child: Text("Account settings"),),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))
            ),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: widget.user.username),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black))
            ),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: widget.user.email),
            ),
          ),
          Container(
            child: Text("Email will not be displayed publicly.."),
          ),
          Container(
            child: RaisedButton(
              child: Text("Sign out", style: TextStyle(color: Colors.red),),
              onPressed: () => _signOut()
              ),
          ),
          Container(
            child: RaisedButton(
              child: Text("Upload profile image"),
              onPressed: () => {
                _uploadImage()
              },
            ),
          ),
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
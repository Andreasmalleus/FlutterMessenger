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
  final String userId;

  AccountPage({this.database, this.auth, this.logOutCallback, this.userId});

  @override
  _AccountPageState createState() => _AccountPageState();

}

class _AccountPageState extends State<AccountPage>{

  File file;

  void _signOut() async {
    try{
      await widget.auth.signOut();
      widget.logOutCallback();
      Navigator.pop(context);
    }catch(e){
      print(e);
    }
  }

  void _uploadImage() async{
    String url = "";
    try{
      file = await FilePicker.getFile(type: FileType.image);
      url = await widget.database.uploadImageToStorage(file, widget.userId);
      widget.database.uploadImageToDataBase(url, widget.userId);
    }catch(e){
      print(e);
    }
  }

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    if(widget.userId != null){
      return StreamBuilder(
            stream: widget.database.getUserRef().child(widget.userId).onValue,
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data.snapshot.value != null){
                dynamic dbUser = snapshot.data.snapshot.value;
                User user = User(
                  id: widget.userId,
                  imageUrl: dbUser["imageUrl"],
                  createdAt: dbUser["createdAt"],
                  username: dbUser["username"],
                  email: dbUser["email"]
                );
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(user.username),
                      centerTitle: true, 
                    ),
                    body: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                          Container(
                            child: 
                              user.imageUrl != ""
                              ?  
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(user.imageUrl),
                              )                 
                              :
                              Icon(Icons.android, size: 30,)
                            ),
                          Container(
                            child: Text(user.username),
                          )
                        ],),
                        Container(child: Text("Account settings"),),
                      
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black))
                          ),
                          child: TextField(
                            decoration: InputDecoration.collapsed(hintText: user.username),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black))
                          ),
                          child: TextField(
                            decoration: InputDecoration.collapsed(hintText: user.email),
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
                  width: 0,
                  height: 0,
                );
              }
            },
          );
    }else{
      return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }

  }
}
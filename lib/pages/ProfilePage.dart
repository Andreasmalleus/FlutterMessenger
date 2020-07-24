import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/pages/Email.dart';
import 'package:fluttermessenger/pages/Username.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

class ProfilePage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  final VoidCallback logOutCallback;
  final String userId;

  ProfilePage({this.database, this.auth, this.logOutCallback, this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage>{

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

  void _uploadProfileImage() async{
    String url = "";
    try{
      file = await FilePicker.getFile(type: FileType.image);
      url = await widget.database.uploadUserImageToStorage(file, widget.userId);
      widget.database.updateUserImageUrl(url, widget.userId);
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
                      title: Text("Profile"),
                      centerTitle: true, 
                    ),
                    body: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                          ],),
                        ),
                        GestureDetector(
                          onTap: () => _uploadProfileImage(),
                          child: Container(
                            child: Text("Change profile photo", style: TextStyle(fontSize: 15, color: Colors.blue),),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Divider(color: Colors.blueAccent,)
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Text("Edit profile", style: TextStyle(fontSize: 20),),
                          alignment: Alignment.topLeft,),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Text("Username", style: TextStyle(fontSize: 17),),
                                ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context, MaterialPageRoute(
                                    builder : (context) => Username(
                                      database: widget.database,
                                      user: user,
                                      ))),
                                child: Container(
                                  margin: EdgeInsets.only(left: 25),
                                  child: Text(user.username, style: TextStyle(fontSize: 17),)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Text("Email address", style: TextStyle(fontSize: 14),),
                                ),
                              GestureDetector(
                                onTap: () =>  Navigator.push(
                                  context, MaterialPageRoute(
                                    builder : (context) => Email(
                                      database: widget.database,
                                      user: user,
                                      auth: widget.auth
                                      ))),
                                child: Container(
                                  margin: EdgeInsets.only(left: 14),
                                  child: Text(user.email, style: TextStyle(fontSize: 17),)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Divider(color: Colors.blueAccent,)
                        ),
                        Container(
                          child: RaisedButton(
                            color: Colors.blueAccent,
                            child: Text("Sign out", style: TextStyle(color: Colors.white),),
                            onPressed: () => _signOut()
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
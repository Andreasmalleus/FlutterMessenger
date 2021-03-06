import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/profile/email.dart';
import 'package:fluttermessenger/pages/profile/username.dart';
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
      
      widget.database.updateUserImageUrl(widget.userId, url);
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
            stream: widget.database.streamUser(widget.userId),
            builder: (context, snapshot){
              if(snapshot.hasData){
                User user = snapshot.data;
                  return Scaffold(
                    backgroundColor: Color(0xff121212),
                    appBar: AppBar(
                      backgroundColor: Color(0xff2b2a2a),
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
                                Icon(Icons.account_circle, size: 120, color: Colors.white,)
                              ),
                          ],),
                        ),
                        GestureDetector(
                          onTap: () => _uploadProfileImage(),
                          child: Container(
                            child: Text("Change profile photo", style: TextStyle(fontSize: 15, color: Colors.white),),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Divider(color: Colors.grey,)
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Text("Edit profile", style: TextStyle(fontSize: 20, color: Colors.white),),
                          alignment: Alignment.topLeft,),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Text("Username", style: TextStyle(fontSize: 17, color: Colors.white),),
                                ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context, MaterialPageRoute(
                                    builder : (context) => UsernamePage(
                                      database: widget.database,
                                      user: user,
                                      ))),
                                child: Container(
                                  margin: EdgeInsets.only(left: 25),
                                  child: Text(user.username, style: TextStyle(fontSize: 17, color: Colors.white),)
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
                                child: Text("Email address", style: TextStyle(fontSize: 14, color: Colors.white),),
                                ),
                              GestureDetector(
                                onTap: () =>  Navigator.push(
                                  context, MaterialPageRoute(
                                    builder : (context) => EmailPage(
                                      database: widget.database,
                                      user: user,
                                      auth: widget.auth
                                      ))),
                                child: Container(
                                  margin: EdgeInsets.only(left: 14),
                                  child: Text(user.email, style: TextStyle(fontSize: 17, color: Colors.white),)
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: Divider(color: Colors.grey,)
                        ),
                        Container(
                          child: RaisedButton(
                            color: Color(0xff2b2a2a),
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
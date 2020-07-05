import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/database.dart';

class UserPage extends StatefulWidget{

  final String userId;
  final BaseDb database;
  final User currentUser;
  final String chatKey;

  UserPage({this.userId, this.database,this.currentUser, this.chatKey});

  @override
  _UserPageState createState() => _UserPageState();

}

class _UserPageState extends State<UserPage>{

  User user;

  void getUserObject() async{
    User dbUser = await widget.database.getUserObject(widget.userId);
    setState(() {
      user = dbUser;
    });
  }

  void _unfriend() async{
    await widget.database.unFriend(widget.currentUser.id, user.id);
    await widget.database.removeChat(widget.chatKey);
    navigateToChatsPage();
  }

  void navigateToChatsPage(){
    var nav = Navigator.of(context);
    nav.pop();
    nav.pop();
  }

  void initState(){
    getUserObject();
    super.initState();
  }

  Widget build(BuildContext context){
    if(user != null){
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
                user.imageUrl != ""
                ?  
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user.imageUrl),
                )                 
                :
                Icon(Icons.android)
              ),
            Container(
              child: Text(user.username),
            )
          ],),
          Container(
            child: Text(user.username),
          ),
          Container(
            child: Text(user.email),
          ),
          Container(
            child: RaisedButton(
              onPressed: () => {
                _unfriend()
              },
              child: Text("Unfriend", style: TextStyle(color: Colors.red),),
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
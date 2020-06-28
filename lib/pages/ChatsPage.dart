import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chatModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/widgets/CustomDrawer.dart';
import 'MessagePage.dart';


class ChatsPage extends StatefulWidget {

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  ChatsPage({this.auth, this.logOutCallback, this.database});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

//TODO Add friends && search

class _ChatsPageState extends State<ChatsPage> {
  List<User> users = [];
  String lastMessage = "";
  User currentUser;

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void _addFriends(String firstUser, String secondUser) async{
    widget.database.addFriends(firstUser, secondUser);
  }

  void _removeFriends(String firstUser, String secondUser) async{
    widget.database.unFriend(firstUser, secondUser);
  }

  void _addChat(String firstUser, String secondUser) async{
    widget.database.createChat(firstUser, secondUser);
  }

  @override
  void initState(){
    super.initState();
      getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Chats"),
      ),
      drawer: CustomDrawer(auth: widget.auth, logOutCallback: widget.logOutCallback),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () => {
                  _addFriends(currentUser.id, "aa")
                },
                child: Text("Create friendship"),),
                RaisedButton(
                onPressed: () => {
                  _removeFriends(currentUser.id, "aa")
                },
                child: Text("Remove friendship"),),
            ],
          ),
          RaisedButton(
            onPressed: () => {
              _addChat(currentUser.id, "lVHt2VOcrTVZZCgYYApfl3wnOAy2")
            },
            child: Text("Create chat"),),
          StreamBuilder(
            stream: widget.database.getChatRef().onValue,
            builder: (context, snapshot) {
              if(snapshot.hasData && snapshot.data.snapshot.value != null){
                Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                List<Chat> chats = List<Chat>();
                map.forEach((key,val) =>{
                  val["participants"].forEach((id, value) => {
                    if(id != currentUser.id){
                      chats.add(
                        Chat(
                          id: key,
                          lastMessage: val["lastMessage"],
                          lastMessageTime: val["lastMessageTime"],
                          participant: id
                        ),
                      )
                      }
                    }),
                });
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:  chats.length,
                  itemBuilder: (BuildContext ctx, int i){
                    return GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context)=> MessagePage(
                            database: widget.database,
                            receiver: chats[i].id,
                            sender: currentUser,
                            chatKey: chats[i].id
                            ))),
                      child: Container(
                        height: 75,
                        child: Card(
                          child: ListTile(
                          leading: Icon(Icons.android, size: 35,),
                          title: Text(chats[i].id),
                          subtitle: Text(chats[i].lastMessage + " " + chats[i].lastMessageTime),
                          trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {  },),
                          ),
                          ),
                      )
                    );             
                }
                );
              }else{
                return Container(child: Text("No data"),);
              }
            },
          )
        ]
      ),
    );
  }
}

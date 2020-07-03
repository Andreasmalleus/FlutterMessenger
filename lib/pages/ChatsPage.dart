import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chatModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/pages/AccountPage.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:fluttermessenger/widgets/CustomDrawer.dart';
import 'MessagePage.dart';


class ChatsPage extends StatefulWidget {

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  final VoidCallback toggleBottomAppBarVisibility;
  ChatsPage({this.auth, this.logOutCallback, this.database, this.toggleBottomAppBarVisibility});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

//TODO Add friends && search

class _ChatsPageState extends State<ChatsPage>{
  String lastMessage = "";
  User currentUser;
  List<Chat> temp = [];
  String searchResult = "";

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void _addFriends(String firstUser, String secondUser){
    widget.database.addFriends(firstUser, secondUser);
  }

  void _removeFriends(String firstUser, String secondUser){
    widget.database.unFriend(firstUser, secondUser);
  }

  void _addChat(String firstUser, String secondUser){
    widget.database.createChat(firstUser, secondUser);
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0)
            )
          ),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Add Friends"),
              RaisedButton(
                child: Text("Close"),
                onPressed: () => {
                  Navigator.pop(context),
                  widget.toggleBottomAppBarVisibility()
                }
              )
            ],
          )
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //keybaord resizes widget
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => {
              _showSheet(),
              widget.toggleBottomAppBarVisibility()
            },
            ),
            IconButton(
            icon: Icon(Icons.android),
            onPressed: () => {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => AccountPage(
                  database: widget.database,
                  auth : widget.auth,
                  logOutCallback: widget.logOutCallback,
                  user: currentUser
                ),
              ))
            },
            ) 
        ],
        title: Text("Chats"),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(hintText: "Search chats here..."),
              onChanged: (value) => setState((){
                searchResult = value;
              })
            ),
          ),
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
                Chat chat;
                map.forEach((key,val) =>{
                  if(val["participants"].containsKey(currentUser.id)){
                    val["participants"].forEach((id, value) => {
                        if(id != currentUser.id){
                          chat = Chat(
                            id: key,
                            lastMessage: val["lastMessage"],
                            lastMessageTime: val["lastMessageTime"],
                            participant: id
                          ),
                          chats.add(chat)
                        }
                    })
                  }
                });
                temp = chats;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:  chats.length,
                  itemBuilder: (BuildContext ctx, int i){
                    if(chats[i].id.contains(searchResult)){
                      return GestureDetector(
                        onTap: () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context)=> MessagePage(
                              database: widget.database,
                              receiver: chats[i].participant,
                              sender: currentUser,
                              chatKey: chats[i].id,
                              check: true,
                              ))),
                        child: Container(
                          height: 75,
                          child: Card(
                            child: ListTile(
                            leading: Icon(Icons.android, size: 35,),
                            title: Text(chats[i].id),
                            subtitle: Text(
                              ((){
                                if(chats[i].lastMessage !=  null && chats[i].lastMessageTime != null){
                                  String formattedDate = formatDateToHoursAndMinutes(chats[i].lastMessageTime);
                                  return chats[i].lastMessage + " " + formattedDate;
                                }else{
                                  return "";
                              }
                            }())
                              ),
                            trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {  },),
                            ),
                            ),
                        )
                      );             
                    }
                  }
                );
              }else{
                return Container(child: Text("No data"),);
              }
            },
          ),
        ]
      ),
    );
  }
}

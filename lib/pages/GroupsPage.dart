import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

import 'MessagePage.dart';

class GroupsPage extends StatefulWidget{

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  GroupsPage({this.auth, this.logOutCallback, this.database});

  @override
  _GroupsPageState createState() => _GroupsPageState();

}

class _GroupsPageState extends State<GroupsPage>{

  User currentUser;
  List<User> users = [];

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void _createGroup() async{
    List<String> ids = List<String>();
    ids.add("üks");
    ids.add("kaks");
    widget.database.createGroup(ids);
  }

  @override
  void initState(){
    super.initState();
      getCurrentUser();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Text("GroupsPage")),
      body: Column(
        children: <Widget>[
          Center(
            child: RaisedButton(
              child: Text("Create group"),
              onPressed: () => {
                _createGroup()
              },
            ),
          ),
          StreamBuilder(
            stream: widget.database.getGroupRef().onValue,
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data.snapshot.value != null){
                Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                List<Group> groups = List<Group>();
                List<String> participants = List<String>();
                map.forEach((key, value) {
                  value["participants"].forEach((participantId, boolean){
                    participants.add(participantId);
                  });
                  groups.add(
                    Group(
                      id: key,
                      lastMessage: value["lastMessage"],
                      lastMessageTime: value["lastMessageTime"],
                      participants: participants
                    )
                  );
                });
              return ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (BuildContext context, int i){
                  return GestureDetector(
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context)=> MessagePage(
                          database: widget.database,
                          receiver: groups[i].id,
                          sender: currentUser,
                          chatKey: groups[i].id
                          ))),
                    child: Container(
                      height: 75,
                      child: Card(
                        child: ListTile(
                        leading: Icon(Icons.android, size: 35,),
                        title: Text(groups[i].id),
                        subtitle: Text(
                          ((){
                            if(groups[i].lastMessage !=  null && groups[i].lastMessageTime != null){
                              return groups[i].lastMessage + " " + groups[i].lastMessageTime;
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
              );
              }else{
                return Container(child: Text("No data"),);
              }
            },
          )
        ],
      )
    );
  }
}
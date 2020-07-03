import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:fluttermessenger/widgets/CustomDrawer.dart';

import 'AccountPage.dart';
import 'MessagePage.dart';

class GroupsPage extends StatefulWidget{

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  final VoidCallback toggleBottomAppBarVisibility;
  GroupsPage({this.auth, this.logOutCallback, this.database, this.toggleBottomAppBarVisibility});

  @override
  _GroupsPageState createState() => _GroupsPageState();

}

class _GroupsPageState extends State<GroupsPage>{

  User currentUser;
  List<User> users = [];
  String searchResult = "";

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void _createGroup() async{
    List<String> ids = List<String>();
    ids.add(currentUser.id);
    ids.add("randomId");
    widget.database.createGroup(ids, "grupiNimi");
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

  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("GroupsPage"),
        centerTitle: true,
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
        ),
      drawer: CustomDrawer(),
      body: Column(
        children: <Widget>[
           Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(hintText: "Search groups here..."),
              onChanged: (value) => setState((){
                searchResult = value;
              })
            ),
          ),
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
                Group group;
                map.forEach((key, value) {
                  if(value["participants"].containsKey(currentUser.id)){
                    value["participants"].forEach((participantId, boolean){
                      participants.add(participantId);
                    });
                    group = Group(
                      id: key,
                      name: value["name"],
                      lastMessage: value["lastMessage"],
                      lastMessageTime: value["lastMessageTime"],
                      participants: participants
                    );
                    groups.add(group);
                    }
                });
              return ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (BuildContext context, int i){
                  if(groups[i].id.contains(searchResult)){
                    return GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context)=> MessagePage(
                            database: widget.database,
                            receiver: groups[i].name,
                            sender: currentUser,
                            chatKey: groups[i].id,
                            check: false,
                            ))),
                      child: Container(
                        height: 75,
                        child: Card(
                          child: ListTile(
                          leading: Icon(Icons.android, size: 35,),
                          title: Text(groups[i].name),
                          subtitle: Text(
                            ((){
                              if(groups[i].lastMessage !=  "" && groups[i].lastMessageTime != ""){
                                String formattedDate = formatDateToHoursAndMinutes(groups[i].lastMessageTime);
                                return groups[i].lastMessage + " " + formattedDate;
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
          )
        ],
      )
    );
  }
}
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
  final User currentUser;
  GroupsPage({this.auth, this.logOutCallback, this.database, this.toggleBottomAppBarVisibility, this.currentUser});

  @override
  _GroupsPageState createState() => _GroupsPageState();

}

class _GroupsPageState extends State<GroupsPage>{

  List<User> users = [];
  String searchResult = "";
  String userSearchResult = "";
  List<String> groupParticipants = List<String>();
  String groupName = "";


  void _createGroup() async{
    groupParticipants.add(widget.currentUser.id);
    widget.database.createGroup(groupParticipants, groupName);
  }

  void getAllUsers() async{
    List<User> dbUsers = await widget.database.getAllUsers();
    dbUsers.removeWhere((user) => user.id == widget.currentUser.id);
    setState((){
      users = dbUsers;
    });
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)
                )
              ),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Create a group"),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: TextField(
                      onChanged: (value) => setModalState((){
                        userSearchResult = value;
                      }),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Search users"
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int i){
                      if(users[i].username.contains(userSearchResult) && !groupParticipants.contains(users[i].id) && userSearchResult != ""){
                        return Container(
                          //TODO clicking on card navigates to user Page
                          child: Card(
                            child: ListTile(
                              leading: Icon(Icons.android),
                              title: Text(users[i].username),
                              trailing: IconButton(icon: Icon(Icons.add_box), onPressed: () => setModalState((){
                                groupParticipants.add(users[i].id);
                              })),
                            ),
                          ),
                        );
                     }else{
                       return Container(
                         width: 0,
                         height: 0,
                       );
                     }
                    }
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: TextField(
                      onChanged: (value) => setModalState((){
                        groupName = value;
                        }),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Group name"
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text("Create a group"),
                    onPressed: () => {
                      _createGroup()
                    },
                  ),
                  RaisedButton(
                    child: Text("Close"),
                    onPressed: () => {
                      Navigator.pop(context),
                      setModalState((){
                        groupParticipants.clear();
                      }),
                      widget.toggleBottomAppBarVisibility()
                    }
                  )
                ],
              )
            );
          }
        );
      },
    );
  }

  @override
  void initState(){
    getAllUsers();
    super.initState();
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
                  user: widget.currentUser
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
          StreamBuilder(
            stream: widget.database.getGroupRef().onValue,
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data.snapshot.value != null){
                Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                List<Group> groups = List<Group>();
                List<String> participants = List<String>();
                Group group;
                map.forEach((key, value) {
                  if(value["participants"].containsKey(widget.currentUser.id)){
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
                            group: groups[i],
                            sender: widget.currentUser,
                            typeKey: groups[i].id,
                            isChat: false,
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
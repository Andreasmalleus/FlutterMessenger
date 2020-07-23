import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/groupModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:fluttermessenger/components/CustomBottomSheet.dart';
import 'package:provider/provider.dart';

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

  List<User> users = [];
  String searchResult = "";
  String userSearchResult = "";
  List<String> groupParticipants = List<String>();
  String groupName = "";
  User currentUser;

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomBottomSheet(database: widget.database, toggleBottomAppBarVisibility: widget.toggleBottomAppBarVisibility, isChat: false);
      },
    );
  }

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    this.currentUser = Provider.of<User>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Groups"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () => {
            _showSheet(),
            widget.toggleBottomAppBarVisibility(),
          },
        ),
        actions: <Widget>[
            GestureDetector(
            child: Container(
              child: currentUser.imageUrl != "" 
              ?
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(currentUser.imageUrl),
              )
              : Icon(Icons.account_circle, size: 40)
            ),
            onTap: () => {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => AccountPage(
                  database: widget.database,
                  auth : widget.auth,
                  logOutCallback: widget.logOutCallback,
                  userId: currentUser.id,
                ),
              ))
            },
            )
        ],
      ),
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
                List<String> admins = List<String>();
                Group group;
                map.forEach((key, value) {
                  if(value["participants"].containsKey(currentUser.id)){
                    value["participants"].forEach((participantId, boolean){
                      participants.add(participantId);
                    });
                    value["admins"].forEach((adminId, boolean){
                      admins.add(adminId);
                    });
                    group = Group(
                      id: key,
                      name: value["name"],
                      lastMessage: value["lastMessage"],
                      lastMessageTime: value["lastMessageTime"],
                      imageUrl: value["imageUrl"],
                      participants: participants,
                      admins: admins
                    );
                    groups.add(group);
                    }
                });
              return ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, i){
                  if(groups[i].name.contains(searchResult)){
                    return GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context)=> MessagePage(
                            database: widget.database,
                            group: groups[i],
                            sender: currentUser,
                            convTypeId: groups[i].id,
                            isChat: false,
                            ))),
                      child: Container(
                        height: 75,
                        child: Card(
                          child: ListTile(
                          leading: groups[i].imageUrl != "" 
                          ? 
                          CircleAvatar(
                            backgroundImage: NetworkImage(groups[i].imageUrl),
                          )
                          : Icon(Icons.supervised_user_circle, size: 35,color: Colors.blueAccent,),
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
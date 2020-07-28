import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:fluttermessenger/components/custom_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'profile/profile.dart';
import 'messages.dart';

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
                builder: (context) => ProfilePage(
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
            stream: widget.database.streamGroups(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                List<Group> groups = snapshot.data;
                groups.removeWhere((group) => !group.participants.contains(currentUser.id));
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
                    }else{
                      return Container(width: 0,height: 0,);
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
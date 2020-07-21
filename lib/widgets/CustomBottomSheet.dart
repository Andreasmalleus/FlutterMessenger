import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:provider/provider.dart';

class CustomBottomSheet extends StatefulWidget{

  final bool isChat;
  final VoidCallback toggleBottomAppBarVisibility;
  final BaseDb database;
  CustomBottomSheet({this.isChat,this.toggleBottomAppBarVisibility, this.database});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();

}

class _CustomBottomSheetState extends State<CustomBottomSheet>{

  String searchResult = "";
  User currentUser;
  String groupName = "";
  List<String> groupParticipants = List<String>();


  void _addFriends(String userId, String currentUserId){
    widget.database.addFriends(currentUserId, userId);
  }

  void _addChat(String userId,String currentUserId){
    widget.database.createChat(currentUserId, userId);
  }

  Widget _groupNameContainer(){
    if(!widget.isChat){
      return Container(
        width: MediaQuery.of(context).size.width * 0.35,
        child: TextField(
          onChanged: (value) => setState((){
            groupName = value;
            }),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "Group name"
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

  void _createGroup(String currentUserId) async{
    groupParticipants.add(currentUserId);
    widget.database.createGroup(groupParticipants, groupName);
  }

  Widget _createGroupButton(){
    if(!widget.isChat){
      return RaisedButton(
        child: Text("Create a group"),
        onPressed: () => {
          _createGroup(currentUser.id)
        },
      );
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  @override
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    this.currentUser = Provider.of<User>(context);
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
          widget.isChat ? Text("Add Friends") : Text("Create a group"),
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: TextField(
              onChanged: (value) => setState((){
                searchResult = value;
                }),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Search users"
              ),
            ),
          ),
          _groupNameContainer(),
          //TODO needs a better solution
          StreamBuilder<dynamic>(
            stream: widget.database.streamUsers(),
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data != null){
                Map<dynamic,dynamic> map = snapshot.data;
                List<User> users =List<User>();
                map.forEach((key, value) {
                  users.add(
                    User(
                      id: key,
                      username: value["username"],
                      email: value["email"],
                      createdAt: value["createdAt"],
                      imageUrl: value["imageUrl"]
                    )
                  );
                });
                return FutureBuilder(
                  future: widget.database.getFriends(currentUser.id),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot){
                    if(snapshot.hasData && snapshot != null){
                      List<User> friends = snapshot.data;
                      if(widget.isChat){
                        for(User friend in friends){
                        users.removeWhere((user) => user.id == friend.id);
                          //TODO bugged
                        }
                      }
                    }
                    users.removeWhere((user) => user.id == currentUser.id);
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (BuildContext context, int i){
                          if(users[i].username.contains(searchResult) && searchResult != ""){
                            return Container(
                              child: Card(
                                child: ListTile(
                                  leading: users[i].imageUrl != "" ? CircleAvatar(backgroundImage: NetworkImage(users[i].imageUrl),) : Icon(Icons.android),
                                  title: Text(users[i].username),
                                  trailing: IconButton(icon: Icon(Icons.add_box), onPressed: () => {
                                    widget.isChat ?  _addFriends(users[i].id,currentUser.id) : null,
                                    widget.isChat ? _addChat(users[i].id,currentUser.id) : null,
                                    !widget.isChat ? groupParticipants.add(users[i].id):  null,
                                    setState(() {
                                      users.removeWhere((user) => user.id == users[i].id);
                                    })
                                  },),
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
                      );
                  }
                );
              }else{
                return Container(
                  width: 0,
                  height: 0,
                );
              }
            }
          ), 
          _createGroupButton(),
          RaisedButton(
            child: Text("Close"),
            onPressed: () => {
              Navigator.pop(context),
              widget.toggleBottomAppBarVisibility(),
              groupParticipants.clear()
            }
          )
        ],
      )
    );
  }
} 
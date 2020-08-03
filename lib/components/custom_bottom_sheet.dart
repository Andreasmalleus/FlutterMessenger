import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chat.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/user.dart';
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
    Chat chat = Chat(
      lastMessage: "",
      lastMessageTime: "",
      participants: [
        userId, currentUserId
      ]
    );
    widget.database.createChat(chat);
  }

  Widget _groupNameContainer(){
    if(!widget.isChat){
      return Container(
        margin: EdgeInsets.all(5),
        child: TextField(
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          decoration: InputDecoration.collapsed(
            filled: true,
            hintText: "Group name",
            fillColor: Color(0xff2b2a2a),
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder( 
              borderRadius : BorderRadius.all(Radius.circular(10))
            )
          ),
            onChanged: (value) => setState((){
              groupName = value;
            }),
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
    Group group = Group(
      name: groupName,
      participants: groupParticipants,
      admins: [currentUserId],
      imageUrl: "",
      lastMessage: "",
      lastMessageTime: "",
    );
    widget.database.createGroup(group);
  }

  Widget _createGroupButton(){
    if(!widget.isChat){
      return RaisedButton(
        color:  Color(0xff2b2a2a),
        child: Text("Create a group", style: TextStyle(color: Colors.white),),
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
        color: Color(0xff121212),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0)
        )
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.isChat ? Text("Add Friends", style: TextStyle(color: Colors.white),) : Text("Create a group", style: TextStyle(color: Colors.white),),
         Container(
            margin: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                filled: true,
                hintText: "Search users",
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
              ),
                onChanged: (value) => setState((){
                  searchResult = value;
                }),
            ),
          ),
          _groupNameContainer(),
          //TODO needs a better solution
          StreamBuilder<List<User>>(
            stream: widget.database.streamUsers(),
            builder: (context, snapshot){
              if(snapshot.hasData && snapshot.data != null){
                List<User> users = snapshot.data;
                return FutureBuilder(
                  future: widget.database.getFriends(currentUser.id),
                  builder: (BuildContext ctx, AsyncSnapshot snapshot){
                    if(snapshot.hasData && snapshot != null){
                      List<User> friends = snapshot.data;
                      if(widget.isChat){
                        for(User friend in friends){
                        users.removeWhere((user) => user.id == friend.id);
                        }
                      }else{
                        for(User friend in friends){
                        users.removeWhere((user) => user.id != friend.id);
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
                                color: Color(0xff2b2a2a),
                                child: ListTile(
                                  leading: users[i].imageUrl != "" ? CircleAvatar(backgroundImage: NetworkImage(users[i].imageUrl),) : Icon(Icons.android, color: Colors.white,),
                                  title: Text(users[i].username, style: TextStyle(color: Colors.white),),
                                  trailing: IconButton(icon: Icon(Icons.add_box, color: Colors.white,), onPressed: () => {
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
            child: Text("Close", style: TextStyle(color: Colors.white),),
            color: Color(0xff2b2a2a),
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
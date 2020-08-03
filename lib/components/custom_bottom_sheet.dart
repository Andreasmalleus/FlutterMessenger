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
  List<User> users;
  bool _isLoading;


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
          decoration: InputDecoration(
            filled: true,
            hintText: "Group name",
            fillColor: Color(0xff2b2a2a),
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder( 
              borderRadius : BorderRadius.all(Radius.circular(10))
            ),
            suffixIcon: Icon(Icons.text_fields)
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
      return GestureDetector(
        onTap: () => _createGroup(currentUser.id),
         child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: Color(0xff2b2a2a),
          margin: EdgeInsets.only(top: 10),
          child: Text("Create", style: TextStyle(color: Colors.greenAccent, fontSize: 18),)
        ),
      );
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  Future<void> _searchUsers() async {
    List<User> dbUsers = await widget.database.searchUsers(searchResult, currentUser.id);
    if(dbUsers != null){
      setState(() {
        users = dbUsers;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFriends() async {
    List<User> dbUsers = await widget.database.searchFriends(searchResult, currentUser.id);
    if(dbUsers != null){
      setState(() {
        users = dbUsers;
        _isLoading = false;
      });
    }
  }

  Widget showSearchedUsers(){
    if(users.isNotEmpty){
      return ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int i){
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
        }
      );
    }else if(_isLoading){
      return Container(child: CircularProgressIndicator(),);
    }else{
      return Container(width: 0,height: 0,);
    }
  }

  @override
  void initState(){
    users = List<User>();
    _isLoading = false;
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
        ),
        border: Border.all(width: 3, color: Color(0xff121212))
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column( 
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30),
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.redAccent,),
              color: Color(0xff2b2a2a),
              onPressed: () => {
                Navigator.pop(context),
                widget.toggleBottomAppBarVisibility(),
                groupParticipants.clear()
              }
            ),
          ),
          widget.isChat ? Text("Add Friends", style: TextStyle(color: Colors.white),) : Text("Create a group", style: TextStyle(color: Colors.white),),
          Container(
            margin: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                hintText: "Search users",
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => {
                    FocusScope.of(context).unfocus(),
                    setState((){
                      _isLoading = true;
                    }),
                    widget.isChat
                    ?
                    _searchUsers()
                    :
                    _searchFriends(),
                    groupParticipants.clear()
                  }
                )
              ),
              onChanged: (value) => setState((){
                searchResult = value;
              }),
            ),
          ),
          _groupNameContainer(),
          showSearchedUsers(),
          //TODO needs a better solution
          _createGroupButton(),
        ],
      )
    );
  }
} 
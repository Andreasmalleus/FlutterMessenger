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
  final User currentUser;
  ChatsPage({this.auth, this.logOutCallback, this.database, this.toggleBottomAppBarVisibility, this.currentUser});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>{
  String lastMessage = "";
  String searchResult = "";
  String userSearchResult = "";
  List<User> users = List<User>();
  List<User> friends = List<User>();

  void getAllUsers() async{
    List<User> dbFriends = await widget.database.getFriends(widget.currentUser.id);
    List<User> dbUsers = await widget.database.getAllUsers();
    for(User friend in dbFriends){
      dbUsers.removeWhere((user) => user.id == friend.id);
      print(friend.id);

    }
    dbUsers.removeWhere((user) => user.id == widget.currentUser.id);
    setState((){
      users = dbUsers;
    });
  }

  void _addFriends(String userId){
    widget.database.addFriends(widget.currentUser.id, userId);
  }

  void _removeFriend(String userId){
    widget.database.unFriend(widget.currentUser.id, userId);
  }

  void _addChat(String userId){
    widget.database.createChat(widget.currentUser.id, userId);
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
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
                Text("Add Friends"),
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
                    if(users[i].username.contains(userSearchResult) && userSearchResult != ""){
                      return Container(
                        //TODO clicking on card navigates to user Page
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.android),
                            title: Text(users[i].username),
                            trailing: IconButton(icon: Icon(Icons.add_box), onPressed: () => {
                              _addFriends(users[i].id),
                              _addChat(users[i].id),
                              setModalState(() {
                                users.removeWhere((user) => user.id == users[i].id);
                              })
                            },),
                          ),
                        ),
                      );
                    }
                  }
                ),
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
      },
    );
  }

  @override
  void initState(){
    super.initState();
    getAllUsers();
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
              widget.toggleBottomAppBarVisibility(),
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
          StreamBuilder(
            stream: widget.database.getChatRef().onValue,
            builder: (context, snapshot) {
              if(snapshot.hasData && snapshot.data.snapshot.value != null){
                Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
                List<Chat> chats = List<Chat>();
                Chat chat;

                map.forEach((key,val) =>{
                  if(val["participants"].containsKey(widget.currentUser.id)){
                    val["participants"].forEach((id, value) => {
                        if(id != widget.currentUser.id){
                          chat = Chat(
                            id: key,
                            lastMessage: val["lastMessage"],
                            lastMessageTime: val["lastMessageTime"],
                            participant: id
                          ),
                          chats.add(chat)
                        },
                    })
                  }
                });
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:  chats.length,
                  itemBuilder: (BuildContext ctx, int i){
                    return FutureBuilder(
                      future: widget.database.getUserObject(chats[i].participant),
                      builder: (BuildContext ctx, AsyncSnapshot snapshot){
                        if(snapshot.hasData && snapshot.data != null){
                          User user = snapshot.data;
                          if(user.username.contains(searchResult)){
                            return GestureDetector(
                              onTap: () => Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context)=> MessagePage(
                                    database: widget.database,
                                    receiver: user.id,
                                    sender: widget.currentUser,
                                    chatKey: chats[i].id,
                                    check: true,
                                    ))),
                              child: Container(
                                height: 75,
                                child: Card(
                                  child: ListTile(
                                    leading: user.imageUrl != "" ? 
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(user.imageUrl),
                                    )
                                    :
                                    Icon(Icons.android, size: 35,),
                                    title: Text(user.username),
                                    subtitle: Text(
                                      ((){
                                        if(chats[i].lastMessage != "" && chats[i].lastMessageTime != ""){
                                          String formattedDate = formatDateToHoursAndMinutes(chats[i].lastMessageTime);
                                          return chats[i].lastMessage + " " + formattedDate;
                                        }else{
                                          return "";
                                      }
                                    }())
                                      ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.more_vert
                                      ), 
                                      onPressed: () =>{ }
                                    ),
                                  ),
                                ),
                              )
                            );             
                          }
                        }else{
                          return Container(child: Text("No data"),);
                        }
                      }
                    );
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

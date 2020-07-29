import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/chat.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/profile/profile.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:fluttermessenger/components/custom_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'messages.dart';


class ChatsPage extends StatefulWidget {

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  final VoidCallback toggleBottomAppBarVisibility;
  ChatsPage({this.auth, this.logOutCallback, this.database, this.toggleBottomAppBarVisibility});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>{
  String lastMessage = "";
  String searchResult = "";
  String userSearchResult = "";
  List<User> users = List<User>();
  List<User> friends = List<User>();
  User currentUser;
  String id = "";

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(database: widget.database, isChat: true, toggleBottomAppBarVisibility: widget.toggleBottomAppBarVisibility);
      },
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.currentUser = Provider.of<User>(context);
    if(currentUser != null){
      return Scaffold(
      resizeToAvoidBottomInset: false, //keybaord resizes widget
      appBar: AppBar(
        title: Text("Chats"),
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
              : Icon(Icons.account_circle, size: 40,)
            ),
            onTap: () => {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (context) => ProfilePage(
                  database: widget.database,
                  auth : widget.auth,
                  logOutCallback: widget.logOutCallback,
                  userId: currentUser.id
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
              decoration: InputDecoration.collapsed(hintText: "Search chats here..."),
              onChanged: (value) => setState((){
                searchResult = value;
              })
            ),
          ),
          StreamBuilder(
            stream: widget.database.streamChats(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List<Chat> chats = snapshot.data;
                chats.removeWhere((chat) => !chat.participants.contains(currentUser.id));//temporary 
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:  chats.length,
                  itemBuilder: (BuildContext ctx, int i){
                    int index = chats[i].participants.indexWhere((id) => id != currentUser.id);
                    String id = chats[i].participants[index];
                    return FutureBuilder<User>(
                      future: widget.database.getUserObject(id),
                      builder: (BuildContext ctx, AsyncSnapshot snapshot){
                        if(snapshot.hasData && snapshot.data != null){
                          User user = snapshot.data;
                          if(user.username.contains(searchResult)){
                            return GestureDetector(
                              onTap: () => Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context)=> MessagePage(
                                    database: widget.database,
                                    user: user,
                                    sender: currentUser,
                                    convTypeId: chats[i].id,
                                    isChat: true,
                                    chat: chats[i],
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
                                    Icon(Icons.account_circle, size: 35,color: Colors.blueAccent,),
                                    title: Text(user.username),
                                    subtitle: Text(
                                      ((){
                                        String message = chats[i].lastMessage;
                                        if(message != ""){
                                          String time = formatDateToHoursAndMinutes(chats[i].lastMessageTime);
                                          if(message.length > 22){
                                            String trimmedMssage = message.substring(0,22);
                                            return "$trimmedMssage.. $time";
                                          }else{
                                            return "$message $time";
                                          }
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
                          }else{
                            return Container(
                              width: 0, height: 0,
                            );
                          }
                        }else{
                          return Container(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }
                    );
                  }
                );

              }else{
                print("no");
                return Container(
                  width: 0,
                  height: 0,
                );
              }
            },
          ),
        ]
      ),
    );
    }else{
      return Container(
        child: CircularProgressIndicator(),
      );
    }
  }
}

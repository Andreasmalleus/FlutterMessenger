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
  String urlll = "https://firebasestorage.googleapis.com/v0/b/flutter-messenger-a7479.appspot.com/o/users%2Fh6RTagwDUnhoH4O5k1V3yoXrjhF3%2Fmedia%2FprofileImage?alt=media&token=5bea6cc6-511c-4660-ad77-1539a2b35b16";

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
      backgroundColor: Color(0xff121212),
      resizeToAvoidBottomInset: false, //keybaord resizes widget
      appBar: AppBar(
        title: Text("Chats"),
        centerTitle: true,
        backgroundColor: Color(0xff2b2a2a),
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
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: TextField(
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration.collapsed(
                filled: true,
                hintText: "Search chats here...",
                fillColor: Color(0xff2b2a2a),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
              ),
              onChanged: (value) => setState((){
                searchResult = value;
              })
            ),
          ),
          StreamBuilder<List<Chat>>(
            stream: widget.database.streamChats(currentUser.id),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List<Chat> chats = snapshot.data;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount:  chats.length,
                  itemBuilder: (BuildContext ctx, int i){
                    int index = chats[i].participants.indexWhere((id) => id != currentUser.id);
                    String id = chats[i].participants[index];
                    return FutureBuilder<User>(
                      future: widget.database.getUser(id),
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
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                height: 75,
                                child: Card(
                                  color: Color(0xff2b2a2a),
                                  child: Container(
                                    child: ListTile(
                                      
                                      leading: user.imageUrl != "" ? 
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(user.imageUrl),
                                      )
                                      :
                                      Icon(Icons.account_circle, size: 35,color: Colors.white,),
                                      title: Text(user.username, style: TextStyle(color: Colors.white),),
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
                                      }()),
                                      style: TextStyle(color: Colors.grey),
                                        ),
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
                return Container(
                  child: Text(snapshot.toString() , style:TextStyle(color: Colors.white)),
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

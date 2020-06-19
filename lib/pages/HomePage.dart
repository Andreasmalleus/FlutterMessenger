import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/widgets/CustomDrawer.dart';
import 'MessagePage.dart';


class HomePage extends StatefulWidget {

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  HomePage({this.auth, this.logOutCallback, this.database});

  @override
  _HomePageState createState() => _HomePageState();
}

//TODO Add friends && search
//TODO remove friends
//TODO ADD 2 person chat

class _HomePageState extends State<HomePage> {
  List<User> users = [];
  User sender;
  String lastMessage = "";
  User currentUser;

  void _lastMessageCallback(String last) async{
    setState(() {
      lastMessage = last;
    });
  }

  void _signOut() async{
    try {
      await widget.auth.signOut();
      widget.logOutCallback();
    } catch (e) {
      print(e);
    }
  }

  void getCurrentUser() async{
    FirebaseUser dbUser = await widget.auth.getCurrentUser();
    User user = await widget.database.getCurrentUserObject(dbUser.uid);
    setState(() {
      currentUser = user;
    });
  }

  void mapUsersToList() async{
    FirebaseUser currentUser = await widget.auth.getCurrentUser();
    List<User> dbUsers = await widget.database.getFriends(currentUser.uid);
    setState(() {
      users = dbUsers;
    });
  } 

  void _addFriends(String firstUser, String secondUser) async{
    await widget.database.addFriends(firstUser, secondUser);
  }


  @override
  void initState(){
    super.initState();
      mapUsersToList();
      getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Home"),
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () => {
              _signOut()
            },
            child: Text("Log out"),),
          RaisedButton(
            onPressed: () => {
              _addFriends(currentUser.id, "lVHt2VOcrTVZZCgYYApfl3wnOAy2")
            },
            child: Text("Create friendship"),),
          ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (BuildContext context, int i){
              return GestureDetector(
                onTap: () => Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context)=> new MessagePage(
                      callback: _lastMessageCallback,
                      database: widget.database,
                      receiver: users[i],
                      sender: currentUser,
                      ))),
                child: Container(
                  height: 75,
                  child: Card(
                    child: ListTile(
                    leading: Icon(Icons.android, size: 35,),
                    title: Text(users[i].username),
                    subtitle: Text(lastMessage),
                    trailing: IconButton(icon: Icon(Icons.more_vert), onPressed: () {  },),
                    ),
                    ),
                )
              );
            }
          ),
        ]
      ),
    );
  }
}

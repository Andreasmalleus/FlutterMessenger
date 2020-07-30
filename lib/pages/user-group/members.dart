import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/database.dart';

class MembersPage extends StatelessWidget{

  MembersPage({this.database, this.group});

  final BaseDb database;
  final Group group;

  void _setNickname(String userId){
    print("set Nickname to $userId");
  }

  //TODO add tabs /one for people one for admins
  Widget build(BuildContext context){
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Color(0xff121212),
          appBar: AppBar(
            backgroundColor: Color(0xff2b2a2a),
            title: Text("Members"),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: "All"),
                Tab(text: "Admins",)
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                itemCount: group.participants.length,
                itemBuilder: (BuildContext context, int i){
                  return FutureBuilder(
                    future: database.getUserObject(group.participants[i]),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      User user = snapshot.data;
                      if(snapshot.hasData){
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal:5),
                          child: Card(
                            color: Color(0xff2b2a2a),
                            child: ListTile(
                              leading: user.imageUrl != ""? 
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.imageUrl),
                                )
                                :
                                Icon(Icons.account_circle, size: 40, color: Colors.white,),
                              title: Text(user.username, style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        );
                      }else{
                        return Container(width: 0,height: 0,);
                      }
                    },
                  );
            }),
              ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                itemCount: group.admins.length,
                itemBuilder: (BuildContext context, int i){
                  return FutureBuilder(
                    future: database.getUserObject(group.admins[i]),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      User user = snapshot.data;
                      if(snapshot.hasData){
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Card(
                            color: Color(0xff2b2a2a),
                            child: ListTile(
                              leading: user.imageUrl != ""? 
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.imageUrl),
                                )
                                :
                                Icon(Icons.account_circle, size: 40,),
                              title: Text(user.username, style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        );
                      }else{
                        return Container(width: 0,height: 0,);
                      }
                    },
                  );
              }),
            ),
            ],
          )
        ),
    );
  }
}
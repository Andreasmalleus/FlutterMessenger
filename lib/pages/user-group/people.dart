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
          appBar: AppBar(
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
              ListView.builder(
              itemCount: group.participants.length,
              itemBuilder: (BuildContext context, int i){
                return FutureBuilder(
                  future: database.getUserObject(group.participants[i]),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    User user = snapshot.data;
                    if(snapshot.hasData){
                      return Container(
                        child: Card(
                          child: ListTile(
                            leading: user.imageUrl != ""? 
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.imageUrl),
                              )
                              :
                              Icon(Icons.account_circle, size: 40,),
                            title: Text(user.username),
                          ),
                        ),
                      );
                    }else{
                      return Container(width: 0,height: 0,);
                    }
                  },
                );
            }),
            ListView.builder(
              itemCount: group.admins.length,
              itemBuilder: (BuildContext context, int i){
                return FutureBuilder(
                  future: database.getUserObject(group.admins[i]),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    User user = snapshot.data;
                    if(snapshot.hasData){
                      return Container(
                        child: Card(
                          child: ListTile(
                            leading: user.imageUrl != ""? 
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.imageUrl),
                              )
                              :
                              Icon(Icons.account_circle, size: 40,),
                            title: Text(user.username),
                          ),
                        ),
                      );
                    }else{
                      return Container(width: 0,height: 0,);
                    }
                  },
                );
            }),
            ],
          )
        ),
    );
  }
}
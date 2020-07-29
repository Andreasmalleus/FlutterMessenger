import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/user-group/user.dart';
import 'package:fluttermessenger/services/database.dart';

class PeoplePage extends StatelessWidget{

  PeoplePage({this.database, this.group});

  final BaseDb database;
  final Group group;

  void _setNickname(String userId){
    print("set Nickname to $userId");
  }

  //TODO add tabs /one for people one for admins
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("People"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
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
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/group.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/database.dart';

class MembersPage extends StatefulWidget{

  MembersPage({this.database, this.group, this.currentUserId});

  final BaseDb database;
  final Group group;
  final String currentUserId;

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  void _kickMember(String userId) async{
    await widget.database.kickMember(widget.group.id,userId);
    widget.group.participants.removeWhere((id) => userId == id);
    Navigator.pop(context);
  }

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
                itemCount: widget.group.participants.length,
                itemBuilder: (BuildContext context, int i){
                  return FutureBuilder(
                    future: widget.database.getUserObject(widget.group.participants[i]),
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
                              trailing:
                              widget.group.admins.contains(widget.currentUserId) && user.id != widget.currentUserId
                              ?
                              IconButton(
                                onPressed: () => _kickMember(user.id),
                                icon: Icon(Icons.remove),
                                color: Colors.white,)
                              :
                              Container(width: 0, height: 0,)
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
                itemCount: widget.group.admins.length,
                itemBuilder: (BuildContext context, int i){
                  return FutureBuilder(
                    future: widget.database.getUserObject(widget.group.admins[i]),
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
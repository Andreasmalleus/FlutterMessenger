import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/message.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class SearchMessagesPage extends StatefulWidget{

  SearchMessagesPage({this.title, this.database, this.typeId});
  final String title;
  final BaseDb database;
  final String typeId;

  @override
  _SearchMessagesPageState createState() => _SearchMessagesPageState();
}

class _SearchMessagesPageState extends State<SearchMessagesPage> {
  String _searchResult = "";

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _searchMessages(){
    if(_searchResult == ""){
      showSnackBar("Field cant be empty", _scaffoldKey);
    }else{
      print("search $_searchResult");
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SearchedMessagesPage(
          title: widget.title,
          database: widget.database,
          searchResult : _searchResult,
          typeId : widget.typeId
        ))
      );
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 17, right: 15),
            child: GestureDetector(
              child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 20),),
              onTap: () => _searchMessages()
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text("Write your message here"),
            ),
            Container(
              child: TextField(
                onChanged: (value) => _searchResult = value,
                decoration: InputDecoration(
                  hintText: "..."
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SearchedMessagesPage extends StatelessWidget{

  SearchedMessagesPage({this.title, this.database, this.searchResult, this.typeId});
  final String title;
  final BaseDb database;
  final String searchResult;
  final String typeId;

  List filterList(List messages){
    messages.removeWhere((message) => message.type == "image");
    messages.removeWhere((message) => !message.message.contains(searchResult));
    return messages;
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: database.getAllMessages(typeId),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData){
              List<Message> messages = filterList(snapshot.data);
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int i){
                  return Card(
                    child: ListTile(
                      leading: messages[i].sender.imageUrl != "" 
                      ?
                      CircleAvatar(backgroundImage: NetworkImage(messages[i].sender.imageUrl))
                      :
                      Icon(Icons.account_circle)
                      ,
                      title: Text(messages[i].sender.username),
                      subtitle: Text(messages[i].message),
                    )
                  );
                });
            }else{
              Container(
                child: Text("Sorry no such messages"),
              );
            }
          },
        ),
      ),
    );
  }
}
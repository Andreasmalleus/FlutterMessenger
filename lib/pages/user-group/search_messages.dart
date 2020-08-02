import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/message.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class SearchMessagesPage extends StatefulWidget{

  SearchMessagesPage({this.title, this.database, this.typeId, this.isChat});
  final String title;
  final BaseDb database;
  final String typeId;
  final bool isChat;

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
          typeId : widget.typeId,
          isChat : widget.isChat
        ))
      );
    }
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xff121212),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff2b2a2a),
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
              margin: EdgeInsets.only(bottom: 5),
              child: Text("Write your message here", style: TextStyle(color: Colors.white),),
            ),
            Container(
              child: TextField(
                onChanged: (value) => _searchResult = value,
                decoration: InputDecoration(
                  hintText: "...",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xff2b2a2a),
                  border: OutlineInputBorder( 
                  borderRadius : BorderRadius.all(Radius.circular(10))
                )
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

  SearchedMessagesPage({this.title, this.database, this.searchResult, this.typeId, this.isChat});
  final String title;
  final BaseDb database;
  final String searchResult;
  final String typeId;
  final bool isChat;

  List filterList(List messages){
    messages.removeWhere((message) => message.type == "image");
    messages.removeWhere((message) => !message.content.contains(searchResult));
    return messages;
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xff121212),
      appBar: AppBar(
        backgroundColor: Color(0xff2b2a2a),
        title: Text(title),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: database.getAllMessages(typeId, isChat),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData){
              List<Message> messages = filterList(snapshot.data);
              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int i){
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Card(
                      color: Color(0xff2b2a2a),
                      child: ListTile(
                        leading: messages[i].sender.imageUrl != "" 
                        ?
                        CircleAvatar(backgroundImage: NetworkImage(messages[i].sender.imageUrl))
                        :
                        Icon(Icons.account_circle, color: Colors.white, size: 50,)
                        ,
                        title: Text(messages[i].sender.username, style: TextStyle(color: Colors.white),),
                        subtitle: Text(messages[i].content, style: TextStyle(color: Colors.grey),),
                      )
                    ),
                  );
                });
            }else{
              return Container(
                child: Text("Sorry no such messages"),
              );
            }
          },
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/messageModel.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class MessagePage extends StatefulWidget{

  MessagePage({this.database, this.receiver, this.sender, this.chatKey, this.check});
  final BaseDb database;
  final String receiver;
  final User sender;
  final String chatKey;
  final bool check;

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>{
  List<Message> messages = [];

  void mapMessagesToList() async{
    Map<dynamic, dynamic> dbMessages = await widget.database.getAllMessages(widget.chatKey);
    if(dbMessages != null){
      dbMessages.forEach((key, value) {
        User sender = User(
          id: value["sender"]["id"],
          createdAt: value["sender"]["createdAt"],
          username: value["sender"]["username"],
          email: value["sender"]["email"]
          );
        Message message = Message(
          time: value["time"],
          sender: sender,
          text: value["text"],
          isLiked: value["isLiked"],
          isRead: value["isRead"]
        );
        setState(() {
          if(!messages.contains(message)){
            messages.add(message);
          }
        });
    });
    }
    setState(() {
      messages.sort((a,b) => b.time.compareTo(a.time));
    });
  }

  Widget _buildMessage(Message message, bool isMe){ 
    final msg = Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: isMe
              ? EdgeInsets.only(
               top: 8.0, 
               bottom: 8.0, 
               left: 80.0
              ) 
              : EdgeInsets.only(
                top: 8.0, 
                bottom: 8.0,
              ),
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: isMe ? Colors.blueAccent: Colors.grey,
            borderRadius: isMe 
                  ? 
                  BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0)
                  ) 
                  :
                  BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                formatDateToHoursAndMinutes(message.time),
                style: TextStyle(
                  color: Colors.black, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 15.0),
                  ),
              SizedBox(height: 4.0,),
              Text(message.text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            ],
          ),
          );
    if(isMe){
      return msg;
    }else{
    return Row(
      children: <Widget>[
        msg,
        IconButton(
          icon: message.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          color: message.isLiked ? Colors.red : Colors.black,
          iconSize: 25.0,
          onPressed: (){},
        )
      ],
    );
    }
  }

  String text = "";
  final textField = TextEditingController();
  Widget _buildMessageComposer(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 40,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            onPressed: (){},
          ),
          Expanded(
            child: TextField(
              controller: textField,
              onChanged: (value) => text = value,
              decoration: InputDecoration.collapsed(hintText: "Send a message..",),
            )),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            onPressed: () => _sendMessage(text),
          )
        ]
      ),
    );
  }

  void _sendMessage(value){
    User sender = widget.sender;
    Message message = Message(
      text: value,
      isLiked: false,
      isRead: false,
      sender: sender,
      time: getCurrentDate()
    );
    if(value != "" && value != null){
      setState(() {
        messages.insert(0,message);
      });
    }
    widget.database.addMessage(
      message.text,
      sender,
      message.isLiked,
      message.isRead,
      getCurrentDate(),
      widget.chatKey
      );
    widget.database.updateLastMessageAndTime(widget.chatKey, message.text, getCurrentDate(), widget.check);
    textField.clear();
  }

  @override
  void initState(){
    mapMessagesToList();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: null,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.receiver),
        elevation: 0.0,//removes the shadow
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: (){},
          )
        ],),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(top: 15.0),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int i){
                      final Message message = messages[i];
                      final isMe = message.sender.id == widget.sender.id; //to differentiate which shows up on which side
                      return _buildMessage(message, isMe);
                    }),
                ),
              ),
            ),
            _buildMessageComposer(),
        ],),
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttermessenger/pages/GroupsPage.dart';
import 'package:fluttermessenger/pages/ChatsPage.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

class NavigatorPage extends StatefulWidget{

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  NavigatorPage({this.auth, this.logOutCallback, this.database});

  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage>{

  int _selectedIndex = 0;

  void _onTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: <Widget>[
         Offstage(
          offstage: _selectedIndex != 0,
          child: TickerMode(//removes animations
            enabled: _selectedIndex == 0,
            child: MaterialApp(
              home: ChatsPage(
                auth: widget.auth,
                database: widget.database,
                logOutCallback: widget.logOutCallback,
              )
            ),
          ),
        ),
        Offstage(
          offstage: _selectedIndex != 1,
          child: TickerMode(
            enabled: _selectedIndex == 1,
            child: MaterialApp(home: GroupsPage()),
          ),
        ),
        ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chats")
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text("Groups")
          )  
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: _onTap,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/pages/groups.dart';
import 'package:fluttermessenger/pages/chats.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

class NavigatorPage extends StatefulWidget{

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  final BaseDb database;
  final String currentUserId;
  final User currentUser;
  NavigatorPage({this.auth, this.logOutCallback, this.database, this.currentUserId, this.currentUser});

  @override
  _NavigatorPageState createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage>{

  int _selectedIndex = 0;
  bool _isVisible = true;

  void _onTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  void toggleBottomAppBarVisibility(){
    setState(() {
      _isVisible = !_isVisible;
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
                toggleBottomAppBarVisibility: toggleBottomAppBarVisibility,
              )
            ),
          ),
        ),
        Offstage(
          offstage: _selectedIndex != 1,
          child: TickerMode(
            enabled: _selectedIndex == 1,
            child: MaterialApp(
              home: GroupsPage(
                auth: widget.auth,
                database: widget.database,
                logOutCallback: widget.logOutCallback,
                toggleBottomAppBarVisibility: toggleBottomAppBarVisibility,
              )),
          ),
        ),
        ],
        ),
      bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: _isVisible ? 56.0 : 0.0,
          child: Wrap(
            children: <Widget>[
            BottomNavigationBar(
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
            unselectedItemColor: Colors.grey,
            onTap: _onTap,
            backgroundColor: Color(0xff2b2a2a),
        ),
            ]
          ),
      ),
    );
  }
}
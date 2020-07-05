import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/userModel.dart';
import 'package:fluttermessenger/pages/SignInUpPage.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

import 'NavigatorPage.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN
}

class RootPage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  RootPage({this.auth, this.database});

  @override
  _RootPageState createState() => _RootPageState();

}

class _RootPageState extends State<RootPage>{
  AuthStatus status = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  User currentUser;

  void loginCallBack(){
    widget.auth.getCurrentUser().then((user) => {
      setState((){
        status = AuthStatus.LOGGED_IN;
        _userId = user.uid.toString();
      })
    });
  }

  void logOutCallback(){
    setState(() {
      status = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  @override
  void initState(){
    widget.auth.getCurrentUser().then((user) => {
      widget.database.getUserObject(user.uid).then((userObject) => {
        setState((){
          if(user != null){
            _userId = user.uid;
          }
          status = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
          currentUser = userObject;
        })
      }),
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    switch (status) {
      case AuthStatus.NOT_DETERMINED:
        return waitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return SignInUpPage(
          auth: widget.auth,
          database: widget.database,
          loginCallback: loginCallBack
        );
      case AuthStatus.LOGGED_IN:
        if(_userId.length > 0 && _userId != null){
          return NavigatorPage(
            auth: widget.auth,
            logOutCallback : logOutCallback,
            database: widget.database,
            currentUser : currentUser
          );
        }else{
          return waitingScreen();
        }
        break;
      default:
        return waitingScreen();
        break;
    }
  }

  Widget waitingScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
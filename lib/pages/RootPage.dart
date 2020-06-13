import 'package:flutter/material.dart';
import 'package:fluttermessenger/pages/HomePage.dart';
import 'package:fluttermessenger/pages/SignInUpPage.dart';
import 'package:fluttermessenger/services.dart/authenitaction.dart';
import 'package:fluttermessenger/services.dart/database.dart';

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
      setState((){
        if(user != null){
          _userId = user.uid;
        }
        status = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      })
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
          return HomePage(
            auth: widget.auth,
            logOutCallback : logOutCallback,
            database: widget.database,
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
import 'package:flutter/material.dart';
import 'package:fluttermessenger/pages/SignInUpPage.dart';
import 'package:fluttermessenger/services/authenitaction.dart';

class CustomDrawer extends StatelessWidget{

  final BaseAuth auth;
  final VoidCallback logOutCallback;
  CustomDrawer({this.auth, this.logOutCallback});

  void _signOut() async {
    try{
      await this.auth.signOut();
      this.logOutCallback();
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: Container(
        child: ListView(children: <Widget>[
          Container(
            height: 63,
            child: DrawerHeader(
              child: Text("Choose your action"),
              decoration: BoxDecoration(color: Colors.blue),),
          ),
          Container(
            child: ListTile(
              title: Text("Sign in"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInUpPage())),
            ),
          ),
          Container(
            child: ListTile(
              title: Text("Sign up"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInUpPage())),
            ),
          ),
          Container(
            child: ListTile(
              title: Text("Sign out"),
              onTap: () => _signOut(),
            ),
          )
        ],
        ),
      )
      );
  }
}

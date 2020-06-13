import 'package:flutter/material.dart';
import 'package:fluttermessenger/pages/RootPage.dart';
import 'package:fluttermessenger/services.dart/authenitaction.dart';
import 'package:fluttermessenger/services.dart/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RootPage(auth: new Auth(), database: new Database()),//instatiating auth
    );
  }
}

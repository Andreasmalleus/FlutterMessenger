import 'package:flutter/material.dart';
import 'package:fluttermessenger/pages/root.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat app',
      home: RootPage(
          auth: Auth(),
          database: Database()
          ),
    );
  }
}

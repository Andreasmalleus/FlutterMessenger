import 'package:flutter/material.dart';
import 'package:fluttermessenger/services/authenitaction.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';

class SignInUpPage extends StatefulWidget{

  final BaseAuth auth;
  final BaseDb database;
  final VoidCallback loginCallback;
  SignInUpPage({this.auth,this.database, this.loginCallback});

  @override
  _SignInUpPageState createState() => _SignInUpPageState();

}

class _SignInUpPageState extends State<SignInUpPage>{

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email;
  String _password;
  String _username;
  String _cfmPassword;
  bool _signUpForm;
  bool _isLoading;

  String _emailValidator(String value){
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if(!regex.hasMatch(value)){
      return 'Email format is invalid';
    }else{
      return null;
    }
  } 

  String _usernameValidator(String value){
    if(value == ""){
      return 'Username format is invalid';
    }else{
      return null;
    }
  } 

  String _passwordValidator(String value){
    if(value.length < 8){
      return "Password must be atleast 8 characters long";
    }else{
      return null;
    }
  }
  Widget _usernameContainer(){
        if(_signUpForm){
      return Container(
              margin: EdgeInsets.all(10),
              width: 400,
              child: TextFormField(
                obscureText: false,
                validator: _usernameValidator,
                onSaved: (value) => _username = value.trim(),
                decoration: InputDecoration(
                    labelText: "Username", hintText: "john.wick",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: Color(0xfff3f3f4),
                    filled: true,
                )
              ),
            );
    }else{
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  Widget _pwdConfirmationContainer(){
    if(_signUpForm){
      return Container(
              margin: EdgeInsets.all(10),
              width: 400,
              child: TextFormField(
                obscureText: true,
                validator: _passwordValidator,
                onSaved: (value) => _cfmPassword = value.trim(),
                decoration: InputDecoration(
                    labelText: "Confirm password", hintText: "********",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: Color(0xfff3f3f4),
                    filled: true,
                )
              ),
            );
    }else{
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  void _resetForm() {
    _formKey.currentState.reset();
  }

  void _toggleFormMode(){
    _resetForm();
    setState((){
      _signUpForm = !_signUpForm;
    });
  }

  void _handleSignIn() async{
    String userId = "";
    userId = await widget.auth.signIn(_email, _password);
    print('Signed in user: $userId');
    if(userId.length > 0 && userId != null){
      widget.loginCallback();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addCreatedUserToDatabase(String userId, String email, String username, String createdAt, String imageUrl){
    widget.database.addUser(userId, email, username, createdAt, imageUrl);
  }

  void _handleSignUp() async{
    String createdAt = DateTime.now().toString();
    String userId = "";
    print("andmed: $_email, $_password");
    userId = await widget.auth.signUp(_email, _password);
    print('Signed up user: $userId');
    showSnackBar("User signed up", _scaffoldKey);
    _addCreatedUserToDatabase(userId, _email, _username, createdAt, "");
    setState((){
      _isLoading = false;
      _signUpForm = false;
    });
    _resetForm();

  }

  @override
  void initState() {
    _isLoading = false;
    _signUpForm = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff1A1A1A),
      appBar: AppBar(
        title: Text(_signUpForm ? "Sign up" : "Sign in", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        ),
        
      body: Form(
        key: _formKey,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(20),
                child: Text(_signUpForm ? "Sign up" : "Sign in", 
                  style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),)
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: 400,
                child: TextFormField(
                  validator: _emailValidator,
                  onSaved: (value) => _email = value.trim(),
                  decoration: InputDecoration(
                      labelText: "Email", hintText: "john.wick@gmail.com",
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      fillColor: Color(0xfff3f3f4),
                      filled: true,
                  )
                ),
              ),
              _usernameContainer(),
              Container(
                margin: EdgeInsets.all(10),
                width: 400,
                child: TextFormField(
                    validator: _passwordValidator,
                    onSaved: (value) => _password = value.trim(),
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password", hintText: "********",
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        fillColor: Color(0xfff3f3f4),
                        filled: true,
                    )
                ),
              ),
              _pwdConfirmationContainer(),
              Container(
                margin: EdgeInsets.all(10),
                width: 400,
                height: 55,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_signUpForm ? "Sign up" : "Sign in", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                  color: Colors.white,
                  onPressed: () => {
                    if(_formKey.currentState.validate()){
                      _formKey.currentState.save(),
                      if(_signUpForm){
                        if(_password == _cfmPassword){
                        setState((){
                          _isLoading = true;
                        }),
                        _handleSignUp(),
                        }
                      }else{
                        setState(() {
                          _isLoading = true;
                        }),
                        _handleSignIn(),
                      } 
                    }
                  }
                  ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () => _toggleFormMode(),
                  child: Container(
                    child: Text(_signUpForm ? "Already have an account" : "Dont have an account?", style: TextStyle(color: Colors.grey),),
                  )
                ),
              ),
              _showCircularProgress()
            ]
          )
        ),
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

}


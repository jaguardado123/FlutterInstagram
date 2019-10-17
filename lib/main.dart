import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'posts.dart';
import 'addPost.dart';
import 'profile.dart';

void main() => runApp(MyApp());
String url = 'http://serene-beach-48273.herokuapp.com';
var id = '';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram App',
      home: LoginPage(),
    );
  }
}

Widget instaTitle() {
  return Row(children: <Widget>[ 
    Image.asset('assets/logo.jpg', scale: 20,),
    //Image.asset('assets/logo.jpg', height: 35),
    Padding(padding: EdgeInsets.only(right: 20.0)),
    Text('MyInstagram', style: TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 20))
  ]);
}

class LoginPage extends StatefulWidget {
  LoginPage();
  @override
  _LoginPage createState() => _LoginPage();
}

//Login page. If user has an account they are given access to use the instagram_app.
class _LoginPage extends State<LoginPage> {
  var username =TextEditingController();
  var password =TextEditingController();

  void goToPosts(context) async {
    var token =await login();
    if (token == 'error')
      return;
    var posts = await http.get('$url/api/v1/posts', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    var my_posts =await http.get('$url/api/v1/my_posts', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    var my_info = await http.get('$url/api/v1/my_account', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => HomePage(token, jsonDecode(posts.body), jsonDecode(my_posts.body), jsonDecode(my_info.body))
      )
    );
  }

  //Logs the user in through get request.
  Future<String> login() async{
    String loginUrl = '$url/api/login?username=${username.text}&password=${password.text}';
    var response = await http.get(loginUrl);
    if (response.statusCode != 200)
      return 'error';
    return jsonDecode(response.body)['token'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: instaTitle(),
        backgroundColor: Colors.white,),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/profile.jpg'), fit: BoxFit.cover)
        ),
        child:
        ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(30.0),
            child:
              Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))         
                    ),
                child: Column(
                  children: <Widget>[
                    //Padding(padding: EdgeInsets.only(top: 10.0), child: Icon(Icons.person, color: Colors.black, size: 50,)),
                    Padding(padding: EdgeInsets.only(top: 10.0), child: Image.asset('assets/logo.jpg', scale: 10,)),
                    Text('Welcome!', style: TextStyle(color: Colors.redAccent, fontFamily: 'Pacifico', fontSize: 42)),
                    Padding(padding: EdgeInsets.only(bottom: 5.0), child: Text('Login', style: TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 22))),
                    Padding(padding: EdgeInsets.all(10.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.black12)), child: TextField(decoration: InputDecoration(labelText: ' Username'), controller: username))),
                    Padding(padding: EdgeInsets.all(10.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(color: Colors.black12)), child: TextField(decoration: InputDecoration(labelText: ' Password'), obscureText: true, controller: password))),
                    Padding(padding: EdgeInsets.only(bottom: 10.0), child: RaisedButton( color: Colors.white70,
                      child: Text('Enter', style: TextStyle(color: Colors.black54),),
                      onPressed: () {
                      goToPosts(context);
                      },))
                  ],
                )
              )
            )
          ],
        )
      )
    );
  }
}

class HomePage extends StatefulWidget {
  var token, my_info;
  List<dynamic> posts, my_posts;
  HomePage(this.token, this.posts, this.my_posts, this.my_info); 

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  //var token, my_info;
  //List<dynamic> posts, my_posts;
  //HomePage(this.token, this.posts, this.my_posts, this.my_info);

  void update(var token) async {
    var posts = await http.get('$url/api/v1/posts', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    setState(() {
      widget.posts = jsonDecode(posts.body);
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => LoginPage()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(title: Row(children: <Widget>[    Image.asset('assets/logo.jpg', scale: 20,),
                Padding(padding: EdgeInsets.only(right: 20.0)),
                Text('MyInstagram', style: TextStyle(color: Colors.black, fontFamily: 'Pacifico', fontSize: 20)),
                Padding(padding: EdgeInsets.only(right: 60.0),),
                IconButton(icon: Icon(Icons.replay), color: Colors.black, onPressed: () => setState((){update(widget.token);})),
                IconButton(icon: Icon(Icons.exit_to_app), color: Colors.black, onPressed: () => {logout()},)
                ],),
                backgroundColor: Colors.white,
              ),
          body: TabBarView(
            children: <Widget>[
              PostsPage(widget.posts, widget.token, widget.my_info), 
              AddPost(widget.token), 
              MyPosts(widget.my_posts, widget.my_info, widget.token)
            ]
          ),
          bottomNavigationBar: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.photo_album)),
              Tab(icon: Icon(Icons.add_a_photo)),
              Tab(icon: Icon(Icons.account_box))
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.red,
          )
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'main.dart';
import 'intermediate.dart';

class UserPosts extends StatelessWidget {

  var token, info, my_info;
  List<dynamic> posts;
  UserPosts(this.posts, this.info, this.token,);

  String getName(String name) {
    name = name.replaceFirst('.', ' ');
    name = name.replaceAll('01', '');
    name = name.replaceAll('02', '');
    name = name.replaceAll('03', '');
    name = name.replaceAll('04', '');
    name = name.replaceAll('@utrgv.edu', ' ');
    name = name[0].toUpperCase()+name.substring(1);
    for(int i = 0; i < name.length; i++) if(name[i]==' '){name = name.substring(0,i+1)+name[i+1].toUpperCase()+name.substring(i+2); break;}
    return name;
  }

  Widget myInfo() {
    return Container(
      
      padding: EdgeInsets.all(10.0),
      child:
      Column(
        children: <Widget>[
          Image.network(info['profile_image_url']),
          /*
          Container(
            width: 200.0, 
            height: 200.0, 
            decoration: BoxDecoration(shape: BoxShape.circle, 
              image: DecorationImage(
                image: NetworkImage(info['profile_image_url'])
              ),
              border: Border.all(color: Colors.white)
            )
          ),*/
          Padding(padding: EdgeInsets.only(top: 10.0, bottom: 17.0),
            child:
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                padding: EdgeInsets.all(10.0),
                child: Column(children: <Widget>[
                  Text(getName(info['email'].toString()), style: TextStyle(color: Colors.redAccent, fontSize: 32, fontFamily: 'Pacifico')),
                  Padding(padding: EdgeInsets.all(2.0),),
                  Text('Email: ${info['email'].toString()}', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(2.0),),
                  Text('Bio:', style: TextStyle(color: Colors.black, fontSize: 16)),
                  Text('${info['bio'].toString()}', style: TextStyle(color: Colors.black, fontSize: 16)),
                ]),
              )
          )
        ],
      )
    );
  }

  void getInfo() async {
    my_info = await http.get('$url/api/v1/my_account', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  }

  @override
  Widget build(BuildContext context) {
    getInfo();
    return Scaffold(
      appBar: AppBar(title: instaTitle(), backgroundColor: Colors.white, iconTheme: IconThemeData(color: Colors.black),),
      body: ListView.builder(
        itemCount: posts.length + 1,
        itemBuilder: (BuildContext cntxt, int index) {
          return (index == 0) ?
          Padding(padding: EdgeInsets.all(0.0), child: myInfo())
          :
          Intermediate(posts[index - 1], my_info, token);
        },
      ),
    );
  }
}
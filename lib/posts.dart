import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'main.dart';
import 'comments.dart';
import 'intermediate.dart';
import 'user.dart';

//Global function that returns a widget containing the users image and email.
Widget profileImage(var post, var context, int type, var token) {
  String image_url = (type!=2) ? 'user_profile_image_url' : 'profile_image_url';
  String email = (type!=2) ? 'user_email' : 'email';
  String user = (type !=2) ? 'user_id' : 'id';
  var comment = TextEditingController();
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(topRight: Radius.circular(25.0), topLeft: Radius.circular(25.0)),
    ),
    child: Row(children: <Widget>[
      Padding(padding: EdgeInsets.only(right: 10.0, top: 10.0, left: 10.0, bottom: 5.0), 
        child: InkWell(
          child:Container(
            child: Ink( child: InkWell( onTap:() => goToUser(post[user], context, token))),
            width: 40.0, 
            height: 40.0, 
            decoration: BoxDecoration(shape: BoxShape.circle, 
              image: DecorationImage(
                image: NetworkImage(post[image_url])
              ),
              border: Border.all(color: Colors.redAccent)
            )
          )
        )
      ),
      Container(child: (type>2) ?
        Container(
          //height: 40, 
          width: 200, 
          decoration: BoxDecoration(border: Border.all(color: Colors.black26)), 
          child: TextField(controller: comment,)
        )
        : Text(post[email], style: TextStyle(fontWeight: FontWeight.bold))
      ),
      Container(child: (type>2) ? 
        ButtonTheme(height: 44, minWidth: 70,child: 
          RaisedButton(color: (type>3) ? Colors.blueGrey : Colors.blueAccent, 
          child: Text('Post', style: TextStyle(color: (type>3) ? Colors.black : Colors.white)), 
          onPressed: () => newComment(post, comment,token))
        )
        : Container()
      )
    ])
  );
}

  //function goes to UserPage.
void goToUser(var id, var context, var token) async {
  var user = await http.get('$url/api/v1/users/${id.toString()}', headers: {HttpHeaders.authorizationHeader: 'Bearer ${token.toString()}'});
  var posts = await http.get('$url/api/v1/users/${id.toString()}/posts', headers: {HttpHeaders.authorizationHeader: 'Bearer ${token.toString()}'});
  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (context) => 
          UserPosts(jsonDecode(posts.body), jsonDecode(user.body),token)
    )
  ); 
}

///////////////// PostPage class that displays all available posts.


class PostsPage extends StatelessWidget {
  var token, my_info;
  List<dynamic> posts;
  PostsPage(this.posts, this.token, this.my_info);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext cntxt, int index) {
            return Intermediate(posts[index], my_info, token);
          },
        ),

    );
  }
}
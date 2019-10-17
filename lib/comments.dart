import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'posts.dart';
import 'main.dart';

//sends a post request to create a new comment.
void newComment(var post, var my_comment, var token) async {
  await http.post('$url/api/v1/posts/${post['id']}/comments?text=${my_comment.text}', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
}

/////////////////// CommentsPage containing all comments, and user info corresponding to each user who commented.
class CommentsPage extends StatefulWidget {
  var post, token, my_info;
  List<dynamic> comments = [], users;
  CommentsPage(this.comments, this.post, this.my_info, this.token);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

//////////////// CommentsPage
class _CommentsPageState extends State<CommentsPage> {

  var my_comment = TextEditingController();

  Widget commentsTitle() {
    return Row(children: <Widget>[
      Icon(Icons.comment, color: Colors.black, size: 30,),
      Padding(padding: EdgeInsets.only(right: 30.0)),
      Text('Comments', style: TextStyle(color: Colors.black))
    ]);
  }

  void updateComment() async {
    String url_comments = '$url/api/v1/posts/${widget.post['id']}/comments';
    var comments = await http.get(url_comments, headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.token.toString()}'});
    setState(() {
      widget.comments = jsonDecode(comments.body);
    });
  }

  Widget userImage(var info) {
    return 
        Padding(padding: EdgeInsets.all(10.0),
          child: Container(width: 50.0, height: 50.0, 
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              image: DecorationImage(image: NetworkImage(info['profile_image_url'])),
              border: Border.all(color: Colors.blueAccent)
            )
          )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: commentsTitle(),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        child: ListView(children: <Widget>[
          Row(children: <Widget>[ 
            userImage(widget.my_info),
            Container(
              width: 200, 
              decoration: BoxDecoration(border: Border.all(color: Colors.black26)), 
              child: TextField(controller: my_comment,)
            ),
            ButtonTheme(
              height: 44, 
              minWidth: 70,
              child: RaisedButton(
                color: Colors.blueAccent, 
                child: Text('Post', style: TextStyle(color: Colors.black)), 
                onPressed: () => 
                  setState(() {
                    newComment(widget.post, my_comment, widget.token);   
                    updateComment();  
                  })
              )
            )
          ]),
          Container(
            height: 450,
            child: IntermediateComm(widget.comments, widget.token)
          )
        ])
      )
    );
  }
}

//returns a single widget containing the user's image, email, and a button to remove a comment if it is mine.
Widget userImage(var user) {
  return Row(children: <Widget>[
    Padding(padding: EdgeInsets.all(5.0), 
      child: Container(width: 40.0, height: 40.0, 
        decoration: BoxDecoration(shape: BoxShape.circle, 
          image: DecorationImage(
            image: NetworkImage(user['profile_image_url'])
          ),
        )
      )
    ),
    Text('${user['email']}: ', style: TextStyle(fontWeight: FontWeight.bold),),
  ]);
}

class IntermediateComm extends StatefulWidget {
  var token;
  List<dynamic> comments;
  IntermediateComm(this.comments, this.token);

  @override
  _IntermediateComm createState() => _IntermediateComm();
}


class _IntermediateComm extends State<IntermediateComm> {
  //sends delete request to remove a comment.
  void removeComment(var comment) async {
    await http.delete('$url/api/v1/comments/${comment['id']}', headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.token}'});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.comments.length,
      itemBuilder: (BuildContext cntxt, int index) {
        bool cntrl = widget.comments[index]['belongs_to_current_user'];
        return (widget.comments[index]['id']<0) 
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ 
                userImage(widget.comments[index]['user']),
                Container(padding: EdgeInsets.only(left: 60.0, bottom: (cntrl) ? 5.0 : 20.0), child: Text('${widget.comments[index]['text']}')),
                (cntrl) 
                  ? Padding(padding: EdgeInsets.only(left: 60.0, bottom: 20.0), 
                      child: InkWell(onTap: () => 
                        setState((){
                          removeComment(widget.comments[index]);
                          widget.comments[index]['id'] = -99;
                        }), 
                      child: Text('remove', style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline))
                      )
                    ) 
                  : Container()
            ]);
      }
    );
  }
}

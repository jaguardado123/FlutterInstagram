import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'main.dart';
import 'comments.dart';
import 'posts.dart';

/////////////////// Intermediate class, used to display all content of a single post (post image, content, user info,...ect.).
class Intermediate extends StatefulWidget {

  var token, post, my_info;
  Intermediate(this.post, this.my_info,this.token, {Key key}) :super(key: key);
  @override
  _IntermediateState createState() => _IntermediateState();
}

////////////////// Intermediate class.
class _IntermediateState extends State<Intermediate> {
  List<dynamic> commentsView = [];

  var commentCntrl = false;
  var commentCntrlView = false;
  //function that returns a post image.
  Widget getImage(var post) {
      return Image.network(post['image_url'],);
      //return Container(decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),child: Center(child: Image.network(post['image_url'], height: 250,)));
  }

  //sends post request to like a post.
  void like(var id, var token) async {
    http.post('$url/api/v1/posts/${id.toString()}/likes', headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
  }

  //sends delete request to unlike a post.
  void unlike(var id, var token) async {
    http.delete('$url/api/v1/posts/$id/likes', headers: {HttpHeaders.authorizationHeader: 'Bearer ${token.toString()}'});
  }

  void getCommentsView(var id) async {
    String url_comments = '$url/api/v1/posts/${id.toString()}/comments';
    var comm = await http.get(url_comments, headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.token.toString()}'});
    setState(() {
      commentsView = jsonDecode(comm.body);
    });
  }

  //returns user info to be ussed in comments(I think Eric has updated code, this function may not be needed).
  Future<List<dynamic>> userInfo(List<dynamic> comment) async {
    print('Step One\n');
    List<dynamic> user_info = new List(comment.length);
    var test;
    for(int i = 0; i < comment.length; i++) {
      var info = await http.get('$url/api/v1/users/${comment[i]['user_id']}', headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.token}'});
      print(info.statusCode);
      user_info[i] = jsonDecode(info.body);
    }
    return user_info;
  }

  //redirects to the CommentsPage displaying individual user info and their comments.
  void goToComments(var post) async {
    String url_comments = '$url/api/v1/posts/${post['id']}/comments';
    var comments = await http.get(url_comments, headers: {HttpHeaders.authorizationHeader: 'Bearer ${widget.token.toString()}'});
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CommentsPage(jsonDecode(comments.body), post, widget.my_info, widget.token)
      )
    );  
  }

  Widget commentsWindow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start ,children: <Widget> [ Padding(padding: EdgeInsets.all(10), child: Container(
          height: 160,
          child: ListView.builder(
            itemCount: commentsView.length,
            itemBuilder: (BuildContext cntxt, int index) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: <Widget>[
                      InkWell(
                        onTap:() => goToUser(widget.post[index]['user_id'], context, widget.token),
                        child:Container(
                          width: 40.0, 
                          height: 40.0, 
                          decoration: BoxDecoration(shape: BoxShape.circle, 
                            image: DecorationImage(
                              image: NetworkImage(commentsView[index]['user']['profile_image_url'])
                            ),
                            border: Border.all(color: Colors.redAccent)
                          )
                        )
                      ),
                      Padding(padding: EdgeInsets.all(5.0),),
                      Text('${commentsView[index]['user']['email']}', style: TextStyle(fontWeight: FontWeight.bold),)
                    ],),
                    Padding(padding: EdgeInsets.only(left: 50), child: Text('${commentsView[index]['text']}')),
                    Padding(padding: EdgeInsets.only(left: 50, bottom: 15), child: Text('${commentsView[index]['created_at'].toString().substring(6,10)} at ${commentsView[index]['created_at'].toString().substring(11,16)}', style: TextStyle(color: Colors.grey, fontSize: 10))),
                ])
              );
            },
          ),
        )),
        InkWell(onTap: () => {goToComments(widget.post)},child: Text('   Go to comments...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 ,),)),
        Padding(padding: EdgeInsets.all(5.0),)
        ]);
  }


  Widget body() {
    bool commented = false;
    var comment = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[
          IconButton(
            icon: widget.post['liked'] ? Icon(Icons.favorite) : Icon(Icons.favorite_border), 
            color: widget.post['liked'] ? Colors.red : Colors.black, onPressed: () =>
              setState(()
                {
                  if (!widget.post['liked']) {
                    widget.post['likes_count']++;
                    widget.post['liked'] = true;
                    like(widget.post['id'], widget.token);
                  }
                  else {
                    widget.post['likes_count']--;
                    widget.post['liked'] = false;
                    unlike(widget.post['id'], widget.token);
                  }
                }
              ),
          ),
          IconButton(
            icon: Icon(Icons.comment,),
            color: Colors.black, 
            onPressed: () =>
              setState(() 
              {
                //widget.post['likes_count'] = widget.post['likes_count'];
                //widget.post['comments_count'] = widget.post['comments_count'];
                if (commentCntrl)
                  commentCntrl = false;
                else
                  commentCntrl = true; 
                
                if (commented) {
                  commented = false;
                  widget.post['comments_count']++;
                }
                
              }
            )
          ),
        ],),
        Container(padding: EdgeInsets.only(left: 10),
          child: Text('${widget.post['likes_count'].toString()} likes', style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        Container(padding: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0), 
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(
              '${widget.post['user_email'].toString().replaceFirst('@utrgv.edu', ' ')}:', 
              style: TextStyle(fontWeight: FontWeight.bold,)
            ),
            Text('${widget.post['caption']}')
          ])
        ), 
        (commentCntrl) ? Padding(padding: EdgeInsets.all(3.0), 
          child: Row(children: <Widget>[
            Padding(padding: EdgeInsets.all(15.0), child: Container(width: 40.0, height: 40.0, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                image: DecorationImage(image: NetworkImage(widget.my_info['profile_image_url']))
              )
            )),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                border: Border.all(color: Colors.black12)
              ),
              width: 200, 
              child: TextField(decoration: InputDecoration(hintText: ' Comment'),controller: comment,)
            ),
            ButtonTheme(height: 44, minWidth: 70,child: 
              RaisedButton(color: Colors.white70, 
                child: Text('Post', style: TextStyle(color: Colors.black54)), 
                onPressed: () => setState(() {
                  newComment(widget.post, comment, widget.token);
                  widget.post['comments_count']++;
                  //widget.post['likes_count'] = widget.post['likes_count'];
                  //setState(() {
                  //commentCntrl = false;//; }) 
                  comment.clear();     
                  commented = true;        
                })
                //;}
              )
            )
          ])
        )
       : Container(),
        Container(padding: EdgeInsets.only(left: 10.0, bottom: 5.0), 
          child: InkWell(onTap: () => setState((){ 
            if(!commentCntrlView) {
              getCommentsView(widget.post['id']); 
              commentCntrlView = true;}
            else 
              commentCntrlView = false;
            }
          ), 
          child: Text('view all ${widget.post['comments_count'].toString()} comments', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),)
        )),
        (commentCntrlView) 
        ? commentsWindow()
        : Container(),
        Container(padding: EdgeInsets.only(left: 10.0, bottom: 5.0),child: Text('${widget.post['created_at'].toString().substring(6,10)} at ${widget.post['created_at'].toString().substring(11,16)}', style: TextStyle(color: Colors.grey, fontSize: 10))),
        Padding(padding: EdgeInsets.all(5.0),)
    ]);
  }
//
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0, bottom: 5.0),
            child: profileImage(widget.post, context, 1, widget.token)
          ),
          InkWell(
            onDoubleTap: () => setState(() {
              if (!widget.post['liked']) {
                widget.post['likes_count']++; 
                widget.post['liked'] = true; 
                like(widget.post['id'], widget.token);
              }
              else {
                widget.post['likes_count']--; 
                widget.post['liked'] = false; 
                unlike(widget.post['id'], widget.token);               
              }
            }), 
            child: getImage(widget.post)
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25.0), bottomRight: Radius.circular(25.0)),
              ),
              child: body(),
            )
          ),
          Padding(padding: EdgeInsets.all(5.0),)
        ],)
    );
  }
}
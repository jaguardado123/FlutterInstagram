import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'intermediate.dart';

class MyPosts extends StatefulWidget {
  var token, info;
  List<dynamic> posts;
  MyPosts(this.posts, this.info, this.token, {Key key}) :super(key: key);
  @override
  _MyPostsPage createState() => _MyPostsPage();
}

class _MyPostsPage extends State<MyPosts> {
  File _image;
  var bio = TextEditingController();
  bool editCntrl = false;
  bool responseCntrl = false;
  bool deleteCntrl = false;

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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<Response> upload(var token, var bio) async{
    FormData formData = new FormData.from({
      "image": new UploadFileInfo(_image, _image.path)
    });

    var response = await Dio().patch("http://serene-beach-48273.herokuapp.com/api/v1/my_account/profile_image", data: formData, options: Options(
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token"
      },
    ),);
    await http.patch("http://serene-beach-48273.herokuapp.com/api/v1/my_account?bio=${bio.text}", headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});
    return response;
  }

  Widget myInfo() {
    return Container(

      padding: EdgeInsets.all(10.0),
      child:
      Column(
        children: <Widget>[
          Image.network(widget.info['profile_image_url']),
          /*
          Container(
            width: 200.0, 
            height: 200.0, 
            decoration: BoxDecoration(shape: BoxShape.circle, 
              image: DecorationImage(
                image: NetworkImage(widget.info['profile_image_url'])
              ),
              border: Border.all(color: Colors.redAccent)
            ),
            child: Text('data'),
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
                  Text(getName(widget.info['email'].toString()), style: TextStyle(color: Colors.redAccent, fontSize: 32, fontFamily: 'Pacifico')),
                  Padding(padding: EdgeInsets.all(2.0),),
                  Text('Email: ${widget.info['email'].toString()}', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.all(2.0),),
                  Text('Bio:', style: TextStyle(color: Colors.black, fontSize: 16)),
                  Text('${widget.info['bio'].toString()}', style: TextStyle(color: Colors.black, fontSize: 16)),
                ]),
              )
          ),
          Row(children: <Widget> [
            Padding(padding: EdgeInsets.only(left: 100.0),), 
            FloatingActionButton(backgroundColor: Colors.redAccent, child: Icon(Icons.edit, color: Colors.white,), onPressed: () => setState((){(editCntrl)?editCntrl = false:editCntrl = true; responseCntrl = false;}),),
            Padding(padding: EdgeInsets.only(left: 20.0),), 
            FloatingActionButton(backgroundColor: Colors.redAccent, child: Icon(Icons.delete_forever, color: Colors.white,), onPressed: () => setState((){if(!deleteCntrl) deleteCntrl = true; else deleteCntrl = false;}),)
          ]),
          Padding(padding: EdgeInsets.all(10.0),),
          (editCntrl) 
          ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.black12)
            ),
            child: Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10.0), child: Text('Profile Image:', style: TextStyle(fontFamily: 'Pacifico', fontSize: 18))),
              (_image==null) 
              ? Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0, ), child: Image.network(widget.info['profile_image_url'], scale: 5,),)
              : Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0, ), child: Image.file(_image, scale: 5,),),
              RaisedButton(color: Colors.white70, child: Text('New', style: TextStyle(color: Colors.black26),), onPressed: () => setState((){getImage();}),),
              Padding(padding: EdgeInsets.all(5.0),),
              Text('Bio:', style: TextStyle(fontFamily: 'Pacifico', fontSize: 18)),
              Padding(padding: EdgeInsets.only(left: 15.0, right: 15.0, ), child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.black12)), child: TextField(decoration: InputDecoration(hintText: '${widget.info['bio'].toString()}'),controller: bio,))),
              RaisedButton(color: Colors.white70, child: Text('Submit', style: TextStyle(color: Colors.black26),), onPressed: () => setState((){upload(widget.token, bio); responseCntrl = true;}),),
              Padding(padding: EdgeInsets.all(5.0),),
              (responseCntrl) 
              ? Padding(padding: EdgeInsets.all(10.0), child: Container(child: Icon(Icons.check_circle, color: Colors.green, size: 80,),),)
              : Container()
              
            ],),
          )
          : Container()
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.posts.length + 1,
        itemBuilder: (BuildContext cntxt, int index) {
          return (index == 0) ?
          Padding(padding: EdgeInsets.all(0.0), child: myInfo())
          : Column(children: <Widget>[
          (deleteCntrl) ? Text('Delete?', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20, decoration: TextDecoration.underline)) : Container(),
          Intermediate(widget.posts[index - 1], widget.info, widget.token)
          ]);
        },
      ),

    );
  }
}
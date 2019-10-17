import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';



class AddPost extends StatefulWidget {
  var token;
  AddPost(this.token, {Key key}) :super(key: key);
  @override
  _AddPostPage createState() => _AddPostPage();
}

class _AddPostPage extends State<AddPost> {

  File _image = null;

  void gets() async {
    await getImage();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<Response> upload(var token, var caption) async{
    FormData formData = new FormData.from({
      "caption": '${caption.text}',
      "image": new UploadFileInfo(_image, _image.path)
    });
    var response = await Dio().post("http://serene-beach-48273.herokuapp.com/api/v1/posts", data: formData, options: Options(
    headers: {
      HttpHeaders.authorizationHeader: "Bearer $token"
    },
  ),);
    return response;
  }

  var caption =TextEditingController();
  var image;
  var contrl = false;

  Widget build(BuildContext context) {
    
    return Scaffold(
      body: (!contrl) ? ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Container(
              decoration: BoxDecoration(
                //image: DecorationImage(image: AssetImage('assets/profile.jpg'), fit: BoxFit.cover),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                border: Border.all(color: Colors.black12)
              ),
              child: Column(children: <Widget>[
                Text('New Post', style: TextStyle(fontFamily: 'Pacifico', color: Colors.redAccent, fontSize: 38)),
                (_image == null) ?  Padding(padding: EdgeInsets.all(10.0),
                  child: Container(decoration: 
                    BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12
                    ),
                    padding: EdgeInsets.all(15),
                    child: Icon(Icons.photo_library, color: Colors.white, size: 120,),
                  )
                )
                : Padding(padding: EdgeInsets.all(10.0), child: Container(color: Colors.white70, padding: EdgeInsets.all(2.0), child: Image.file(_image, height: 200,))),
                Padding(padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 85.0, right: 10.0),
                      child:
                      FloatingActionButton(
                        child: Icon(Icons.photo_library, size: 30, color: Colors.white,), 
                        backgroundColor: Colors.redAccent,
                        onPressed: () => getImage()
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10.0, right: 80.0),
                      child:
                      FloatingActionButton(
                        child: Icon(Icons.photo_camera, size: 30), 
                        backgroundColor: Colors.redAccent,
                        onPressed: () => getImage(),
                      ),
                    )
                  ],)
                ),
                Padding(padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 22.0, right: 22.0),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0),), color: Colors.white70),
                    padding: EdgeInsets.all(10.0),
                    child: Column(children: <Widget>[
                      Text('Caption', style: TextStyle(fontSize: 20, fontFamily: 'Pacifico', color: Colors.black)),
                      Padding(padding: EdgeInsets.all(5.0),),
                      Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), border: Border.all(color: Colors.black12)), child: TextField(decoration: InputDecoration(hintText: ' Post description'), controller: caption,))
                    ])
                  )
                ), 
                Padding(padding: EdgeInsets.only(bottom: 10.0), 
                  child: RaisedButton(child: Text('Post', style: TextStyle(color: Colors.black54),), 
                  color: Colors.white70, 
                  onPressed: () => setState((){
                    upload(widget.token, caption);
                    //_image = null
                    contrl = true;
                  },))
                )
            ],)
            )
          )
        ],
      )
      : ListView(
        children: <Widget>[
          Column(children: <Widget>[
            Text('All Done!', style: TextStyle(fontFamily: 'Pacifico', fontSize: 42, color: Colors.redAccent),),
          Padding(padding: EdgeInsets.all(10.0), child: Container(color: Colors.white70, padding: EdgeInsets.all(2.0), child: Image.file(_image, height: 200,))),
          Text('Caption', style: TextStyle(fontFamily: 'Pacifico', fontSize: 20),),
          Padding(padding: EdgeInsets.only(top: 3, bottom: 10), child: Text('${caption.text.toString()}')),
          InkWell(onTap: () => setState((){contrl = false; _image = null; caption.clear();}), child: Padding(padding: EdgeInsets.all(10.0), child: Container(child: Icon(Icons.check_circle, color: Colors.green, size: 80,),),)),
          ])
        ],
      )
    );
  }
}
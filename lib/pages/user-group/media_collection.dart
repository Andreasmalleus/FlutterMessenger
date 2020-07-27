import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/storage_file.dart';
import 'package:fluttermessenger/services/database.dart';

class MediaCollectionPage extends StatefulWidget{

  MediaCollectionPage({this.database, this.typeId});
  final BaseDb database;
  final String typeId;

  @override
  _MediaCollectionPageState createState() => _MediaCollectionPageState();
}

class _MediaCollectionPageState extends State<MediaCollectionPage> {


  List<StorageFile> files = List<StorageFile>();
  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos and videos"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: widget.database.listAllStorageFilesById(widget.typeId),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
          files = snapshot.data;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ), 
            itemCount: files.length,
            itemBuilder: (BuildContext context, int i){
              return Container(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailPage(url: files[i].url, name: files[i].name,))),
                  child: Container(
                    child: Image.network(files[i].url, fit: BoxFit.cover,)
                  ),
                ),
              );
            });
          }else{
            return Container(
              alignment: Alignment.center,
              child: Text("No images so far", style: TextStyle(fontSize: 20),),
            );
          }
        },
      )
    );
  }
}

class DetailPage extends StatefulWidget{

  DetailPage({this.url, this.name});
  final String url;
  final String name;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    super.dispose();
  }

  Widget build(BuildContext context){
    return Container(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Hero(
          tag: widget.name,
          child: Image.network(widget.url),
        ),
      ),
    );
  }
}
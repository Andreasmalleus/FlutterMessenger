import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttermessenger/models/message.dart';
import 'package:fluttermessenger/models/storage_file.dart';
import 'package:fluttermessenger/models/user.dart';
import 'package:fluttermessenger/services/database.dart';
import 'package:fluttermessenger/utils/utils.dart';
import 'package:path/path.dart' as path;


class CustomMediaPicker extends StatefulWidget{

  final User sender;
  final BaseDb database;
  final String convTypeId;
  final bool isChat;

  CustomMediaPicker({this.sender, this.database, this.convTypeId, this.isChat});
  
  @override
  _CustomMediaPickerState createState() =>  _CustomMediaPickerState();

}

class _CustomMediaPickerState extends State<CustomMediaPicker>{

  String dirPath= "";
  List files = List();
  int _selectedIndex;
  bool _isSelected;

  Future<String> _getPath() async {
    return await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }

  Future<dynamic> _getListOfFiles() async{
    String dir = await _getPath();
    files = Directory(dir).listSync();
    return files;
  }

  String getFileType(String p){
    return path.basename(p).split('.')[1];
  }
  String getFileName(String p){
    return path.basename(p).split('.')[0];
  }

  void _addImageToDatabaseAndStorage() async{
    String path = files[_selectedIndex].path;
    String time = getCurrentDate();
    String fileName = getFileName(path);
    String url;
    StorageFile storageFile;
    if(widget.isChat){
      url = await widget.database.uploadFileToChatStorage(File(path), widget.convTypeId, widget.sender.id, fileName);
      storageFile = StorageFile(
        userId: widget.sender.id,
        name: fileName,
        url: url
      );
      await widget.database.fileUrlToDatabase(widget.convTypeId, storageFile, widget.isChat);
    }else{
      url = await widget.database.uploadFileToGroupStorage(File(path), widget.convTypeId, widget.sender.id, fileName);
      storageFile = StorageFile(
        userId: widget.sender.id,
        name: fileName,
        url: url
      );
      await widget.database.fileUrlToDatabase(widget.convTypeId, storageFile, widget.isChat);
    }
    Message message = Message(
      content: url,
      sender: widget.sender,
      isLiked: false,
      isRead: false,
      time: time,
      type: "image"
    );
    await widget.database.addMessage(widget.convTypeId, message, widget.isChat);
  }
  Widget _sendButton(){
    if(_isSelected){
        return GestureDetector(
          onTap: () => _addImageToDatabaseAndStorage(),
          child: Align(
            alignment: Alignment.bottomCenter,
              child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.3 ,
              height: MediaQuery.of(context).size.height * 0.08 ,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration( color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(15))),
               child: Text("Send", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
          ),
        );
    }else{
      return Container(
        width: 0,
        height: 0,
      );
    }

  }

  Widget image(String filePath, bool selected){
    if(selected){
      return ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
          child: Image.file(
            File(filePath),
            fit: BoxFit.cover,
          )
      );
    }else{
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
      );
    }
  }

  void initState(){
    _isSelected = false;
    super.initState();
  }

  Widget build(BuildContext context){
    return FutureBuilder<dynamic>(
      future: _getListOfFiles(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Expanded(
            child: Container(
              child: Stack(
                children: [ GridView.builder(
                  physics: ScrollPhysics(),
                  itemCount: files.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ), 
                  itemBuilder: (context, i){
                    String file = files[i].path;
                    return GestureDetector(
                      onTap: () => {
                        print(file + " selected"),
                        if(_selectedIndex != i){
                          setState((){
                            _selectedIndex = i;
                            _isSelected = true;
                          })
                        }else{
                           setState((){
                            _selectedIndex = null;
                            _isSelected = false;
                          })
                        }
                      },
                      child: Container(
                        child:
                        _selectedIndex == i
                        ?
                        image(file, true)
                        :
                        image(file, false)
                      ),
                    );
                  }),
                  _sendButton()
                ]
              ),
            ),
          );
        }else{
          return Container(
            child: CircularProgressIndicator(),
          );
        }
      },
        
    );
  }
}
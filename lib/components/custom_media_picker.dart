import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
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
    String message = files[_selectedIndex].path;
    String time = getCurrentDate();
    String fileName = getFileName(message);
    String url;
    if(widget.isChat){
      url = await widget.database.uploadFileToChatStorage(File(message), widget.convTypeId, widget.sender.id, fileName);
      await widget.database.fileUrlToDatabase(widget.convTypeId, widget.sender.id, url, fileName);
    }else{
      url = await widget.database.uploadFileToGroupStorage(File(message), widget.convTypeId, widget.sender.id, fileName);
      await widget.database.fileUrlToDatabase(widget.convTypeId, widget.sender.id, url, fileName);
    }
    await widget.database.addMessage(url, widget.sender, false, false, time, widget.convTypeId, "image");
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
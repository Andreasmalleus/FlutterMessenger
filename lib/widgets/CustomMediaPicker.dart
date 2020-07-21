import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';


class CustomMediaPicker extends StatefulWidget{


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

  Widget isSelected(){
    if(_isSelected){
        return GestureDetector(
          onTap: () => print("tapped"),
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
                    return GestureDetector(
                      onTap: () => {
                        print(files[i].path + " selected"),
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
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                            child: Image.file(
                              File(files[i].path),
                              fit: BoxFit.cover,
                            )
                        )
                        :
                        Image.file(
                          File(files[i].path),
                          fit: BoxFit.cover,
                        )
                      ),
                    );
                  }),
                  isSelected()
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
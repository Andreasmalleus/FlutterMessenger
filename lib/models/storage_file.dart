import 'package:cloud_firestore/cloud_firestore.dart';

class StorageFile{
  final String userId;
  final String url;
  final String name;

  StorageFile({
    this.userId,
    this.url,
    this.name
  });

  factory StorageFile.fromFirestore(DocumentSnapshot data){
    print(data.toString() + "data");
    return StorageFile(
      userId: data["userId"]?? '',
      url: data["url"]?? '',
      name: data["name"]?? '',
    );
  }

  toJson(){
    return {
      "userId" : userId,
      "url" : url,
      "name" : name
    };
  }
}
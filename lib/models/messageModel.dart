import 'userModel.dart';

class Message{
  final String id;
  final String type;
  final User sender;
  final String time; //DateTime
  final String message;
  final bool isRead;
  final bool isLiked;

  Message({
    this.id,
    this.type,
    this.sender,
    this.time,
    this.message,
    this.isRead,
    this.isLiked
  });
}
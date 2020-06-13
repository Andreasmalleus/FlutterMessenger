import 'userModel.dart';

class Message{
  final User sender;
  final String time; //DateTime
  final String text;
  final bool isRead;
  final bool isLiked;

  Message({
    this.sender,
    this.time,
    this.text,
    this.isRead,
    this.isLiked
  });
}
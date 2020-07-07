class Group{
  String id;
  String name;
  String lastMessage;
  String lastMessageTime;
  String imageUrl;
  List<String> participants;

  Group({
    this.id,
    this.name,
    this.lastMessage,
    this.lastMessageTime,
    this.imageUrl,
    this.participants,
  });
}
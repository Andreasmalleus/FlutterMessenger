class Group{
  String id;
  String name;
  String lastMessage;
  String lastMessageTime;
  String imageUrl;
  List<String> participants;
  List<String> admins;

  Group({
    this.id,
    this.name,
    this.lastMessage,
    this.lastMessageTime,
    this.imageUrl,
    this.participants,
    this.admins
  });
}
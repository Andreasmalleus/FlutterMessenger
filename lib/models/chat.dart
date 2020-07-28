class Chat{
  String id;
  String lastMessage;
  String lastMessageTime;
  List<String> participants;

  Chat({
    this.id,
    this.lastMessage,
    this.lastMessageTime,
    this.participants,
  });

  factory Chat.fromFirebase(MapEntry<dynamic, dynamic> data){
    List<String> ids = List<String>();
    data.value["participants"].forEach((key, value) => {
      ids.add(key)
    });
      return Chat(
        id: data.key,
        lastMessage: data.value["lastMessage"],
        lastMessageTime: data.value["lastMessageTime"],
        participants: ids
    );

  }
}
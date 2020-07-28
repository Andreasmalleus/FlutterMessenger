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

  factory Group.fromFirebase(MapEntry<dynamic, dynamic> data){
    List<String> participants = List<String>();
    List<String> admins = List<String>();
    data.value["participants"].forEach((participantId, boolean){
      participants.add(participantId);
    });
    data.value["admins"].forEach((adminId, boolean){
      admins.add(adminId);
    });
    return Group(
      id: data.key,
      name: data.value["name"],
      lastMessage: data.value["lastMessage"],
      lastMessageTime: data.value["lastMessageTime"],
      imageUrl: data.value["imageUrl"],
      participants: participants,
      admins: admins
    );
  }

}
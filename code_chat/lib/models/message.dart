class Message {
  final int id;
  final int senderId;
  final int recipientId;
  final String content;
  final String createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}
class Message {
  final String text;
  final String senderId;
  final String receiverId;
  final String senderType;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.timestamp,
  });
}

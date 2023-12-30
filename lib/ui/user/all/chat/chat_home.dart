import 'package:cucifikasi_laundry/model/data/message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final bool isSenderAdmin;

  const AllChatPage({super.key, 
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.isSenderAdmin,
  });

  @override
  _AllChatPageState createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', isEqualTo: widget.senderId)
                  .where('receiverId', isEqualTo: widget.receiverId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshotSender) {
                if (!snapshotSender.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }

                List<Message> messagesSender = snapshotSender.data!.docs
                    .where((doc) => doc['timestamp'] != null)
                    .map((doc) => Message(
                          text: doc['text'],
                          senderId: doc['senderId'],
                          receiverId: doc['receiverId'],
                          senderType: doc['senderType'],
                          timestamp: doc['timestamp'].toDate(),
                        ))
                    .toList();

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('senderId', isEqualTo: widget.receiverId)
                      .where('receiverId', isEqualTo: widget.senderId)
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> snapshotReceiver) {
                    if (!snapshotReceiver.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    }

                    List<Message> messagesReceiver = snapshotReceiver.data!.docs
                        .map((doc) => Message(
                              text: doc['text'],
                              senderId: doc['senderId'],
                              receiverId: doc['receiverId'],
                              senderType: doc['senderType'],
                              timestamp: doc['timestamp'].toDate(),
                            ))
                        .toList();

                    List<Message> allMessages = [
                      ...messagesSender,
                      ...messagesReceiver
                    ];
                    allMessages
                        .sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: allMessages.length,
                      itemBuilder: (context, index) {
                        Message message = allMessages[index];

                        return _buildMessageItem(message);
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    bool isSender = message.senderId == widget.senderId;
    Color backgroundColor = isSender
        ? Theme.of(context).primaryColor.withOpacity(0.5)
        : Colors.grey.shade300;
    Color textColor = isSender ? Colors.black : Colors.black;
    Color timeColor = isSender
        ? const Color.fromARGB(255, 82, 82, 82)
        : const Color.fromARGB(255, 82, 82, 82);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isSender ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight:
                isSender ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
              textAlign: isSender ? TextAlign.end : TextAlign.start,
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute}',
              style: TextStyle(fontSize: 12, color: timeColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).hintColor),
            onPressed: () {
              _sendMessage(_messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    String senderType = widget.isSenderAdmin ? 'admin' : 'user';

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'senderType': senderType,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chat> {
  final List<Map<String, dynamic>> messages = [
    {
      "isMe": true,
      "message": "Placeholder text from User 1",
      "time": "12:00 PM",
    },
    {
      "isMe": false,
      "message": "Placeholder text from User 2",
      "time": "12:01 PM",
    },
    // ... more messages
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(messages[index]);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isMe = message['isMe'];
    final Alignment alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe ? CupertinoColors.activeBlue : CupertinoColors.lightBackgroundGray;
    final CrossAxisAlignment crossAxisAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  color: isMe ? CupertinoColors.white : CupertinoColors.black,
                ),
              ),
            ),
            Text(
              message['time'],
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 12,
              ),
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
            child: CupertinoTextField(
              placeholder: 'Enter message',
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(width: 8),
          CupertinoButton(
            child: Text('Send'),
            onPressed: () {
              // Handle send message
            },
          ),
        ],
      ),
    );
  }
}

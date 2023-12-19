import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tandem/utils/hexcolor.dart';
import 'package:tandem/utils/settings.dart';
import 'package:tandem/utils/websocketmanager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../objs/contact.dart';
import '../objs/messageobj.dart';
import '../utils/databasehelper.dart';

class Chat extends StatefulWidget {
  final WebSocketManager manager;
  final Contact contact;
  final String avatarUrl;

  Chat({Key? key, required this.manager,
    required this.contact, required this.avatarUrl}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chat> {
  final List<Map<String, dynamic>> messages = [
    {
      "isMe": false,
      "message": "Hey",
      "time": DateTime.now().subtract(Duration(minutes: 1)),
    },
    // Add previous messages here
  ];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String navigationBarColorHex = "26252A";
  final double opacity = 0.4;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocketManager
    final wsManager = WebSocketManager();
    wsManager.sendMessage("${Settings().getPrefix()} f tel:${widget.contact.number}\n");
    wsManager.sendMessage("\n");
    loadMessagesFromDatabase(widget.contact.number);
    widget.manager.messages.listen((message) {
      var pm = parseMessage(message);
      if (pm["isType2"]) {
        setState(() {
          messages.insert(0, {
            "isMe": false,
            "message": pm["message"],
            "time": DateTime.now().subtract(const Duration(seconds: 5)),
          });
        });
      } else {
        print(pm["message"]);
      }
    });
  }

  // Method to load messages from the database
  void loadMessagesFromDatabase(String contactNumber) async {
    DatabaseHelper db = DatabaseHelper();
    List<Message> dbMessages = await db.getMessages(contactNumber);
    setState(() {
      messages.addAll(dbMessages.map((message) => {
        "isMe": message.isSent,
        "message": message.text,
        "time": message.timestamp,
      }).toList());
    });
  }

  void sendMessage() {
    String textToSend = _textController.text;
    widget.manager.sendMessage(textToSend);
    Message newMessage = Message(
      text: textToSend,
      timestamp: DateTime.now().toIso8601String(),
      isSent: true,
      contactNumber: widget.contact.number, id: null,
    );
    DatabaseHelper db = DatabaseHelper();
    db.insertMessage(newMessage);
    widget.contact.lastMessage = newMessage;
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(widget.avatarUrl),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(widget.contact.contactName),
          ],
        ),
        backgroundColor: HexColor(navigationBarColorHex).withOpacity(opacity),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey, width: 0.0),
        ),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: CupertinoColors.white,
        ),
        padding: EdgeInsetsDirectional.only(
          start: 0,
          end: 0,
          top: 10,
          bottom: 10, // Increase bottom padding as needed
        ),
      ),

      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8),
                itemCount: messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(messages[index], index == messages.length - 1);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isLatest) {
    final bool isMe = message['isMe'];
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    final bubbleColor = isMe ? CupertinoColors.activeBlue : HexColor("26252A");
    final textColor = isMe ? CupertinoColors.white : CupertinoColors.white;

    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message['message'],
              style: TextStyle(color: textColor),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(message['time']),
              style: TextStyle(
                color: isMe ? CupertinoColors.secondarySystemBackground : CupertinoColors.systemGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    String formattedDate = DateFormat('h:mm a').format(timestamp);
    if (timestamp.day == DateTime.now().day) {
      return formattedDate;
    } else {
      return '${DateFormat('MMMMd').format(timestamp)}, $formattedDate';
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _textController,
              placeholder: 'iMessage',
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(CupertinoIcons.arrow_up_circle_fill, color: CupertinoColors.activeBlue, size: MediaQuery.of(context).size.height * 0.045,),
            onPressed: () {
              _handleSubmitted(_textController.text);
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = {
      "isMe": true,
      "message": text,
      "time": DateTime.now(),
    };

    setState(() {
      messages.insert(0, newMessage);
      sendMessage();
    });

    _textController.clear();

    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> parseMessage(String input) {
    if (input.contains("drceo1909")) {
      if (input.contains("tel:+")) {
        var telIndex = input.indexOf("tel:+") + 5;
        var endIndex = input.indexOf("]", telIndex);
        var phoneNumber = input.substring(telIndex, endIndex);

        var messageStart = input.indexOf("{", endIndex) + 1;
        var messageEnd = input.indexOf("}", messageStart);
        var message = input.substring(messageStart, messageEnd);

        return {
          'isType2': true,
          'phoneNumber': phoneNumber,
          'message': message,
        };
      } else {
        var messageStart = input.indexOf("{") + 1;
        var messageEnd = input.indexOf("}", messageStart);
        var message = input.substring(messageStart, messageEnd);

        return {
          'isType2': false,
          'message': message,
        };
      }
    } else {
      throw FormatException('String does not contain drceo1909');
    }
  }



}

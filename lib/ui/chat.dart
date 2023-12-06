import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tandem/utils/hexcolor.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  final WebSocketChannel channel;
  final String contactName;
  final String avatarUrl;

  Chat({Key? key, required this.channel, required this.contactName, required this.avatarUrl}) : super(key: key);

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
    widget.channel.sink.add("f tel:+12819069013");
    widget.channel.stream.listen((message) {
      messages.add({
        "isMe": false,
        "message": message.toString(),
        "time": DateTime.now().subtract(const Duration(seconds: 5)),
      });
    });
  }

  void sendMessage() {
    widget.channel.sink.add(_textController.text);
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
            Text(widget.contactName),
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
        padding: const EdgeInsetsDirectional.only(
          start: 0,
          end: 0,
          top: 10,
          bottom: 10,
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

}

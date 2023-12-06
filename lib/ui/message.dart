import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat.dart';

class Message extends StatefulWidget {
  final WebSocketChannel channel;

  Message(this.channel, {super.key});

  @override
  _MessagesHomeScreenState createState() => _MessagesHomeScreenState();
}

class _MessagesHomeScreenState extends State<Message> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.channel.stream.listen((message) {
      // Handle the message received from the server
      // Navigate to next page or show an error based on the message
    });
  }

  void _navigateToChatScreen(Map<String, dynamic> contact) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => Chat(
        channel: widget.channel,
        contactName: contact['name'],
        avatarUrl: contact['avatarUrl'],
      ),
    ));
  }

  final List<Map<String, dynamic>> messages = List.generate(
    20,
        (index) => {
      "name": "Contact ${index + 1}",
      "message": "Last message snippet here...",
      "time": "10:00 PM",
      "avatarUrl": "https://avatars.githubusercontent.com/u/29443930?v=4",
    },
  );

  List<Map<String, dynamic>> get filteredMessages => messages
      .where((message) =>
  message["name"].toLowerCase().contains(searchQuery.toLowerCase()) ||
      message["message"].toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Messages'),
              backgroundColor: CupertinoColors.black,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Edit'),
                onPressed: () {
                  // Handle edit action
                },
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.square_pencil),
                onPressed: () {
                  // Navigate to compose new message screen
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  onChanged: (String value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  var message = filteredMessages[index];
                  return _buildCustomListTile(message);
                },
                childCount: filteredMessages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomListTile(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () {
        _navigateToChatScreen(message);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: <Widget>[
            ClipOval(
              child: Image.network(
                message["avatarUrl"],
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message["name"],
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    message["message"],
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
            ),
            Text(
              message["time"],
              style: TextStyle(color: CupertinoColors.systemGrey2),
            ),
          ],
        ),
      ),
    );
  }
}

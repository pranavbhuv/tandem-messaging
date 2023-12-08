import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:tandem/websocketmanager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat.dart';

class Message extends StatefulWidget {
  final WebSocketManager channel;

  Message(this.channel, {super.key});

  @override
  _MessagesHomeScreenState createState() => _MessagesHomeScreenState();
}

class _MessagesHomeScreenState extends State<Message> {
  String searchQuery = '';

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final wsManager = WebSocketManager();

    wsManager.messages.listen((message) {
      // Handle the message received from the server
      // Navigate to next page or show an error based on the message

      // Example:
      // if (message.contains('Success')) {
      //   Navigator.of(context).push(...); // Navigate to the next page
      // } else {
      //   // Show an error message
      // }
    });
  }

  void _navigateToChatScreen(Map<String, dynamic> contact) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => Chat(
        manager: widget.channel,
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
                onPressed: () => _showModalScreen(context),
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

  void _showModalScreen(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(400)),
          height: MediaQuery.of(context).size.height * 0.4,
          child: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: Text(''),
              middle: Text('New Message'),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      placeholder: 'To:',
                      prefix: Padding(
                        padding: const EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                        child: Icon(
                          CupertinoIcons.person_add,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  _buildMessageInput(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _textController,
                      placeholder: 'iMessage',
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Align(
            alignment: Alignment.topCenter,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.arrow_up_circle_fill,
                color: CupertinoColors.activeBlue,
                size: MediaQuery.of(context).size.height * 0.045,
              ),
              onPressed: () {
                // TODO implement the send message functionality
              },
            ),
          ),
        ],
      ),
    );
  }

}

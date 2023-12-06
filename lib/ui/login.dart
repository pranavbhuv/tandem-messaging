import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tandem/ui/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _2FA = TextEditingController();

  var channel;

  @override
  void initState() {
    super.initState();
  }

  void setupWS(String ws) {
    final wsUrl = Uri.parse(ws);
    channel = WebSocketChannel.connect(wsUrl);

    // final streamController = StreamController.broadcast();
    // streamController.addStream(channel.stream);

    channel.stream.listen((message) {
      channel.sink.add(_usernameController.text);
      channel.sink.add(_passwordController.text);
    });
  }

  void sendPostRequest() async {
    final ipAddress = '34.173.89.189';
    final port = 8080;
    final endpoint = '/initSession';
    final url = Uri.http('$ipAddress:$port', endpoint);

    final Map<String, dynamic> requestData = {
      'email': '_usernameController',
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData), // Encode data as JSON
    );

    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      setupWS(response.body);
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response data: ${response.body}');
    }
  }

  void _login() {
    // TODO: Replace this with actual login logic and condition
    bool loginConditionMet = true;
    sendPostRequest();
    // widget.channel.sink.add(_usernameController.text);
    // widget.channel.sink.add(_passwordController.text);
    // if (loginConditionMet) {
    //   _show2FADialog();
    // }
  }

  void verify() {
    channel.sink.add(_2FA.text);
    Navigator.of(context).push(
        CupertinoPageRoute(builder: (context) => Message(channel)));
  }

  void _show2FADialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Enter your 2FA code'),
          content: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.025,
              ),
              CupertinoTextField(
                controller: _2FA,
                placeholder: '',
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Verify'),
              onPressed: () {
                // TODO: Implement 2FA verification logic
                Navigator.of(context).pop();
                verify();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Login'),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username',
                ),
                SizedBox(height: 10),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  child: Text('Login'),
                  color: CupertinoColors.activeBlue,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ));
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tandem/ui/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../websocketmanager.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _2FA = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void sendPostRequest() async {
    final ipAddress = '35.232.9.168';
    final port = 8080;
    final endpoint = '/initSession';
    final url = Uri.http('$ipAddress:$port', endpoint);

    final Map<String, dynamic> requestData = {
      'email': _usernameController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData), // Encode data as JSON
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
        await setupWS(JsonDecoder().convert(response.body)['address']);
        _login(); // Call login after WebSocket setup
      } else {
        print('Request failed with status code: ${response.statusCode}');
        print('Response data: ${response.body}');
      }
    } catch (e) {
      print('Request failed with error: $e' + e.toString());
    }
  }

  Future<void> setupWS(String ws) async {
    final wsManager = WebSocketManager();
    wsManager.connect(ws);
  }

  void _login() {
    final wsManager = WebSocketManager();
    if (wsManager.isConnected) {  // Check if the WebSocket is connected
      wsManager.messages.listen((message) {
        if (message.contains('Username:')) {
          wsManager.sendMessage(_usernameController.text);
        } else if (message.contains('Password:')) {
          wsManager.sendMessage(_passwordController.text);
        } else if (message.contains('Enter 2FA code:')) {
          _show2FADialog();
        } else if (message.contains('Waiting for incoming messages...')) {
          verify();
        }
      });
    } else {
      print('WebSocket channel is not connected.');
    }
  }

  Future<void> verify() async {
    final wsManager = WebSocketManager();
    if (wsManager.isConnected) {
      wsManager.sendMessage(_2FA.text);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Message(wsManager)));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      print("Login Status: ${prefs.getBool('loggedIn')}");
      await prefs.setString('email', _usernameController.text);
    } else {
      print('WebSocket channel is not connected.');
    }
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
                  onPressed: sendPostRequest,
                ),
              ],
            ),
          ),
        ));
  }
}


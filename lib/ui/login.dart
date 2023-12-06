import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tandem/ui/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Login extends StatefulWidget {
  final WebSocketChannel channel;

  // Login({super.key});
  Login(this.channel, {super.key});

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
    widget.channel.stream.listen((message) {
      // Handle the message received from the server
      // Navigate to next page or show an error based on the message
    });
  }

  void _login() {
    // TODO: Replace this with actual login logic and condition
    bool loginConditionMet = true;
    widget.channel.sink.add(_usernameController.text);
    widget.channel.sink.add(_passwordController.text);
    if (loginConditionMet) {
      _show2FADialog();
    }
  }

  void verify() {
    widget.channel.sink.add(_2FA.text);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => Message(widget.channel)));
  }

  void _show2FADialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Enter your 2FA code'),
          content: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.025,),
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
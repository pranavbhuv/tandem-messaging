import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:tandem/ui/login.dart';
import 'package:tandem/ui/message.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'firebase_options.dart';

void sendPostRequest() async {
  final ipAddress = '3417389189';
  final port = 3000;
  final endpoint = '/initsession';
  final url = Uri.http('$ipAddress:$port', endpoint);

  final Map<String, dynamic> requestData = {
    // Add any data you want to send in the request body here
    // For example:
    // 'key1': 'value1',
    // 'key2': 'value2',
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
  } else {
    print('Request failed with status code: ${response.statusCode}');
    print('Response data: ${response.body}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  sendPostRequest();

  final wsUrl = Uri.parse('ws://localhost:1234');
  var channel = WebSocketChannel.connect(wsUrl);

  // final streamController = StreamController.broadcast();
  // streamController.addStream(channel.stream);

  channel.stream.listen((message) {
    channel.sink.add('cd userId');
  });

  runApp(MyApp(channel));
}

class MyApp extends StatelessWidget {

  final WebSocketChannel channel;

  const MyApp(this.channel, {super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Flutter Demo',
        home: Login(channel)
    );
  }
}



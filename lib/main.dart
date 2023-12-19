import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tandem/ui/login.dart';
import 'package:tandem/ui/message.dart';
import 'package:tandem/utils/settings.dart';
import 'package:tandem/utils/websocketmanager.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await checkFirstLaunch();

  runApp(MyApp());
}

Future<void> checkFirstLaunch() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstLaunch = prefs.getBool('firstTime') ?? true;
  if (firstLaunch) {
    await prefs.setBool('loggedIn', false);
    await prefs.setBool('firstTime', false);
  }
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      home: FutureBuilder<bool>(
        future: getLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data == false) {
              return Message(new WebSocketManager());
            } else {
              return FutureBuilder<WebSocketManager>(
                future: createWebSocket(),
                builder: (context, wsSnapshot) {
                  if (wsSnapshot.connectionState == ConnectionState.done) {
                    if (wsSnapshot.hasData) {
                      return Message(wsSnapshot.data!);
                    } else {
                      return Text('Error: Unable to create WebSocket connection.');
                    }
                  } else {
                    return Center(child: CupertinoActivityIndicator());
                  }
                },
              );
            }
          } else {
            // Show loading indicator while waiting for login status
            return Center(child: CupertinoActivityIndicator());
          }
        },
      ),
    );
  }

  Future<WebSocketManager> createWebSocket() async {
    try {
      final ipAddress = Settings().getIP();
      final port = 8080;
      final endpoint = '/initSession';
      final url = Uri.http('$ipAddress:$port', endpoint);
      final Map<String, dynamic> requestData = {
        'email': await getEmail(),
      };
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
        final wsManager = WebSocketManager();
        wsManager.connect(JsonDecoder().convert(response.body)['address']);
        return wsManager;
      } else {
        print('Request failed with status code: ${response.statusCode}');
        print('Response data: ${response.body}');
        throw Exception('Failed to create WebSocket: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Request failed with error: $e');
      throw Exception('Failed to create WebSocket: $e');
    }
  }

  Future<bool> getLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getBool('loggedIn'));
    return prefs.getBool('loggedIn') ?? false;
  }

  Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('email'));
    return prefs.getString('email') ?? "example@error.com";
  }
}



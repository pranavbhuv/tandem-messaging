import 'package:firebase_core/firebase_core.dart';
import 'package:tandem/ui/login.dart';
import 'package:tandem/ui/message.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final wsUrl = Uri.parse('ws://localhost:1234');
  var channel = WebSocketChannel.connect(wsUrl);

  channel.stream.listen((message) {
    channel.sink.add('received!');
    channel.sink.close(status.goingAway);
  });

  runApp(MyApp(channel));
  // runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoApp(
//         title: 'Flutter Demo',
//         home: Login()
//     );
//   }
// }

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



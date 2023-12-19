import 'messageobj.dart';

class Contact {
  String contactName = "Lorem Ipsum";
  String number;
  Message? lastMessage = Message(
    text: "ERR",
    timestamp: DateTime.now().toIso8601String(),
    isSent: true,
    contactNumber: "+12819069014",
    id: null,
  );

  Contact({
    required this.number,
    required this.contactName,
    this.lastMessage,
  });

  // Method to update the last message
  void updateLastMessage(Message message) {
    lastMessage = message;
  }
}

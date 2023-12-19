class Message {
  final int? id;
  final String text;
  final String timestamp;
  final bool isSent;
  final String contactNumber;

  Message({this.id, required this.text, required this.timestamp, required this.isSent, required this.contactNumber});

  Map<String, dynamic> toMap() {
    var map = {
      'text': text,
      'timestamp': timestamp,
      'isSent': isSent ? 1 : 0,
      'contactNumber': contactNumber,
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,  // Explicitly cast to 'int?'
      text: map['text'] as String,  // Explicitly cast to 'String'
      timestamp: map['timestamp'] as String,  // Explicitly cast to 'String'
      isSent: map['isSent'] == 1,
      contactNumber: map['contactNumber'],
    );
  }
}

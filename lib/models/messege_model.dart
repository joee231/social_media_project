class MessegeModel {
  late String senderId;
  late String receiverId;
  late String text;
  late String dateTime;
  String? messageImage;

  late String messageId;

  MessegeModel({
    required this.senderId,
    required this.receiverId,
    required this.messageId,
    this.text = '',
    this.dateTime = '',
    this.messageImage, // Remove the default empty string
  });

  MessegeModel.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'] ?? '';
    receiverId = json['receiverId'] ?? '';
    messageId = json['messageId'] ?? '';
    text = json['text'] ?? '';
    dateTime = json['dateTime'] ?? '';
    messageImage = json['messageImage']; // Remove default empty string
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'dateTime': dateTime,
      'messageImage': messageImage,
      'messageId': messageId,
    };
  }
}
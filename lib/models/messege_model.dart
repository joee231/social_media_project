class MessegeModel {
  late String senderId;
  late String receiverId;
  late String text;
  late String dateTime;
  String? messageImage;

  MessegeModel({
    required this.senderId,
    required this.receiverId,
    this.text = '',
    this.dateTime = '',
    this.messageImage, // Remove the default empty string
  });

  MessegeModel.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'] ?? '';
    receiverId = json['receiverId'] ?? '';
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
    };
  }
}
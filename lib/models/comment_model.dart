class CommentModel {
  String? uId;
  String? name;
  String? image;
  late String comment;
  String? dateTime;

  late String commentId;

  CommentModel({
    this.uId,
    this.name,
    this.image,
    required this.comment,
    this.dateTime,
    required this.commentId,
  });

  CommentModel.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    name = json['name'];
    image = json['image'];
    comment = json['comment'];
    dateTime = json['dateTime'];
    commentId = json['commentId'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'name': name,
      'image': image,
      'comment': comment,
      'dateTime': dateTime,
      'commentId': commentId,
    };
  }
}

class NewsModel {
  final int? id;
  final String? title;
  final String? content;
  final String? mediaUrl;
  final int? typeMedia;
  final String? createTime;
  final String? createBy;

  NewsModel({
    this.id,
    this.title,
    this.content,
    this.mediaUrl,
    this.typeMedia,
    this.createTime,
    this.createBy,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      typeMedia: json['typeMedia'],
    );
  }

  @override
  String toString() {
    return 'NewsModel{id: $id, title: $title, content: $content, mediaUrl: $mediaUrl, typeMedia: $typeMedia, createTime: $createTime, createBy: $createBy}';
  }
}

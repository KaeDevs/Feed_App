class Post {
  Post({
    required this.id,
    required this.createdAt,
    required this.mediaThumbUrl,
    required this.mediaMobileUrl,
    required this.mediaRawUrl,
    required this.likeCount,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final rawLikeCount = json['like_count'];
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      mediaThumbUrl: json['media_thumb_url'],
      mediaMobileUrl: json['media_mobile_url'],
      mediaRawUrl: json['media_raw_url'],
      likeCount: rawLikeCount is int
          ? rawLikeCount
          : (rawLikeCount is num ? rawLikeCount.toInt() : 0),
      isLiked: _toBool(
        json['is_liked'] ?? json['isLiked'] ?? json['liked_by_user'],
      ),
    );
  }

  final String id;
  final DateTime createdAt;
  final String mediaThumbUrl;
  final String mediaMobileUrl;
  final String mediaRawUrl;
  final int likeCount;
  final bool isLiked;

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

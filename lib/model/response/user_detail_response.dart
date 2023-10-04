class UserDetailResponse {
  final List<UserDetailData> items;
  final bool hasMore;

  UserDetailResponse({
    required this.items,
    required this.hasMore,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      items: List<UserDetailData>.from(
        json['items'].map(
          (userInfo) => UserDetailData.fromJson(userInfo),
        ),
      ),
      hasMore: json['has_more'],
    );
  }
}

class UserDetailData {
  final String reputationType;
  final int reputationChange;
  final DateTime creationDate;
  final int postId;

  UserDetailData({
    required this.reputationType,
    required this.reputationChange,
    required this.creationDate,
    required this.postId,
  });

  factory UserDetailData.fromJson(Map<String, dynamic> json) {
    return UserDetailData(
      reputationType: json['reputation_history_type'],
      reputationChange: json['reputation_change'],
      creationDate:
          DateTime.fromMillisecondsSinceEpoch(json["creation_date"] * 1000),
      postId: json['post_id'],
    );
  }
}

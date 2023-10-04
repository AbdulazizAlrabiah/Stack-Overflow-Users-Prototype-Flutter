class UsersResponse {
  final List<UserData> items;
  final bool hasMore;

  UsersResponse({
    required this.items,
    required this.hasMore,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      items: List<UserData>.from(
        json['items'].map(
          (userInfo) => UserData.fromJson(userInfo),
        ),
      ),
      hasMore: json['has_more'],
    );
  }
}

class UserData {
  final int accountId;
  final int userId;
  final String name;
  final String profileImageURL;
  final int reputation;
  final String location;
  final DateTime creationDate;
  bool isBookmarked;

  UserData({
    required this.accountId,
    required this.userId,
    required this.name,
    required this.profileImageURL,
    required this.reputation,
    required this.location,
    required this.creationDate,
    required this.isBookmarked,
  });

  factory UserData.fromJson(
    Map<String, dynamic> json, {
    bool fromDB = false,
  }) {
    return UserData(
      accountId: fromDB ? json["id"] : json["account_id"],
      userId: json["user_id"],
      name: json["display_name"],
      profileImageURL: json["profile_image"],
      reputation: json["reputation"],
      location: json["location"] ?? "No location",
      creationDate:
          DateTime.fromMillisecondsSinceEpoch(json["creation_date"] * 1000),
      isBookmarked: fromDB ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": accountId,
      "user_id": userId,
      "display_name": name,
      "profile_image": profileImageURL,
      "reputation": reputation,
      "location": location,
      "creation_date": creationDate.millisecondsSinceEpoch / 1000,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

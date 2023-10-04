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
  final int id;
  final String name;
  final String profileImageURL;
  final num reputation;
  final String location;
  final DateTime creationDate;

  UserData({
    required this.id,
    required this.name,
    required this.profileImageURL,
    required this.reputation,
    required this.location,
    required this.creationDate,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['user_id'],
      name: json['display_name'],
      profileImageURL: json['profile_image'],
      reputation: json['reputation'],
      location: json['location'] ?? "No location",
      creationDate:
          DateTime.fromMillisecondsSinceEpoch(json['creation_date'] * 1000),
    );
  }
}

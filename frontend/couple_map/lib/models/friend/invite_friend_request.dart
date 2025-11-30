class InviteFriendRequest {
  final String friendCode;

  InviteFriendRequest({
    required this.friendCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendCode': friendCode,
    };
  }
}

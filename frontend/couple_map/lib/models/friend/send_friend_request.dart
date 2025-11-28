class SendFriendRequest {
  final String friendCode;

  SendFriendRequest({
    required this.friendCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendCode': friendCode,
    };
  }
}

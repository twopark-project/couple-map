enum NotificationType { invite, mapInvite, memory, join, other }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String message;
  final String boldPart;
  final String? highlightPart;
  final String timeAgo;
  final bool hasAction;
  final int? friendshipId;
  final int? mapMemberId;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.boldPart,
    this.highlightPart,
    required this.timeAgo,
    this.hasAction = false,
    this.friendshipId,
    this.mapMemberId,
  });

  factory NotificationModel.fromFriendRequest(Map<String, dynamic> json) {
    final rawId = json['friendshipId'];
    final friendshipId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final nickname = json['nickname'] as String? ?? '';
    return NotificationModel(
      id: 'friend_${friendshipId ?? ''}',
      type: NotificationType.invite,
      message: '$nickname님이 친구 요청을 보냈어요',
      boldPart: nickname,
      timeAgo: '',
      hasAction: true,
      friendshipId: friendshipId,
    );
  }

  factory NotificationModel.fromMapInvitation(Map<String, dynamic> json) {
    final rawId = json['mapMemberId'];
    final mapMemberId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final inviterName = json['inviterName'] as String? ?? '';
    final mapName = json['mapName'] as String? ?? '';
    return NotificationModel(
      id: 'map_${mapMemberId ?? ''}',
      type: NotificationType.mapInvite,
      message: '$inviterName님이 $mapName에 초대했어요',
      boldPart: inviterName,
      highlightPart: mapName,
      timeAgo: '',
      hasAction: true,
      mapMemberId: mapMemberId,
    );
  }
}

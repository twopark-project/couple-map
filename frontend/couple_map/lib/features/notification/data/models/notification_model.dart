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

  static String _calcTimeAgo(String? createdAtStr) {
    if (createdAtStr == null || createdAtStr.isEmpty) return '';
    try {
      final createdAt = DateTime.parse(createdAtStr);
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      if (diff.inSeconds < 60) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      if (diff.inDays == 1) return '어제';
      if (diff.inDays < 7) return '${diff.inDays}일 전';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
      return '${(diff.inDays / 30).floor()}달 전';
    } catch (_) {
      return '';
    }
  }

  factory NotificationModel.fromFriendRequest(Map<String, dynamic> json) {
    final rawId = json['friendshipId'];
    final friendshipId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final nickname = json['nickname'] as String? ?? '';
    return NotificationModel(
      id: 'friend_${friendshipId ?? ''}',
      type: NotificationType.invite,
      message: '$nickname님이 친구 요청을 보냈어요',
      boldPart: nickname,
      timeAgo: _calcTimeAgo(json['createdAt']?.toString()),
      hasAction: true,
      friendshipId: friendshipId,
    );
  }

  factory NotificationModel.fromMapInvitation(Map<String, dynamic> json) {
    final rawId = json['mapMemberId'];
    final mapMemberId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final inviterName = json['inviterNickname'] as String? ?? '';
    final mapName = json['mapName'] as String? ?? '';
    return NotificationModel(
      id: 'map_${mapMemberId ?? ''}',
      type: NotificationType.mapInvite,
      message: '$inviterName님이 \'$mapName\'에 초대했어요',
      boldPart: inviterName,
      highlightPart: '\'$mapName\'',
      timeAgo: _calcTimeAgo(json['createdAt']?.toString()),
      hasAction: true,
      mapMemberId: mapMemberId,
    );
  }
}

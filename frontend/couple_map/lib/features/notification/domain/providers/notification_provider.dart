import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((_) => NotificationRepository());

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/friend_repository.dart';

final friendRepositoryProvider = Provider<FriendRepository>((_) => FriendRepository());

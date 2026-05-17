import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mypage_repository.dart';

final mypageRepositoryProvider = Provider<MypageRepository>((_) => MypageRepository());

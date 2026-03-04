import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((_) => MapRepository());

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/memory_repository.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((_) => MemoryRepository());

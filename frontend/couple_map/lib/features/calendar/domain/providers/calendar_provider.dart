import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((_) => CalendarRepository());

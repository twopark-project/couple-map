import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../memory/data/models/memory_model.dart';
import '../../../memory/data/repositories/memory_repository.dart';
import '../../../memory/presentation/screens/memory_detail_screen.dart';

// ─── 내부 데이터 클래스 ──────────────────────────────────────────────────────
class _MemoryEntry {
  final int mapId;
  final MemorySummary summary;

  _MemoryEntry({required this.mapId, required this.summary});
}

// ─── 캘린더 스크린 ──────────────────────────────────────────────────────────
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final HomeRepository _homeRepo = HomeRepository();
  final MemoryRepository _memoryRepo = MemoryRepository();
  final AuthRepository _authRepo = AuthRepository();

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();

  // 날짜 키 → 추억 리스트
  Map<String, List<_MemoryEntry>> _memoryMap = {};
  bool _isLoading = true;

  static const _emojis = [
    '❤️', '🌸', '🎬', '☕', '🏔️', '🍜', '🍰', '🎵', '📸', '✨', '🌊', '🌙',
  ];
  static const _bgColors = [
    Color(0xFFFFE4E4), Color(0xFFE4F0FF), Color(0xFFE4FFE4),
    Color(0xFFFFEDD5), Color(0xFFF0E4FF), Color(0xFFE4FFF0),
  ];

  String _emoji(int id) => _emojis[id.abs() % _emojis.length];
  Color _bgColor(int id) => _bgColors[id.abs() % _bgColors.length];

  @override
  void initState() {
    super.initState();
    _loadAllMemories();
  }

  Future<String?> _getToken() async {
    final auth = ref.read(authProvider);
    if (auth is AuthSuccess) return auth.token.accessToken;
    return await _authRepo.getAccessToken();
  }

  Future<void> _loadAllMemories() async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken();
      if (token == null) return;

      final maps = await _homeRepo.getMapList(token);

      // 모든 지도의 추억을 병렬로 로드
      final futures = maps.map((m) async {
        try {
          final memories = await _memoryRepo.getMemoryList(token, m.mapId);
          return memories.map((s) => _MemoryEntry(mapId: m.mapId, summary: s));
        } catch (_) {
          return <_MemoryEntry>[];
        }
      });

      final results = await Future.wait(futures);
      final newMap = <String, List<_MemoryEntry>>{};

      for (final entries in results) {
        for (final entry in entries) {
          if (entry.summary.memoryDate == null) continue;
          final key = _dateKey(entry.summary.memoryDate!);
          newMap.putIfAbsent(key, () => []).add(entry);
        }
      }

      if (mounted) {
        setState(() {
          _memoryMap = newMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<_MemoryEntry> get _selectedEntries =>
      _memoryMap[_dateKey(_selectedDate)] ?? [];

  int get _monthMemoryCount {
    int count = 0;
    _memoryMap.forEach((key, value) {
      final parts = key.split('-');
      if (parts.length >= 2 &&
          parts[0] == _currentMonth.year.toString() &&
          parts[1] == _currentMonth.month.toString().padLeft(2, '0')) {
        count += value.length;
      }
    });
    return count;
  }

  bool _hasMemory(DateTime date) =>
      (_memoryMap[_dateKey(date)] ?? []).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8E8E)),
              )
            : Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFFF8E8E),
                      onRefresh: _loadAllMemories,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildMonthHeader(),
                              const SizedBox(height: 16),
                              _buildCalendarCard(),
                              const SizedBox(height: 24),
                              _buildMemorySection(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── 앱바 ──
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Align(
        alignment: Alignment(0, 1.0),
        child: Text(
          '캘린더',
          style: TextStyle(
            fontFamily: 'NotoSerifKR',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  // ── 월 헤더 ──
  Widget _buildMonthHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                );
                _selectedDate =
                    DateTime(_currentMonth.year, _currentMonth.month, 1);
              }),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const Text(
                  '❮',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${_currentMonth.year}년 ${_currentMonth.month}월',
              style: const TextStyle(
                fontFamily: 'NotoSerifKR',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(() {
                _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                );
                _selectedDate =
                    DateTime(_currentMonth.year, _currentMonth.month, 1);
              }),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const Text(
                  '❯',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '이번 달 추억 $_monthMemoryCount개',
          style: const TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  // ── 캘린더 카드 ──
  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDayHeaders(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildDayHeaders() {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: days.map((day) {
        final isRed = day == '일';
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isRed
                    ? const Color(0xFFFF8E8E)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun
    final totalDays = lastDay.day;

    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= totalDays; day++) {
      cells.add(
        _buildDayCell(DateTime(_currentMonth.year, _currentMonth.month, day)),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells =
          cells.sublist(i, (i + 7).clamp(0, cells.length)).toList();
      while (rowCells.length < 7) { rowCells.add(const SizedBox()); }
      rows.add(Row(
          children: rowCells.map((c) => Expanded(child: c)).toList()));
      if (i + 7 < cells.length) rows.add(const SizedBox(height: 4));
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected = _selectedDate.day == date.day &&
        _selectedDate.month == date.month &&
        _selectedDate.year == date.year;
    final hasMemory = _hasMemory(date);
    final isToday = DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;
    final isSunday = date.weekday == DateTime.sunday;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF8E8E)
                : (isToday ? const Color(0xFFFFE4E4) : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'NotoSansKR',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isSunday
                          ? const Color(0xFFFF8E8E)
                          : const Color(0xFF2C2C2C)),
                ),
              ),
              if (hasMemory && !isSelected)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8E8E),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 추억 섹션 ──
  bool get _isSelectedToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Widget _buildMemorySection() {
    final entries = _selectedEntries;
    final month = _selectedDate.month;
    final day = _selectedDate.day;

    final count = entries.length;
    final title = _isSelectedToday
        ? (count > 0 ? '오늘의 추억 ($count개)' : '오늘의 추억 ($month월 $day일)')
        : (count > 0 ? '$month월 $day일의 추억 ($count개)' : '$month월 $day일의 추억');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'NotoSansKR',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          _buildEmptyMemory()
        else
          ...entries.map((e) => _buildMemoryTile(e)),
      ],
    );
  }

  Widget _buildEmptyMemory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text('📝', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _isSelectedToday ? '오늘 추억이 없어요' : '이날 추억이 없어요',
              style: const TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '새로운 추억을 기록해보세요!',
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryTile(_MemoryEntry entry) {
    final s = entry.summary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemoryDetailScreen(
                mapId: entry.mapId,
                memoryId: s.memoryId,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 이모지 or 썸네일
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: s.thumbnailUrl != null
                        ? Colors.transparent
                        : _bgColor(s.memoryId),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: s.thumbnailUrl != null
                      ? Image.network(
                          s.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              _emoji(s.memoryId),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _emoji(s.memoryId),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.title,
                        style: const TextStyle(
                          fontFamily: 'NotoSansKR',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.placeName,
                        style: const TextStyle(
                          fontFamily: 'NotoSansKR',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF999999),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

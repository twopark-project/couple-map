import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../memory/data/models/memory_model.dart';
import '../../../memory/data/repositories/memory_repository.dart';
import '../../../memory/presentation/screens/memory_detail_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final int mapId;

  const CalendarScreen({super.key, required this.mapId});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final MemoryRepository _repo = MemoryRepository();
  List<MemorySummary> _memories = [];
  bool _isLoading = true;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthSuccess) return;
    try {
      final list = await _repo.getMemoryList(auth.token.accessToken, widget.mapId);
      if (mounted) setState(() { _memories = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MemorySummary> _memoriesForDay(DateTime day) {
    return _memories.where((m) {
      if (m.memoryDate == null) return false;
      return m.memoryDate!.year == day.year &&
          m.memoryDate!.month == day.month &&
          m.memoryDate!.day == day.day;
    }).toList();
  }

  List<MemorySummary> get _selectedMemories =>
      _selectedDay != null ? _memoriesForDay(_selectedDay!) : [];

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '캘린더',
          style: TextStyle(
              color: Color(0xFF191919),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendarHeader(),
                _buildCalendarGrid(),
                if (_selectedDay != null) ...[
                  const Divider(height: 1),
                  Expanded(child: _buildSelectedDayList()),
                ],
              ],
            ),
    );
  }

  Widget _buildCalendarHeader() {
    final months = ['1월', '2월', '3월', '4월', '5월', '6월',
        '7월', '8월', '9월', '10월', '11월', '12월'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left)),
          Text(
            '${_focusedMonth.year}년 ${months[_focusedMonth.month - 1]}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) days.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600])),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 1),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox();
              final hasMemory = _memoriesForDay(day).isNotEmpty;
              final isSelected = _selectedDay != null &&
                  _selectedDay!.year == day.year &&
                  _selectedDay!.month == day.month &&
                  _selectedDay!.day == day.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF7A7A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF191919),
                        ),
                      ),
                      if (hasMemory)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFFF7A7A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayList() {
    if (_selectedMemories.isEmpty) {
      return const Center(
        child: Text('이 날의 추억이 없어요',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedMemories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final m = _selectedMemories[index];
        return ListTile(
          tileColor: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: m.thumbnailUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(m.thumbnailUrl!,
                      width: 48, height: 48, fit: BoxFit.cover),
                )
              : Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.photo, color: Color(0xFFFF7A7A)),
                ),
          title: Text(m.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(m.placeName,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemoryDetailScreen(
                  mapId: widget.mapId, memoryId: m.memoryId),
            ),
          ),
        );
      },
    );
  }
}

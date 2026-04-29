import 'package:eschool/cubits/auth/authCubit.dart';
import 'package:eschool/cubits/student/subjectAttendanceCubit.dart';
import 'package:eschool/data/models/student/subjectAttendanceModel.dart';
import 'package:eschool/ui/widgets/academic/subjectAttendanceCard.dart';
import 'package:eschool/ui/widgets/system/changeCalendarMonthButton.dart';
import 'package:eschool/ui/widgets/system/customBackButton.dart';
import 'package:eschool/ui/widgets/system/errorContainer.dart';
import 'package:eschool/ui/widgets/system/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/system/shimmerLoaders/shimmerLoadingContainer.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class SubjectAttendanceContainer extends StatefulWidget {
  final int? childId;
  final DateTime? fixedDate;

  const SubjectAttendanceContainer({
    Key? key,
    this.childId,
    this.fixedDate,
  }) : super(key: key);

  @override
  State<SubjectAttendanceContainer> createState() =>
      _SubjectAttendanceContainerState();
}

class _SubjectAttendanceContainerState
    extends State<SubjectAttendanceContainer> with TickerProviderStateMixin {
  late DateTime selectedDate;
  final DateFormat dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id');
  late AnimationController _animationController;

  // Brand colors
  static const Color _primaryColor = Color(0xFFE53935);
  static const Color _lightColor = Color(0xFFFFEBEE);
  static const Color _surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.fixedDate ?? DateTime.now();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(Duration.zero, _fetchSubjectAttendance);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchSubjectAttendance() {
    context.read<SubjectAttendanceCubit>().fetchSubjectAttendance(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.childId ?? 0,
          date: selectedDate,
        );
  }

  void _stepDate(int days) {
    setState(() {
      final next = selectedDate.add(Duration(days: days));
      if (days > 0 && next.isAfter(DateTime.now())) return;
      selectedDate = next;
      _fetchSubjectAttendance();
    });
    _animationController.forward(from: 0.0);
  }

  String _getDayInIndonesian(String englishDay) {
    const map = {
      'monday': 'Senin',
      'tuesday': 'Selasa',
      'wednesday': 'Rabu',
      'thursday': 'Kamis',
      'friday': 'Jumat',
      'saturday': 'Sabtu',
      'sunday': 'Minggu',
    };
    return map[englishDay.toLowerCase()] ?? englishDay;
  }

  // ─── State widgets ────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return ShimmerLoadingContainer(
      child: Column(
        children: List.generate(
          3,
          (_) => Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            child: Container(height: 140, padding: const EdgeInsets.all(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String selectedDay, bool hasScheduleForDay) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: _lightColor, shape: BoxShape.circle),
              child: Icon(
                hasScheduleForDay
                    ? Icons.pending_actions_rounded
                    : Icons.event_busy_rounded,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                hasScheduleForDay
                    ? 'Belum ada data absensi untuk hari ini. Hubungi guru Anda untuk melakukan absensi'
                    : 'Tidak ada jadwal pelajaran untuk hari ${_getDayInIndonesian(selectedDay)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.fixedDate == null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _fetchSubjectAttendance,
                child: const Text('Muat Ulang'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<SubjectAttendance> list) {
    return AnimationLimiter(
      child: Column(
        children: List.generate(
          list.length,
          (i) => SubjectAttendanceCard(attendance: list[i], index: i),
        ),
      ),
    );
  }

  // ─── App bar with date picker bar ─────────────────────────────────────────

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      heightPercentage: Utils.appBarMediumtHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back button
          if (context.read<AuthCubit>().isParent() || widget.fixedDate != null)
            const Positioned(left: 10, top: -2, child: CustomBackButton()),

          // Title
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              Utils.getTranslatedLabel(subjectAttendanceKey),
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: Utils.screenTitleFontSize,
              ),
            ),
          ),

          // Date selector bar
          PositionedDirectional(
            bottom: -20,
            start: MediaQuery.of(context).size.width * 0.075,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.075),
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 5,
                  ),
                ],
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Stack(
                children: [
                  // Date tap target
                  Align(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context).colorScheme.primary,
                                onPrimary: Colors.white,
                                surface: _surfaceColor,
                                onSurface: Colors.grey[800] ?? Colors.grey,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: _primaryColor,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                              datePickerTheme: DatePickerThemeData(
                                headerBackgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                headerForegroundColor: Colors.white,
                                headerHeadlineStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                                dayOverlayColor:
                                    WidgetStateProperty.resolveWith(
                                  (states) => states
                                          .contains(WidgetState.selected)
                                      ? _primaryColor.withValues(alpha: 0.2)
                                      : null,
                                ),
                                dayStyle: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                todayForegroundColor:
                                    WidgetStateProperty.all(_primaryColor),
                                todayBackgroundColor: WidgetStateProperty.all(
                                    _lightColor.withValues(alpha: 0.7)),
                                yearOverlayColor:
                                    WidgetStateProperty.resolveWith(
                                  (states) => states
                                          .contains(WidgetState.selected)
                                      ? _primaryColor.withValues(alpha: 0.2)
                                      : null,
                                ),
                                yearStyle: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                surfaceTintColor: Colors.transparent,
                                backgroundColor: Colors.white,
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.1),
                                dividerColor: Colors.transparent,
                                rangePickerBackgroundColor: Colors.white,
                                rangeSelectionBackgroundColor: _lightColor,
                                rangeSelectionOverlayColor:
                                    WidgetStateProperty.all(
                                        _primaryColor.withValues(alpha: 0.1)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                inputDecorationTheme: InputDecorationTheme(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey
                                            .withValues(alpha: 0.3)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorStyle: const TextStyle(
                                      fontSize: 12, height: 0.8),
                                ),
                              ),
                              dialogTheme: const DialogThemeData(
                                  backgroundColor: Colors.transparent),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaler: TextScaler.linear(1.0)),
                              child: Builder(
                                builder: (context) => Dialog(
                                  insetPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical:
                                        MediaQuery.of(context).viewInsets.bottom >
                                                0
                                            ? 16.0
                                            : 24.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              (MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom >
                                                      0
                                                  ? 0.7
                                                  : 0.85),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: SingleChildScrollView(
                                            physics:
                                                const ClampingScrollPhysics(),
                                            child: child!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            _fetchSubjectAttendance();
                          });
                          _animationController.forward(from: 0.0);
                        }
                      },
                      child: Text(
                        dateFormatter.format(selectedDate),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Previous day
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ChangeCalendarMonthButton(
                      isDisable: false,
                      isNextButton: false,
                      onTap: () => _stepDate(-1),
                    ),
                  ),
                  // Next day
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ChangeCalendarMonthButton(
                      isDisable: selectedDate
                          .add(const Duration(days: 1))
                          .isAfter(DateTime.now()),
                      isNextButton: true,
                      onTap: () => _stepDate(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: RefreshIndicator(
            displacement: Utils.getScrollViewTopPadding(
              context: context,
              appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
            ),
            color: _primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () async => _fetchSubjectAttendance(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  BlocBuilder<SubjectAttendanceCubit, SubjectAttendanceState>(
                    builder: (context, state) {
                      if (state is SubjectAttendanceFetchInProgress) {
                        return _buildLoading();
                      }

                      if (state is SubjectAttendanceFetchSuccess) {
                        final selectedDay =
                            DateFormat('EEEE', 'en_US').format(selectedDate);
                        final selectedDateStr =
                            DateFormat('yyyy-MM-dd').format(selectedDate);

                        final filtered = state.subjectAttendances
                            .where((a) =>
                                a.subjectAttendance.timetable.day
                                    .toLowerCase() ==
                                    selectedDay.toLowerCase() &&
                                a.subjectAttendance.date == selectedDateStr)
                            .toList();

                        if (filtered.isEmpty) {
                          final hasSchedule = state.subjectAttendances.any((a) =>
                              a.subjectAttendance.timetable.day.toLowerCase() ==
                              selectedDay.toLowerCase());
                          return _buildEmptyState(selectedDay, hasSchedule);
                        }

                        return _buildList(filtered);
                      }

                      if (state is SubjectAttendanceFetchFailure) {
                        return ErrorContainer(
                          errorMessageCode: state.errorMessage,
                          onTapRetry: _fetchSubjectAttendance,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(alignment: Alignment.topCenter, child: _buildAppBar()),
      ],
    );
  }
}

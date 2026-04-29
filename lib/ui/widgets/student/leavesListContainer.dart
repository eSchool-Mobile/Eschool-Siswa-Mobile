import 'package:eschool/cubits/student/leavesCubit.dart';
import 'package:eschool/data/models/student/leave.dart';
import 'package:eschool/ui/widgets/student/leaveCard.dart';
import 'package:eschool/ui/widgets/system/customBackButton.dart';
import 'package:eschool/ui/widgets/system/errorContainer.dart';
import 'package:eschool/ui/widgets/system/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/ui/widgets/student/applyLeavesContainer.dart';
import 'package:eschool/data/models/auth/student.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeavesListContainer extends StatefulWidget {
  final int? childId;
  final Student student;

  const LeavesListContainer({
    Key? key,
    this.childId,
    required this.student,
  }) : super(key: key);

  @override
  State<LeavesListContainer> createState() => _LeavesListContainerState();
}

class _LeavesListContainerState extends State<LeavesListContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchLeaves);
  }

  void _fetchLeaves() {
    context.read<LeavesCubit>().fetchLeaves(childId: widget.childId ?? 0);
  }

  void _navigateToApplyLeaves() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) =>
              ApplyLeavesContainer(childId: widget.childId, data: null),
        ))
        .then((_) => _fetchLeaves());
  }

  bool _shouldShowFab(List<Leave> leaves) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return !leaves.any((l) => l.leaveDetail.any((d) => d.date == today));
  }

  // ─── Loading shimmer ──────────────────────────────────────────────────────

  Widget _buildLoadingShimmer() {
    final dummyLeaves = List.generate(
      5,
      (i) => Leave(
        id: i,
        userId: 0,
        reason: 'This is a dummy reason for the loading state skeletonizer.',
        type: 'Sick',
        fromDate: '2024-01-01',
        toDate: '2024-01-01',
        status: 0,
        schoolId: 0,
        rejectReason: '',
        leaveMasterId: 0,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
        leaveDetail: [
          LeaveDetail(
            id: i,
            leaveId: i,
            date: '2024-01-01',
            type: 'Sick',
            schoolId: 0,
          )
        ],
        fileDetail: [],
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: Utils.getScrollViewTopPadding(
                context: context,
                appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
              ) +
              10,
          bottom: 20,
        ),
        itemCount: dummyLeaves.length,
        itemBuilder: (_, i) => LeaveCard(
          leave: dummyLeaves[i],
          index: i,
          childId: widget.childId,
          studentFullName: widget.student.getFullName(),
          onRefresh: _fetchLeaves,
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
        ),
      ),
      child: Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 500)),
          ScaleEffect(duration: Duration(milliseconds: 500)),
        ],
        autoPlay: true,
        onComplete: (c) => c.stop(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15),
                Icon(
                  Icons.event_busy_rounded,
                  size: 120,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Belum Ada Data Izin Untuk Hari Ini!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap tombol + untuk mengajukan izin baru',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = Utils.getScrollViewTopPadding(
      context: context,
      appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
    );

    return Scaffold(
      floatingActionButton: BlocBuilder<LeavesCubit, LeavesState>(
        builder: (context, state) {
          if (state is LeavesFetchSuccess && _shouldShowFab(state.leaves)) {
            return FloatingActionButton(
              onPressed: _navigateToApplyLeaves,
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: Utils.getTranslatedLabel(applyLeavesKey),
              child: const Icon(Icons.add, color: Colors.white),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                );
          }
          return const SizedBox.shrink();
        },
      ),
      body: Stack(
        children: [
          // ─── Content ────────────────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              onRefresh: () async => _fetchLeaves(),
              color: Theme.of(context).colorScheme.primary,
              child: BlocBuilder<LeavesCubit, LeavesState>(
                builder: (context, state) {
                  if (state is LeavesFetchInProgress) {
                    return _buildLoadingShimmer();
                  }

                  if (state is LeavesFetchSuccess) {
                    final hasValidLeave = state.leaves.isNotEmpty &&
                        (state.leaves.first.leaveDetail.isNotEmpty) &&
                        state.leaves.first.leaveDetail.first.leaveId != null;

                    if (!hasValidLeave) return _buildEmptyState();

                    return ListView.builder(
                      padding: EdgeInsets.only(top: topPad, bottom: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.leaves.length,
                      itemBuilder: (_, i) => LeaveCard(
                        leave: state.leaves[i],
                        index: i,
                        childId: widget.childId,
                        studentFullName: widget.student.getFullName(),
                        onRefresh: _fetchLeaves,
                      ),
                    );
                  }

                  if (state is LeavesFetchFailure) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: topPad),
                      child: ErrorContainer(
                        errorMessageCode: state.errorMessage,
                        onTapRetry: _fetchLeaves,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ─── App bar ─────────────────────────────────────────────────────
          ScreenTopBackgroundContainer(
            heightPercentage: Utils.appBarSmallerHeightPercentage,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  const CustomBackButton(),
                  Text(
                    Utils.getTranslatedLabel(leavesKey),
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
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
}

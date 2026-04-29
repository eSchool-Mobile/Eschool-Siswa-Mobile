import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/auth/authCubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/cubits/exam/examTabSelectionCubit.dart';
import 'package:eschool/cubits/exam/examsOnlineCubit.dart';
import 'package:eschool/cubits/academic/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/models/exam/examOnline.dart';
import 'package:eschool/data/models/academic/subject.dart';
import 'package:eschool/ui/widgets/academic/assignmentsSubjectsContainer.dart';
import 'package:eschool/ui/widgets/exam/examFilterBottomSheet.dart';
import 'package:eschool/ui/widgets/exam/examOnlineShimmerLoading.dart';
import 'package:eschool/ui/widgets/exam/examSearchBar.dart';
import 'package:eschool/ui/widgets/system/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/system/errorContainer.dart';
import 'package:eschool/ui/widgets/exam/examOnlineKeyBottomsheetContainer.dart';
import 'package:eschool/ui/widgets/exam/listItemForOnlineExamAndOnlineResult.dart';
import 'package:eschool/ui/widgets/system/noDataContainer.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:get/get.dart';

class ExamOnlineListContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;

  const ExamOnlineListContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  State<ExamOnlineListContainer> createState() =>
      _ExamOnlineListContainerState();
}

class _ExamOnlineListContainerState extends State<ExamOnlineListContainer>
    with SingleTickerProviderStateMixin {
  late ExamOnline examSelected;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_examOnlinesScrollListener);

  String _selectedFilter = 'all';
  String _selectedFilterSiswa = 'all';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  void _examOnlinesScrollListener() {
    if (_scrollController.offset ==
        _scrollController.position.maxScrollExtent) {
      if (context.read<ExamsOnlineCubit>().hasMore()) {
        context.read<ExamsOnlineCubit>().getMoreExamsOnline(
              childId: widget.childId ?? 0,
              useParentApi: context.read<AuthCubit>().isParent(),
            );
      }
    }
  }

  void fetchExamsList() {
    Future.delayed(Duration.zero, () {
      context.read<ExamsOnlineCubit>().getExamsOnline(
            classSubjectId: context
                .read<ExamTabSelectionCubit>()
                .state
                .examFilterByClassSubjectId,
            childId: widget.childId ?? 0,
            useParentApi: context.read<AuthCubit>().isParent(),
          );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExamsList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_examOnlinesScrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> navigateToExamScreen() async {
    Get.back();
    Get.toNamed(Routes.examOnline, arguments: {"exam": examSelected});
  }

  void onTapOnlineExam(ExamOnline exam) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      elevation: 5.0,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => ExamOnlineKeyBottomsheetContainer(
        navigateToExamScreen: navigateToExamScreen,
        exam: exam,
      ),
    );
  }

  // ─── Core list build ──────────────────────────────────────────────────────

  List<ExamOnline> _applyFilters(List<ExamOnline> examList) {
    final searched = examList.where((exam) {
      return _searchQuery.isEmpty ||
          (exam.title?.toLowerCase().contains(_searchQuery) == true) ||
          (exam.subjectName?.toLowerCase().contains(_searchQuery) == true);
    }).toList()
      ..sort((a, b) {
        if (a.isExamStarted && !b.isExamStarted) return -1;
        if (!a.isExamStarted && b.isExamStarted) return 1;
        final aDate =
            a.startDate != null ? DateTime.parse(a.startDate!) : DateTime(0);
        final bDate =
            b.startDate != null ? DateTime.parse(b.startDate!) : DateTime(0);
        return bDate.compareTo(aDate);
      });

    final now = DateTime.now();
    final isParent = context.read<AuthCubit>().isParent();

    return searched.where((exam) {
      final startDate =
          exam.startDate != null ? DateTime.parse(exam.startDate!) : null;
      final endDate =
          exam.endDate != null ? DateTime.parse(exam.endDate!) : null;

      final matchesTime = () {
        switch (_selectedFilter) {
          case 'ongoing':
            return startDate != null &&
                endDate != null &&
                now.isAfter(startDate) &&
                now.isBefore(endDate);
          case 'completed':
            return endDate != null && now.isAfter(endDate);
          case 'upcoming':
            return startDate != null && now.isBefore(startDate);
          default:
            return true;
        }
      }();

      if (isParent) return matchesTime;

      final matchesStudentStatus = () {
        switch (_selectedFilterSiswa) {
          case 'process':
            return exam.status == 1;
          case 'completed':
            return exam.status == 2;
          case 'not_Yet':
            return exam.status == 0;
          default:
            return true;
        }
      }();

      return matchesTime && matchesStudentStatus;
    }).toList();
  }

  Widget _buildExamOnlineList(ExamsOnlineFetchSuccess state) {
    final filtered = _applyFilters(state.examList);

    if (filtered.isEmpty) {
      return NoDataContainer(
          titleKey: Utils.getTranslatedLabel(noExamsFoundKey));
    }

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(filtered.length, (index) {
            final exam = filtered[index];
            return ListItemForOnlineExamAndOnlineResult(
              isExamStarted: exam.isExamStarted,
              statusUjian: exam.status!,
              examStartingDate: exam.startDate ?? "",
              examEndingDate: exam.endDate ?? "",
              examName: exam.title ?? "",
              subjectName: exam.subjectName ?? "-",
              totalMarks: exam.totalMarks ?? "",
              isSubjectSelected: context
                      .read<ExamTabSelectionCubit>()
                      .state
                      .examFilterByClassSubjectId !=
                  0,
              marks: '',
              onItemTap: () => _handleExamTap(exam),
            );
          }),
        ),
      ),
    );
  }

  void _handleExamTap(ExamOnline exam) {
    final isParent = context.read<AuthCubit>().isParent();

    if (isParent) {
      if (exam.status == 2) {
        Navigator.of(context).pushNamed(Routes.resultOnline, arguments: {
          'examId': exam.id,
          'examName': exam.title,
          'subjectName': exam.subjectName,
          'childId': widget.childId,
        });
      } else {
        Utils.showCustomSnackBar(
          context: context,
          errorMessage: Utils.getTranslatedLabel(examNotCompletedYetKey),
          backgroundColor: Utils.getColorScheme(context).error,
          icon: Icons.error_outline_rounded,
        );
      }
      return;
    }

    // Student flow
    final now = DateTime.now();
    final startDate =
        exam.startDate != null ? DateTime.parse(exam.startDate!) : null;
    final endDate =
        exam.endDate != null ? DateTime.parse(exam.endDate!) : null;

    if (!(startDate?.isBefore(now) == true &&
        endDate?.isAfter(now) == true)) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(noExamNowKey),
        backgroundColor: Utils.getColorScheme(context).error,
      );
      return;
    }

    setState(() => examSelected = exam);

    if (endDate != null && now.difference(endDate).inDays > 0) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(noExamTodayKey),
        backgroundColor: Utils.getColorScheme(context).error,
      );
      return;
    }

    if (endDate != null && now.isBefore(endDate)) {
      onTapOnlineExam(exam);
    } else {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(noExamNowKey),
        backgroundColor: Utils.getColorScheme(context).error,
      );
    }
  }

  Widget _buildSubjectsContainer() {
    return BlocBuilder<StudentSubjectsAndSlidersCubit,
        StudentSubjectsAndSlidersState>(
      builder: (context, state) {
        return BlocBuilder<ExamTabSelectionCubit, ExamTabSelectionState>(
          bloc: context.read<ExamTabSelectionCubit>(),
          builder: (context, state) {
            return AssignmentsSubjectContainer(
              cubitAndState: "onlineExam",
              subjects: (widget.subjects != null)
                  ? widget.subjects!
                  : context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjectsForAssignmentContainer(),
              onTapSubject: (classSubjectId) {
                context
                    .read<ExamTabSelectionCubit>()
                    .changeExamFilterBySubjectId(classSubjectId);
                fetchExamsList();
              },
              selectedClassSubjectId: state.examFilterByClassSubjectId,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
        context: context,
        appBarHeightPercentage: Utils.appBarBiggerHeightPercentage -
            (Utils.appBarBiggerHeightPercentage * 0.1),
      ),
      onRefreshCallback: () {
        if (kDebugMode) print("refresh - fetch exams list");
        fetchExamsList();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: Utils.getScrollViewBottomPadding(context),
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarBiggerHeightPercentage -
                (Utils.appBarBiggerHeightPercentage * 0.1),
          ),
        ),
        child: Column(
          children: [
            _buildSubjectsContainer(),
            ExamSearchBar(
              controller: _searchController,
              onSearchChanged: (query) => setState(() => _searchQuery = query),
              onClearSearch: () => setState(() {
                _searchController.clear();
                _searchQuery = '';
              }),
              onFilterTap: () => ExamFilterBottomSheet.show(
                context: context,
                currentFilter: _selectedFilter,
                currentFilterSiswa: _selectedFilterSiswa,
                isParent: context.read<AuthCubit>().isParent(),
                onApply: (filter, filterSiswa) => setState(() {
                  _selectedFilter = filter;
                  _selectedFilterSiswa = filterSiswa;
                }),
              ),
            ),
            BlocBuilder<ExamsOnlineCubit, ExamsOnlineState>(
              builder: (context, state) {
                if (state is ExamsOnlineFetchSuccess) {
                  if (kDebugMode) {
                    print("ExamsOnlineFetchSuccess ${state.totalPage}");
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    child: state.examList.isEmpty
                        ? const NoDataContainer(titleKey: noExamsFoundKey)
                        : _buildExamOnlineList(state),
                  );
                }
                if (state is ExamsOnlineFetchFailure) {
                  return ErrorContainer(
                    errorMessageCode: state.errorMessage,
                    onTapRetry: () {
                      if (kDebugMode) print("Retry - fetch exams list");
                      fetchExamsList();
                    },
                  );
                }
                return const ExamOnlineShimmerLoading();
              },
            ),
          ],
        ),
      ),
    );
  }
}

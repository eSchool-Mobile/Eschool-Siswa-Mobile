
import 'package:eschool/cubits/extracurricular/extracurricularCubit.dart';
import 'package:eschool/cubits/extracurricular/myExtracurricularCubit.dart';

import 'package:eschool/cubits/extracurricular/allMyExtracurricularStatusCubit.dart';

import 'package:eschool/ui/widgets/system/customBackButton.dart';
import 'package:eschool/ui/widgets/system/errorContainer.dart';
import 'package:eschool/ui/widgets/system/noDataContainer.dart';
import 'package:eschool/ui/widgets/system/screenTopBackgroundContainer.dart';

import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eschool/ui/widgets/extracurricular/extracurricularSearchBar.dart';
import 'package:eschool/ui/widgets/extracurricular/extracurricularTabBar.dart';
import 'package:eschool/ui/widgets/extracurricular/extracurricularCard.dart';
import 'package:eschool/ui/widgets/extracurricular/myExtracurricularCard.dart';
import 'package:eschool/ui/widgets/extracurricular/extracurricularShimmer.dart';

class ExtracurricularContainer extends StatefulWidget {
  final bool showBackButton;

  const ExtracurricularContainer({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<ExtracurricularContainer> createState() =>
      _ExtracurricularContainerState();
}

class _ExtracurricularContainerState extends State<ExtracurricularContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(Duration.zero, () {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    // Fetch all extracurriculars first to get coach names
    context.read<ExtracurricularCubit>().fetchExtracurriculars();
    // Then fetch my extracurriculars
    context.read<MyExtracurricularCubit>().fetchMyExtracurriculars();
    // Also fetch all my extracurricular statuses for button status checking
    context
        .read<AllMyExtracurricularStatusCubit>()
        .fetchAllMyExtracurricularStatuses();
  }

  Future<void> _onRefresh() async {
    // Clear search when refreshing
    _searchController.clear();

    // Fetch data based on current tab
    if (_currentTabIndex == 0) {
      // All Extracurriculars tab
      context.read<ExtracurricularCubit>().fetchExtracurriculars();
      // Also refresh status for button updates
      context
          .read<AllMyExtracurricularStatusCubit>()
          .fetchAllMyExtracurricularStatuses();
    } else {
      // My Extracurriculars tab
      context.read<MyExtracurricularCubit>().fetchMyExtracurriculars();
    }

    // Wait a bit for the API call to complete
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _refreshAfterJoin() {
    // Optimized refresh after successful join
    // Prioritize fetching my extracurriculars first to show updated status
    context.read<MyExtracurricularCubit>().fetchMyExtracurriculars();
    // Also immediately fetch all statuses to update button states
    context
        .read<AllMyExtracurricularStatusCubit>()
        .fetchAllMyExtracurricularStatuses();

    // Delay fetching all extracurriculars to avoid overwhelming the API
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ExtracurricularCubit>().fetchExtracurriculars();
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_currentTabIndex == 0) {
      context.read<ExtracurricularCubit>().searchExtracurriculars(query);
    } else {
      context.read<MyExtracurricularCubit>().fetchMyExtracurriculars(
            search: query,
          );
    }
  }

  Widget _buildAllExtracurriculars() {
    return BlocBuilder<ExtracurricularCubit, ExtracurricularState>(
      builder: (context, state) {
        if (state is ExtracurricularFetchInProgress) {
          return const ExtracurricularShimmer();
        } else if (state is ExtracurricularFetchFailure) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                context.read<ExtracurricularCubit>().fetchExtracurriculars();
              },
            ),
          );
        } else if (state is ExtracurricularFetchSuccess) {
          if (state.extracurriculars.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child:
                  const NoDataContainer(titleKey: 'Tidak ada ekstrakurikuler'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 100), // Increased padding for bottom navigation
              itemCount: state.extracurriculars.length,
              itemBuilder: (context, index) {
                return ExtracurricularCard(
                  extracurricular: state.extracurriculars[index],
                  onJoinSuccess: _refreshAfterJoin,
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMyExtracurriculars() {
    return BlocBuilder<MyExtracurricularCubit, MyExtracurricularState>(
      builder: (context, state) {
        if (state is MyExtracurricularFetchInProgress) {
          return const ExtracurricularShimmer();
        } else if (state is MyExtracurricularFetchFailure) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                context
                    .read<MyExtracurricularCubit>()
                    .fetchMyExtracurriculars();
              },
            ),
          );
        } else if (state is MyExtracurricularFetchSuccess) {
          final approvedExtracurriculars =
              state.myExtracurriculars.where((e) => e.status == 1).toList();

          if (approvedExtracurriculars.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: const NoDataContainer(
                  titleKey: 'Anda belum mengikuti ekstrakurikuler apapun'),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 100), // Increased padding for bottom navigation
              itemCount: approvedExtracurriculars.length,
              itemBuilder: (context, index) {
                return MyExtracurricularCard(
                  studentExtracurricular: approvedExtracurriculars[index],
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              ScreenTopBackgroundContainer(
                heightPercentage: Utils.appBarSmallerHeightPercentage,
                child: Stack(
                  children: [
                    if (widget.showBackButton) const CustomBackButton(),
                    // Title positioned in the center of header
                    Positioned(
                      top: 0,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: Text(
                          'Ekstrakurikuler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ExtracurricularSearchBar(
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onClearSearch: () {
                  setState(() {
                    _searchController.clear();
                    _onSearchChanged('');
                  });
                },
              ),
              ExtracurricularTabBar(
                currentTabIndex: _currentTabIndex,
                onTabChanged: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                  _tabController.animateTo(index);
                  _fetchData();
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _currentTabIndex == 0
                    ? _buildAllExtracurriculars()
                    : _buildMyExtracurriculars(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


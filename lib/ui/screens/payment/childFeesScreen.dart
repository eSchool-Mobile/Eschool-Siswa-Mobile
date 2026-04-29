import 'package:eschool/cubits/payment/childFeeDetailsCubit.dart';
import 'package:eschool/cubits/payment/xenditInvoiceCubit.dart';
import 'package:eschool/data/models/auth/student.dart';
import 'package:eschool/data/models/payment/childFeeDetails.dart';
import 'package:eschool/data/repositories/payment/xenditRepository.dart';
import 'package:eschool/ui/screens/payment/payment/xenditOnlyPaymentScreen.dart';

import 'package:eschool/ui/widgets/payment/feeCard.dart';
import 'package:eschool/ui/widgets/payment/feeFloatingPaymentButton.dart';
import 'package:eschool/ui/widgets/payment/feeOverviewBoard.dart';
import 'package:eschool/ui/widgets/system/customBackButton.dart';
import 'package:eschool/ui/widgets/system/errorContainer.dart';
import 'package:eschool/ui/widgets/system/noDataContainer.dart';
import 'package:eschool/ui/widgets/system/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/system/shimmerLoaders/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/system/shimmerLoaders/shimmerLoadingContainer.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildFeesScreen extends StatefulWidget {
  final Student child;
  ChildFeesScreen({Key? key, required this.child}) : super(key: key);

  static Widget routeInstance() {
    return ChildFeesScreen(child: Get.arguments as Student);
  }

  @override
  State<ChildFeesScreen> createState() => _ChildFeesScreenState();
}

class _ChildFeesScreenState extends State<ChildFeesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  Set<int> selectedFeeIds = <int>{};
  final accentGreen = const Color(0xFF10B981);

  bool _isReturningFromNavigation = false;
  bool _hasInitialized = false;

  String selectedTab = 'unpaid';
  bool _isSortDescending = true;

  String get paidTab => 'Sudah Dibayar';
  String get unpaidTab => 'Belum Dibayar';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    selectedFeeIds.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _performCompleteReload();
        _hasInitialized = true;
      }
    });
  }

  @override
  void didUpdateWidget(ChildFeesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) _handleReturnFromNavigation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _handleReturnFromNavigation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _hasInitialized) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _handleReturnFromNavigation();
      });
    }
  }

  // ─── Animations ───────────────────────────────────────────────────────────

  void _initializeAnimations() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _floatingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
  }

  void _resetAnimations() {
    try {
      _animationController.stop();
      _pulseController.stop();
      _floatingController.stop();
      _animationController.reset();
      _pulseController.reset();
      _floatingController.reset();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _animationController.forward();
          _pulseController.repeat();
          _floatingController.repeat();
        }
      });
    } catch (_) {}
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  void fetchChildFeeDetails() {
    setState(() => selectedFeeIds.clear());
    context
        .read<ChildFeeDetailsCubit>()
        .fetchChildFeeDetails(childId: widget.child.id ?? 0);
  }

  void _resetCubitAndFetchData() {
    try {
      context
          .read<ChildFeeDetailsCubit>()
          .fetchChildFeeDetails(childId: widget.child.id ?? 0);
    } catch (_) {}
  }

  void _handleReturnFromNavigation() {
    if (_isReturningFromNavigation) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _performCompleteReload();
    });
  }

  void _performCompleteReload() {
    setState(() {
      _isReturningFromNavigation = true;
      selectedFeeIds.clear();
    });
    _resetAnimations();
    _resetCubitAndFetchData();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isReturningFromNavigation = false);
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _toggleFeeSelection(int feeId) {
    setState(() {
      if (selectedFeeIds.contains(feeId)) {
        selectedFeeIds.remove(feeId);
      } else {
        selectedFeeIds.add(feeId);
      }
    });
  }

  double _getTotalSelectedAmount(List<ChildFeeDetails> fees) {
    double total = 0;
    for (var fee in fees) {
      final status = fee.getFeePaymentStatus();
      if (selectedFeeIds.contains(fee.id) &&
          (status == unpaidKey || status == partiallyPaidKey)) {
        total += fee.remainingFeeAmountToPay();
      }
    }
    return total;
  }

  bool _hasPendingPayment(ChildFeeDetails fee) {
    final bill =
        fee.bills?.isNotEmpty == true ? fee.bills!.first : null;
    if (bill == null || bill.paymentHistory.isEmpty) return false;
    return bill.paymentHistory
        .any((p) => p.status?.toLowerCase() == 'pending');
  }

  List<ChildFeeDetails> _filterFees(List<ChildFeeDetails> fees) {
    return fees.where((fee) {
      final feeStatus = fee.getFeePaymentStatus();
      final remaining = fee.remainingFeeAmountToPay();
      final hasPending = _hasPendingPayment(fee);
      if (selectedTab == 'paid') {
        return feeStatus == paidKey || remaining == 0;
      } else if (selectedTab == 'pending') {
        return hasPending;
      } else {
        return (feeStatus == unpaidKey || remaining > 0) &&
            !(feeStatus == paidKey || remaining == 0) &&
            !hasPending;
      }
    }).toList();
  }

  String _getTabLabel(String tab) {
    switch (tab) {
      case 'paid':
        return 'Sudah Dibayar';
      case 'unpaid':
        return 'Belum Dibayar';
      default:
        return 'Filter';
    }
  }

  // ─── Bottom sheet ─────────────────────────────────────────────────────────

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Filter Biaya',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih status untuk menampilkan tagihan berdasarkan status tagihan',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildStatusOption(context, 'paid', paidTab),
              _buildStatusOption(context, 'unpaid', unpaidTab),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
      BuildContext context, String value, String label) {
    final bool isSelected = selectedTab == value;
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = value);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  // ─── Shimmer loading ──────────────────────────────────────────────────────

  Widget _buildFeeShimmerLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                        height: 48, width: 48, borderRadius: 14)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                              height: 16,
                              width:
                                  MediaQuery.of(context).size.width * 0.4)),
                      const SizedBox(height: 6),
                      ShimmerLoadingContainer(
                          child: CustomShimmerContainer(
                              height: 12,
                              width:
                                  MediaQuery.of(context).size.width * 0.25)),
                    ],
                  ),
                ),
                ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                        height: 28, width: 70, borderRadius: 16)),
              ],
            ),
            const SizedBox(height: 16),
            ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                    height: 70,
                    width: double.infinity,
                    borderRadius: 14)),
            const SizedBox(height: 14),
            Row(
              children: [
                ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                        height: 28, width: 90, borderRadius: 10)),
                const SizedBox(width: 10),
                ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                        height: 28, width: 110, borderRadius: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Fee list container ───────────────────────────────────────────────────

  Widget _buildFeesContainer({required List<ChildFeeDetails> fees}) {
    final filtered = _filterFees(fees);

    if (filtered.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade50, Colors.white],
                ),
              ),
            ),
            Center(
                child: NoDataContainer(
                    titleKey: noUnpaidBillsKey, animate: true)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: () async => fetchChildFeeDetails(),
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: Utils.getScrollViewTopPadding(
                  context: context,
                  appBarHeightPercentage:
                      Utils.appBarBiggerHeightPercentage -
                          (Utils.appBarBiggerHeightPercentage * 0.1),
                ) +
                10,
            bottom: selectedFeeIds.isNotEmpty ? 100 : 30,
            left: 20,
            right: 20,
          ),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return FeeOverviewBoard(
                fees: filtered,
                selectedTab: selectedTab,
                isSortDescending: _isSortDescending,
                accentGreen: accentGreen,
              );
            }
            final fee = filtered[index - 1];
            return FeeCard(
              feeDetails: fee,
              index: index - 1,
              isSelected: selectedFeeIds.contains(fee.id),
              hasPendingPayment: _hasPendingPayment(fee),
              pulseController: _pulseController,
              onSelectionToggle: fee.id != null
                  ? () => _toggleFeeSelection(fee.id!)
                  : () {},
            );
          },
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Floating background blobs
          ...List.generate(2, (i) {
            return AnimatedBuilder(
              animation: _floatingController,
              builder: (context, _) {
                final offset = Tween<double>(begin: 0.0, end: 15.0)
                    .animate(CurvedAnimation(
                      parent: _floatingController,
                      curve: Interval(i * 0.5, 1.0,
                          curve: Curves.easeInOut),
                    ))
                    .value;
                return Positioned(
                  top: 120 + (i * 300),
                  right: -40 + offset,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.04),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
            builder: (context, state) {
              if (state is ChildFeeDetailsFetchSuccess) {
                return _buildFeesContainer(fees: state.fees);
              }
              if (state is ChildFeeDetailsFetchFailure) {
                return Center(
                  child: Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 400)),
                      ScaleEffect(duration: Duration(milliseconds: 400)),
                    ],
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: fetchChildFeeDetails,
                    ),
                  ),
                );
              }
              // Loading
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade50, Colors.white],
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: Utils.getScrollViewTopPadding(
                          context: context,
                          appBarHeightPercentage:
                              Utils.appBarBiggerHeightPercentage -
                                  (Utils.appBarBiggerHeightPercentage *
                                      0.1),
                        ) +
                        10,
                    bottom: 30,
                  ),
                  itemCount: 5,
                  itemBuilder: (_, __) => _buildFeeShimmerLoading(),
                ),
              );
            },
          ),

          // App bar with tab selector
          ScreenTopBackgroundContainer(
            heightPercentage: Utils.appBarBiggerHeightPercentage -
                (Utils.appBarBiggerHeightPercentage * 0.1),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Stack(
                  children: [
                    const Positioned(
                        left: 10, top: -2, child: CustomBackButton()),
                    Positioned(
                      right: 15,
                      top: -12,
                      child: CustomHistoryButton(child: widget.child),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: boxConstraints.maxWidth * 0.5,
                        child: Text(
                          Utils.getTranslatedLabel(feesKey),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: Utils.screenTitleFontSize,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.0, 0.3),
                      child: SizedBox(
                        width: boxConstraints.maxWidth * 0.9,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _showFilterBottomSheet(context),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getTabLabel(selectedTab),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: IconButton(
                                icon: Transform.scale(
                                  scaleY: _isSortDescending ? 1.0 : -1.0,
                                  child: Icon(
                                    Icons.filter_list_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                tooltip: _isSortDescending
                                    ? 'Terbaru di atas'
                                    : 'Terlama di atas',
                                onPressed: () => setState(() =>
                                    _isSortDescending = !_isSortDescending),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Floating pay button
          if (selectedFeeIds.isNotEmpty && selectedTab == 'unpaid')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<ChildFeeDetailsCubit, ChildFeeDetailsState>(
                builder: (context, state) {
                  if (state is ChildFeeDetailsFetchSuccess) {
                    final selectedFeesData = state.fees
                        .where((fee) =>
                            selectedFeeIds.contains(fee.id) &&
                            (fee.getFeePaymentStatus() == unpaidKey ||
                                fee.remainingFeeAmountToPay() > 0) &&
                            !(fee.getFeePaymentStatus() == paidKey ||
                                fee.remainingFeeAmountToPay() == 0))
                        .toList();

                    return FeeFloatingPaymentButton(
                      selectedCount: selectedFeeIds.length,
                      totalAmount: _getTotalSelectedAmount(state.fees),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                XenditInvoiceCubit(XenditRepository()),
                            child: XenditOnlyPaymentScreen(
                              selectedFees: selectedFeesData,
                              totalAmount:
                                  _getTotalSelectedAmount(state.fees),
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Standalone widgets kept alongside this screen ────────────────────────────

class CustomHistoryButton extends StatelessWidget {
  final Student child;
  const CustomHistoryButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/payment-history', arguments: child),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.history_rounded,
            size: 30, color: Colors.white),
      ),
    );
  }
}

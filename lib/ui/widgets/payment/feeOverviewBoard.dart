import 'package:eschool/data/models/payment/childFeeDetails.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Compact stat card used inside the payment overview board.
class FeeStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double amount;
  final Color color;
  final String Function(double) formatCurrency;

  const FeeStatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.amount,
    required this.color,
    required this.formatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated overview board showing summary stats for a list of fees.
class FeeOverviewBoard extends StatelessWidget {
  final List<ChildFeeDetails> fees;
  final String selectedTab;
  final bool isSortDescending;
  final Color accentGreen;

  const FeeOverviewBoard({
    Key? key,
    required this.fees,
    required this.selectedTab,
    required this.isSortDescending,
    required this.accentGreen,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    int paidFees = 0, pendingFees = 0, unpaidFees = 0;
    double totalAmount = 0,
        paidAmount = 0,
        pendingAmount = 0,
        unpaidAmount = 0,
        totalOutstanding = 0;

    for (var fee in fees) {
      final feeRemaining = fee.remainingFeeAmountToPay();
      final isPaid =
          fee.getFeePaymentStatus() == paidKey || feeRemaining == 0;

      bool hasPendingPayment = false;
      final bill = fee.bills?.isNotEmpty == true ? fee.bills!.first : null;
      if (bill != null && bill.paymentHistory.isNotEmpty) {
        final recentPending = bill.paymentHistory
            .any((p) => p.status?.toLowerCase() == 'pending');
        final hasPartial = fee.getPaidAmount() > 0 && feeRemaining > 0;
        hasPendingPayment = recentPending && hasPartial;
      }

      final feeStatus = fee.getFeePaymentStatus();
      hasPendingPayment = hasPendingPayment ||
          feeStatus == 'menunggu konfirmasi admin' ||
          feeStatus == 'waiting for admin confirmation' ||
          feeStatus == 'payment under review';

      if (isPaid) {
        paidFees++;
        paidAmount += fee.getPaidAmount();
      } else if (hasPendingPayment) {
        pendingFees++;
        if (bill != null) {
          pendingAmount += bill.paymentHistory
              .where((p) => p.status?.toLowerCase() == 'pending')
              .fold(0.0, (s, p) => s + (p.amount ?? 0));
        }
      } else {
        unpaidFees++;
        unpaidAmount += feeRemaining;
      }

      totalAmount += fee.getTotalAmount();
      totalOutstanding += feeRemaining;
    }

    Widget statCard;
    if (selectedTab == 'paid') {
      statCard = FeeStatCard(
        icon: Icons.check_circle_outline,
        label: Utils.getTranslatedLabel(paidKey),
        value: '$paidFees',
        amount: paidAmount,
        color: accentGreen,
        formatCurrency: _formatCurrency,
      );
    } else if (selectedTab == 'pending') {
      statCard = FeeStatCard(
        icon: Icons.hourglass_top_rounded,
        label: Utils.getTranslatedLabel(pendingconfirmKey),
        value: '$pendingFees',
        amount: pendingAmount,
        color: Colors.orange.shade600,
        formatCurrency: _formatCurrency,
      );
    } else {
      statCard = FeeStatCard(
        icon: Icons.cancel_outlined,
        label: Utils.getTranslatedLabel(unpaidKey),
        value: '$unpaidFees',
        amount: unpaidAmount,
        color: primaryColor,
        formatCurrency: _formatCurrency,
      );
    }

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 600)),
        SlideEffect(
          begin: Offset(0, -0.2),
          end: Offset.zero,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.analytics_outlined,
                        color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Utils.getTranslatedLabel(paymentOverviewKey),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status stat + total amount
              Column(
                children: [
                  statCard,
                  const SizedBox(height: 12),
                  // Total amount card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 20,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Utils.getTranslatedLabel(totalAmountKey),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                totalAmount > 0
                                    ? _formatCurrency(totalAmount)
                                    : "No amount data",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  height: 1,
                                ),
                              ),
                              if (totalOutstanding > 0) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.orange.shade200),
                                  ),
                                  child: Text(
                                    '${Utils.getTranslatedLabel(outstandingKey)}: ${_formatCurrency(totalOutstanding)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

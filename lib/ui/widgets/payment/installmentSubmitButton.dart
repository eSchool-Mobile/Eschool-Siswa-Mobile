import 'package:eschool/cubits/payment/paymentSubmissionCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InstallmentSubmitButton extends StatelessWidget {
  final bool canProceed;
  final String hintMessage;
  final VoidCallback onProcessPayment;

  const InstallmentSubmitButton({
    Key? key,
    required this.canProceed,
    required this.hintMessage,
    required this.onProcessPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PaymentSubmissionCubit, PaymentSubmissionState>(
        builder: (context, state) {
          final isSubmitting = state is PaymentSubmissionInProgress;
          final isEnabled = canProceed && !isSubmitting;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hint message when disabled
              if (!isEnabled && !isSubmitting)
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 300)),
                    SlideEffect(
                      begin: Offset(0, -0.2),
                      duration: Duration(milliseconds: 300),
                    ),
                  ],
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hintMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: isEnabled ? onProcessPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isEnabled ? 8 : 2,
                    shadowColor: isEnabled
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Memproses Pembayaran...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          isEnabled ? Icons.payment_rounded : Icons.lock_outline,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Kirim Pembayaran Cicilan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

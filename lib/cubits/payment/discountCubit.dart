import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DiscountState {}

class DiscountInitial extends DiscountState {}

class DiscountLoading extends DiscountState {}

class DiscountLoaded extends DiscountState {
  final Discount discount;
  final int billId;

  DiscountLoaded({
    required this.discount,
    required this.billId,
  });
}

class DiscountLoadFailure extends DiscountState {
  final String errorMessage;

  DiscountLoadFailure({required this.errorMessage});
}

class Discount {
  final int percent;
  final int amount;
  final String? notes;
  final bool hasDiscount;

  Discount({
    required this.percent,
    required this.amount,
    this.notes,
    required this.hasDiscount,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      percent: json['percent'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
      notes: json['notes'] as String?,
      hasDiscount: json['has_discount'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'amount': amount,
      'notes': notes,
      'has_discount': hasDiscount,
    };
  }

  Discount copyWith({
    int? percent,
    int? amount,
    String? notes,
    bool? hasDiscount,
  }) {
    return Discount(
      percent: percent ?? this.percent,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      hasDiscount: hasDiscount ?? this.hasDiscount,
    );
  }
}

class DiscountCubit extends Cubit<DiscountState> {
  DiscountCubit() : super(DiscountInitial());

  void loadDiscount({
    required int billId,
    required Map<String, dynamic> discountData,
  }) {
    try {
      emit(DiscountLoading());

      // Parse discount data
      final int percent = discountData['percent'] as int? ?? 0;
      final int amount = discountData['amount'] as int? ?? 0;
      final String? notes = discountData['notes'] as String?;
      final bool hasDiscount = discountData['has_discount'] as bool? ?? false;

      final discount = Discount(
        percent: percent,
        amount: amount,
        notes: notes,
        hasDiscount: hasDiscount,
      );

      emit(DiscountLoaded(
        discount: discount,
        billId: billId,
      ));
    } catch (e) {
      emit(DiscountLoadFailure(errorMessage: e.toString()));
    }
  }

  void applyDiscount({
    required int billId,
    required int percent,
    required int amount,
    String? notes,
  }) {
    try {
      final discount = Discount(
        percent: percent,
        amount: amount,
        notes: notes,
        hasDiscount: true,
      );

      emit(DiscountLoaded(
        discount: discount,
        billId: billId,
      ));
    } catch (e) {
      emit(DiscountLoadFailure(errorMessage: e.toString()));
    }
  }

  void removeDiscount(int billId) {
    try {
      final discount = Discount(
        percent: 0,
        amount: 0,
        notes: null,
        hasDiscount: false,
      );

      emit(DiscountLoaded(
        discount: discount,
        billId: billId,
      ));
    } catch (e) {
      emit(DiscountLoadFailure(errorMessage: e.toString()));
    }
  }

  void clearDiscount() {
    emit(DiscountInitial());
  }
}

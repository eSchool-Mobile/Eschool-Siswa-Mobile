import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PenaltyState {}

class PenaltyInitial extends PenaltyState {}

class PenaltyLoading extends PenaltyState {}

class PenaltyLoaded extends PenaltyState {
  final Penalty penalty;
  final int billId;

  PenaltyLoaded({
    required this.penalty,
    required this.billId,
  });
}

class PenaltyLoadFailure extends PenaltyState {
  final String errorMessage;

  PenaltyLoadFailure({required this.errorMessage});
}

class Penalty {
  final bool isOverdue;
  final int percent;
  final int amount;
  final bool hasPenalty;

  Penalty({
    required this.isOverdue,
    required this.percent,
    required this.amount,
    required this.hasPenalty,
  });

  factory Penalty.fromJson(Map<String, dynamic> json) {
    return Penalty(
      isOverdue: json['is_overdue'] as bool? ?? false,
      percent: json['percent'] as int? ?? 0,
      amount: json['amount'] as int? ?? 0,
      hasPenalty: json['has_penalty'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_overdue': isOverdue,
      'percent': percent,
      'amount': amount,
      'has_penalty': hasPenalty,
    };
  }

  Penalty copyWith({
    bool? isOverdue,
    int? percent,
    int? amount,
    bool? hasPenalty,
  }) {
    return Penalty(
      isOverdue: isOverdue ?? this.isOverdue,
      percent: percent ?? this.percent,
      amount: amount ?? this.amount,
      hasPenalty: hasPenalty ?? this.hasPenalty,
    );
  }
}

class PenaltyCubit extends Cubit<PenaltyState> {
  PenaltyCubit() : super(PenaltyInitial());

  void loadPenalty({
    required int billId,
    required Map<String, dynamic> penaltyData,
  }) {
    try {
      emit(PenaltyLoading());

      // Parse penalty data
      final bool isOverdue = penaltyData['is_overdue'] as bool? ?? false;
      final int percent = penaltyData['percent'] as int? ?? 0;
      final int amount = penaltyData['amount'] as int? ?? 0;
      final bool hasPenalty = penaltyData['has_penalty'] as bool? ?? false;

      final penalty = Penalty(
        isOverdue: isOverdue,
        percent: percent,
        amount: amount,
        hasPenalty: hasPenalty,
      );

      emit(PenaltyLoaded(
        penalty: penalty,
        billId: billId,
      ));
    } catch (e) {
      emit(PenaltyLoadFailure(errorMessage: e.toString()));
    }
  }

  void applyPenalty({
    required int billId,
    required int percent,
    required int amount,
    bool isOverdue = true,
  }) {
    try {
      final penalty = Penalty(
        isOverdue: isOverdue,
        percent: percent,
        amount: amount,
        hasPenalty: true,
      );

      emit(PenaltyLoaded(
        penalty: penalty,
        billId: billId,
      ));
    } catch (e) {
      emit(PenaltyLoadFailure(errorMessage: e.toString()));
    }
  }

  void removePenalty(int billId) {
    try {
      final penalty = Penalty(
        isOverdue: false,
        percent: 0,
        amount: 0,
        hasPenalty: false,
      );

      emit(PenaltyLoaded(
        penalty: penalty,
        billId: billId,
      ));
    } catch (e) {
      emit(PenaltyLoadFailure(errorMessage: e.toString()));
    }
  }

  void clearPenalty() {
    emit(PenaltyInitial());
  }
}

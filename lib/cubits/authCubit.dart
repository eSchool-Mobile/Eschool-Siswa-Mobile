import 'package:equatable/equatable.dart';
import 'package:eschool/data/models/guardian.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class Authenticated extends AuthState {
  final String jwtToken;
  final bool isStudent;
  final Student student;
  final Guardian parent;
  final String schoolCode;
  final List<Student> children;

  Authenticated({
    required this.jwtToken,
    required this.isStudent,
    required this.student,
    required this.parent,
    required this.schoolCode,
    this.children = const [],
  });

  @override
  List<Object?> get props => [
        jwtToken,
        isStudent,
        student,
        parent,
        schoolCode,
        children,
      ];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() {
    print("DEBUG: _checkIsAuthenticated called");
    print("DEBUG: getIsLogIn() = ${authRepository.getIsLogIn()}");

    if (authRepository.getIsLogIn()) {
      // Load children data from persistence storage
      final storedChildren = AuthRepository.getChildrenData();
      print("DEBUG: storedChildren count = ${storedChildren.length}");

      // For parent login, get the current active child's token and school code
      String currentSchoolCode = authRepository.schoolCode;
      String currentJwtToken = authRepository.getJwtToken();
      print("DEBUG: currentSchoolCode from storage = '$currentSchoolCode'");
      print(
          "DEBUG: currentJwtToken from storage = '${currentJwtToken.isEmpty ? 'EMPTY' : 'HAS_VALUE'}'");

      Student currentStudent = Student.fromJson({});

      if (!AuthRepository.getIsStudentLogIn() && storedChildren.isNotEmpty) {
        print(
            "DEBUG: Processing parent login with ${storedChildren.length} children");

        // Find the active child based on stored token/schoolCode or use first child
        final activeChild = storedChildren.firstWhere(
          (child) =>
              child.token == currentJwtToken ||
              child.schoolCode == currentSchoolCode,
          orElse: () => storedChildren.first,
        );

        print(
            "DEBUG: activeChild = ${activeChild.getFullName()}, token=${activeChild.token?.isEmpty == true ? 'EMPTY' : 'HAS_VALUE'}, schoolCode=${activeChild.schoolCode}");

        // Update with active child's credentials if they exist
        if (activeChild.token != null && activeChild.token!.isNotEmpty) {
          currentJwtToken = activeChild.token!;
          authRepository.setJwtToken(currentJwtToken);
          print("DEBUG: Updated token to active child's token");
        } else {
          print("DEBUG: Active child has no token!");
        }

        if (activeChild.schoolCode != null &&
            activeChild.schoolCode!.isNotEmpty) {
          currentSchoolCode = activeChild.schoolCode!;
          authRepository.schoolCode = currentSchoolCode;
          print(
              "DEBUG: Updated schoolCode to active child's schoolCode: $currentSchoolCode");
        } else if (activeChild.school?.code != null &&
            activeChild.school!.code!.isNotEmpty) {
          currentSchoolCode = activeChild.school!.code!;
          authRepository.schoolCode = currentSchoolCode;
          print(
              "DEBUG: Updated schoolCode from school object: $currentSchoolCode");
        } else {
          print("DEBUG: Active child has no school code!");
        }

        currentStudent = activeChild;
      } else if (AuthRepository.getIsStudentLogIn()) {
        print("DEBUG: Processing student login");
        currentStudent = AuthRepository.getStudentDetails();
      } else {
        print("DEBUG: No children found or not parent login");
      }

      print(
          "DEBUG: Final values - schoolCode: '$currentSchoolCode', token: '${currentJwtToken.isEmpty ? 'EMPTY' : 'HAS_VALUE'}'");

      emit(
        Authenticated(
          schoolCode: currentSchoolCode,
          jwtToken: currentJwtToken,
          isStudent: AuthRepository.getIsStudentLogIn(),
          parent: AuthRepository.getIsStudentLogIn()
              ? Guardian.fromJson({})
              : AuthRepository.getParentDetails(),
          student: currentStudent,
          children: storedChildren, // Load children from storage
        ),
      );
    } else {
      print("DEBUG: User not logged in");
      emit(Unauthenticated());
    }
  }

  void authenticateUser({
    required String schoolCode,
    required String jwtToken,
    required bool isStudent,
    required Guardian parent,
    required Student student,
    List<Student> children = const [],
  }) {
    print(
        "DEBUG authenticateUser: schoolCode='$schoolCode', jwtToken='${jwtToken.isEmpty ? 'EMPTY' : 'HAS_VALUE'}', isStudent=$isStudent");
    print("DEBUG authenticateUser: children count=${children.length}");

    //
    authRepository.schoolCode = schoolCode;
    authRepository.setJwtToken(jwtToken);
    authRepository.setIsLogIn(true);
    authRepository.setIsStudentLogIn(isStudent);
    authRepository.setStudentDetails(student);
    authRepository.setParentDetails(parent);

    // Save children data to persistence storage
    if (children.isNotEmpty) {
      print("DEBUG authenticateUser: Saving children to persistence...");
      authRepository.setChildrenData(children);
    } else {
      print("DEBUG authenticateUser: No children to save");
    }

    //emit new state
    emit(
      Authenticated(
        schoolCode: schoolCode,
        jwtToken: jwtToken,
        isStudent: isStudent,
        student: student,
        parent: parent,
        children: children,
      ),
    );

    print("DEBUG authenticateUser: Authentication completed");
  }

  // Method to switch to a specific child session
  void switchToChildSession(Student child) {
    print(
        "DEBUG switchToChildSession: Switching to child ${child.getFullName()}");
    print(
        "DEBUG switchToChildSession: Child token='${child.token}', schoolCode='${child.schoolCode}', school.code='${child.school?.code}'");

    if (state is Authenticated) {
      final currentState = state as Authenticated;

      // Update the token and school code for the selected child
      // Use schoolCode field first, then fallback to school?.code
      final childSchoolCode = child.schoolCode ?? child.school?.code ?? '';
      final childToken = child.token ?? '';

      print(
          "DEBUG switchToChildSession: Setting token='$childToken', schoolCode='$childSchoolCode'");

      // Set the token and school code synchronously
      authRepository.setJwtToken(childToken);
      authRepository.schoolCode = childSchoolCode;

      // Also update the child object to ensure it has the latest data
      final updatedChild = child.copyWith(
        token: childToken,
        schoolCode: childSchoolCode,
      );

      // Update children list with the latest data
      final updatedChildren = currentState.children
          .map((c) => c.id == child.id ? updatedChild : c)
          .toList();

      // Save updated children data immediately
      authRepository.setChildrenData(updatedChildren);

      print(
          "DEBUG switchToChildSession: Verifying persistence - token='${authRepository.getJwtToken()}', schoolCode='${authRepository.schoolCode}'");

      emit(
        Authenticated(
          schoolCode: childSchoolCode,
          jwtToken: childToken,
          isStudent: false, // Parent viewing child data
          student: updatedChild,
          parent: currentState.parent,
          children: updatedChildren,
        ),
      );

      print("DEBUG switchToChildSession: Switch completed");
    }
  }

  Student getStudentDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).student;
    }
    return Student.fromJson({});
  }

  Guardian getParentDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).parent;
    }
    return Guardian.fromJson({});
  }

  bool isParent() {
    if (state is Authenticated) {
      return !(state as Authenticated).isStudent;
    }
    return false;
  }

  void signOut() {
    authRepository.signOutUser();
    emit(Unauthenticated());
  }

  int getUserId() {
    if (state is Authenticated) {
      if ((state as Authenticated).isStudent) {
        return (state as Authenticated).student.id!;
      } else {
        return (state as Authenticated).parent.id!;
      }
    }
    throw Exception("User is not authenticated");
  }

  // Get list of children for parent
  List<Student> getChildren() {
    if (state is Authenticated) {
      return (state as Authenticated).children;
    }
    return [];
  }

  // Get current selected child
  Student getCurrentChild() {
    if (state is Authenticated) {
      return (state as Authenticated).student;
    }
    return Student.fromJson({});
  }

  /// Update data parent yang baru (hasil dari API update profil)
  void updateParentProfile(Guardian updated) {
    if (state is! Authenticated) return;
    final s = state as Authenticated;
    print("UBAH PROFILE PARENT DI AUTH CUBIT");
    // merge semua field: gunakan copyWith
    final merged = s.parent.copyWith(
      id: updated.id,
      firstName: updated.firstName,
      lastName: updated.lastName,
      mobile: updated.mobile,
      email: updated.email,
      gender: updated.gender,
      image: updated.image,
      dob: updated.dob,
      currentAddress: updated.currentAddress,
      permanentAddress: updated.permanentAddress,
      occupation: updated.occupation,
      status: updated.status,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
      fullName: updated.fullName,
    );

    // simpan ke storage juga biar persisten
    authRepository.setParentDetails(merged);

    // emit ulang state Authenticated
    emit(Authenticated(
      jwtToken: s.jwtToken,
      isStudent: s.isStudent,
      student: s.student,
      parent: merged,
      schoolCode: s.schoolCode,
      children: s.children,
    ));
  }

  /// Khusus update foto (cache-buster biar tidak ketahan cache lama)
  void updateParentImage(String newUrl) {
    if (state is! Authenticated) return;
    final s = state as Authenticated;

    final sep = newUrl.contains('?') ? '&' : '?';
    final busted = '$newUrl${sep}v=${DateTime.now().millisecondsSinceEpoch}';

    final merged = s.parent.copyWith(image: busted);

    authRepository.setParentDetails(merged);

    emit(Authenticated(
      jwtToken: s.jwtToken,
      isStudent: s.isStudent,
      student: s.student,
      parent: merged,
      schoolCode: s.schoolCode,
      children: s.children,
    ));
  }
}

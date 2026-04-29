import 'package:eschool/data/models/student/subjectAttendanceModel.dart';
import 'package:eschool/ui/widgets/academic/attendanceAttachmentButton.dart';
import 'package:eschool/ui/widgets/academic/attendanceInfoRow.dart';
import 'package:eschool/ui/widgets/academic/attendanceStatusBadge.dart';
import 'package:eschool/ui/widgets/academic/subjectImageContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

const Color _accentColor = Color(0xFFC62828);

/// Animated card for one [SubjectAttendance] entry in the daily list.
class SubjectAttendanceCard extends StatelessWidget {
  final SubjectAttendance attendance;
  final int index;

  const SubjectAttendanceCard({
    Key? key,
    required this.attendance,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timetable = attendance.subjectAttendance.timetable;
    final subject = timetable.subject;

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: Colors.white,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject image
                      Hero(
                        tag: 'subject_image_${subject.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SubjectImageContainer(
                              showShadow: false,
                              height: 75,
                              width: 75,
                              radius: 12,
                              subject: subject,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.getSubjectName(context: context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _accentColor,
                                    ),
                                  ),
                                ),
                                AttendanceStatusBadge(type: attendance.type),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AttendanceInfoRow(
                              Icons.access_time_rounded,
                              '${timetable.startTime} - ${timetable.endTime}',
                            ),
                            if (attendance.subjectAttendance.materi.isNotEmpty)
                              AttendanceInfoRow(
                                Icons.menu_book_rounded,
                                'Materi: ${attendance.subjectAttendance.materi}',
                                showDivider: true,
                              ),
                            if (attendance.note?.isNotEmpty ?? false)
                              AttendanceInfoRow(
                                Icons.notes_rounded,
                                'Catatan: ${attendance.note}',
                                isNote: true,
                                showDivider: true,
                              ),
                            if (attendance.subjectAttendance.lampiran
                                    ?.isNotEmpty ??
                                false)
                              AttendanceAttachmentButton(
                                attachmentUrl:
                                    attendance.subjectAttendance.lampiran!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

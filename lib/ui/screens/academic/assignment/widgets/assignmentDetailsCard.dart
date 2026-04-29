import 'package:eschool/data/models/academic/assignment.dart';
import 'package:eschool/ui/screens/academic/assignment/widgets/patternPainter.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AssignmentDetailsCard extends StatelessWidget {
  final Assignment assignment;
  final bool isSmallScreen;
  final bool hasPassed;
  final bool isToday;
  final bool assignmentSubmitted;
  final String submissionStatus;

  const AssignmentDetailsCard({
    Key? key,
    required this.assignment,
    required this.isSmallScreen,
    required this.hasPassed,
    required this.isToday,
    required this.assignmentSubmitted,
    required this.submissionStatus,
  }) : super(key: key);

  IconData _getStatusIcon() {
    String statusKey = Utils.getAssignmentSubmissionStatusKey(
      assignment.assignmentSubmission.status,
    );
    switch (statusKey) {
      case 'inReview':
        return Icons.hourglass_top_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'resubmitted':
        return Icons.refresh_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Widget _buildStatusBadge() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  assignmentSubmitted ? _getStatusIcon() : Icons.star_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 18 : 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignmentSubmitted
                            ? submissionStatus
                            : "${assignment.points} ${Utils.getTranslatedLabel(pointsKey)}",
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 11 : 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (assignmentSubmitted &&
                          assignment.assignmentSubmission.points > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          "${assignment.assignmentSubmission.points}/${assignment.points}",
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDueDateSection() {
    String assignmentStatusKey = Utils.getAssignmentSubmissionStatusKey(
      assignment.assignmentSubmission.status,
    );

    DateTime dueDate = assignment.dueDate;
    if ((assignmentStatusKey == rejectedKey &&
            assignment.resubmission == 1) ||
        assignmentStatusKey == resubmittedKey) {
      dueDate = assignment.dueDate
          .add(Duration(days: assignment.extraDaysForResubmission));
    }

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Batas Waktu",
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.1,
                ),
              ),
              if (hasPassed || isToday) ...[
                const Spacer(),
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, animValue, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * animValue),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 10,
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasPassed
                              ? Colors.red.withValues(alpha: 0.8)
                              : Colors.amber.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasPassed
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.amber.withValues(alpha: 0.5),
                            width: 1,
                          ),
                          boxShadow: hasPassed
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasPassed
                                  ? Icons.warning_rounded
                                  : Icons.today_rounded,
                              size: isSmallScreen ? 10 : 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasPassed ? "Terlambat" : "Hari Ini",
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 9 : 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(dueDate),
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: isSmallScreen ? 14 : 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat("HH:mm WIB").format(dueDate),
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: PatternPainter(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.name,
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                          maxLines: isSmallScreen ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 12,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                size: isSmallScreen ? 14 : 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  assignment.subject
                                      .getSubjectName(context: context),
                                  style: GoogleFonts.inter(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  _buildStatusBadge(),
                ],
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              _buildDueDateSection(),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:eschool/data/models/academic/assignment.dart';
import 'package:eschool/ui/widgets/academic/StudyMaterial_part2.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentSubmissionStatusCard extends StatelessWidget {
  final Assignment assignment;
  final bool isSmallScreen;
  final String submissionStatus;

  const AssignmentSubmissionStatusCard({
    Key? key,
    required this.assignment,
    required this.isSmallScreen,
    required this.submissionStatus,
  }) : super(key: key);

  final Color submissionColor = const Color(0xFFE97A43);
  final Color feedbackColor = const Color(0xFF6D4C41);
  final Color textColor = const Color(0xFF424242);
  final Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 20, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: submissionColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  submissionColor,
                  submissionColor.withValues(alpha: 0.8)
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                Expanded(
                  child: Text(
                    "Diserahkan",
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    submissionStatus,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assignment
                    .assignmentSubmission.submittedFiles.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslatedLabel(myWorkFileKey),
                          style: GoogleFonts.poppins(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16),
                          child: Column(
                            children: assignment
                                .assignmentSubmission.submittedFiles
                                .asMap()
                                .entries
                                .map(
                                  (entry) => TweenAnimationBuilder(
                                    duration: Duration(
                                        milliseconds:
                                            400 + (entry.key * 100)),
                                    tween: Tween<double>(begin: 0.9, end: 1.0),
                                    builder: (context, double scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: child,
                                      );
                                    },
                                    child:
                                        StudyMaterialWithDownloadButtonContainer2(
                                      boxConstraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context)
                                                .size
                                                .width *
                                            (isSmallScreen ? 0.8 : 0.7),
                                      ),
                                      studyMaterial: entry.value,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (assignment.assignmentSubmission.content.isNotEmpty)
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getTranslatedLabel(myWorkTextKey),
                          style: GoogleFonts.poppins(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16, vertical: 10),
                          child: Text(
                            assignment.assignmentSubmission.content,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (assignment.assignmentSubmission.feedback.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                              decoration: BoxDecoration(
                                color: feedbackColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.comment,
                                color: feedbackColor,
                                size: isSmallScreen ? 16 : 20,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: Text(
                                "Komentar Guru",
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: feedbackColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16, vertical: 10),
                          child: Text(
                            assignment.assignmentSubmission.feedback,
                            style: GoogleFonts.poppins(
                              fontStyle: FontStyle.italic,
                              color: textColor.withValues(alpha: 0.8),
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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

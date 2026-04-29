import 'package:eschool/data/models/academic/assignment.dart';
import 'package:eschool/ui/widgets/academic/StudyMaterial_part2.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentContentSection extends StatelessWidget {
  final Assignment assignment;
  final bool isSmallScreen;

  const AssignmentContentSection({
    Key? key,
    required this.assignment,
    required this.isSmallScreen,
  }) : super(key: key);

  final Color questionColor = const Color(0xFF6A3DE8);
  final Color materialColor = const Color(0xFF00B59C);
  final Color fileTypeColor = const Color(0xFF546E7A);
  final Color textColor = const Color(0xFF424242);

  IconData _getFileTypeIcon(String fileType) {
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('doc') || fileType.contains('txt')) {
      return Icons.description;
    }
    if (fileType.contains('xls')) return Icons.insert_chart;
    if (fileType.contains('jpg') ||
        fileType.contains('png') ||
        fileType.contains('jpeg')) {
      return Icons.image;
    }
    if (fileType.contains('zip') || fileType.contains('rar')) {
      return Icons.folder_zip;
    }
    if (fileType.contains('ppt')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assignment.instructions.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: questionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: questionColor.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: questionColor,
                          size: isSmallScreen ? 18 : 22,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 14),
                    Expanded(
                      child: Text(
                        Utils.getTranslatedLabel(instructionsKey),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: questionColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 20, vertical: 10),
                  child: Text(
                    assignment.instructions,
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
        if (assignment.referenceMaterials.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      decoration: BoxDecoration(
                        color: materialColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: materialColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.attach_file,
                        color: materialColor,
                        size: isSmallScreen ? 18 : 22,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 14),
                    Expanded(
                      child: Text(
                        Utils.getTranslatedLabel(referenceMaterialsKey),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: materialColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 20,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    child: GridView.count(
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      crossAxisSpacing: isSmallScreen ? 8 : 12,
                      mainAxisSpacing: isSmallScreen ? 8 : 12,
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      children: List.generate(
                        assignment.referenceMaterials.length,
                        (index) {
                          return TweenAnimationBuilder(
                            duration:
                                Duration(milliseconds: 400 + (index * 100)),
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            builder: (context, double scale, child) {
                              return Transform.scale(
                                  scale: scale, child: child);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: materialColor.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: materialColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child:
                                    StudyMaterialWithDownloadButtonContainer2(
                                  boxConstraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            (isSmallScreen ? 0.45 : 0.7),
                                  ),
                                  type: 3,
                                  studyMaterial:
                                      assignment.referenceMaterials[index],
                                  gallery: assignment.referenceMaterials,
                                  initialIndex: index,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (assignment.filetypes.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      decoration: BoxDecoration(
                        color: fileTypeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: fileTypeColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: fileTypeColor,
                        size: isSmallScreen ? 18 : 22,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 14),
                    Expanded(
                      child: Text(
                        'Format Berkas yang Diterima',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: fileTypeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 20, vertical: 10),
                  child: Wrap(
                    spacing: isSmallScreen ? 6 : 10,
                    runSpacing: isSmallScreen ? 6 : 10,
                    children:
                        assignment.filetypes.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String filetype = entry.value;
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (idx * 100)),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 14,
                              vertical: isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: fileTypeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: fileTypeColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFileTypeIcon(filetype.toLowerCase()),
                                size: isSmallScreen ? 12 : 16,
                                color: fileTypeColor,
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 6),
                              Text(
                                filetype,
                                style: GoogleFonts.poppins(
                                  color: fileTypeColor,
                                  fontSize: isSmallScreen ? 11 : 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

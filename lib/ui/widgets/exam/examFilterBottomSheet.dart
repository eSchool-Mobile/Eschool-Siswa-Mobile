import 'package:eschool/ui/widgets/exam/examFilterOptionTile.dart';
import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';

/// Shows the exam filter bottom sheet and returns the selected filter values
/// via [onApply].
///
/// Usage:
/// ```dart
/// ExamFilterBottomSheet.show(
///   context: context,
///   currentFilter: _selectedFilter,
///   currentFilterSiswa: _selectedFilterSiswa,
///   onApply: (filter, filterSiswa) {
///     setState(() {
///       _selectedFilter = filter;
///       _selectedFilterSiswa = filterSiswa;
///     });
///   },
///   isParent: context.read<AuthCubit>().isParent(),
/// );
/// ```
class ExamFilterBottomSheet {
  static void show({
    required BuildContext context,
    required String currentFilter,
    required String currentFilterSiswa,
    required bool isParent,
    required void Function(String filter, String filterSiswa) onApply,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempFilter = currentFilter;
        String tempFilterSiswa = currentFilterSiswa;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06,
                vertical: MediaQuery.of(context).size.height * 0.05,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Utils.bottomSheetTopRadius),
                  topRight: Radius.circular(Utils.bottomSheetTopRadius),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Exam time filter section ──────────────────────────
                  _SectionHeader(labelKey: filterUjianKey),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    children: [
                      ExamFilterOptionTile(
                        title: Utils.getTranslatedLabel(allKey),
                        filterValue: 'all',
                        isSelected: tempFilter == 'all',
                        onTap: () =>
                            setModalState(() => tempFilter = 'all'),
                      ),
                      ExamFilterOptionTile(
                        title: Utils.getTranslatedLabel(onGoingKey),
                        filterValue: 'ongoing',
                        isSelected: tempFilter == 'ongoing',
                        onTap: () =>
                            setModalState(() => tempFilter = 'ongoing'),
                      ),
                      ExamFilterOptionTile(
                        title: Utils.getTranslatedLabel(completedKey),
                        filterValue: 'completed',
                        isSelected: tempFilter == 'completed',
                        onTap: () =>
                            setModalState(() => tempFilter = 'completed'),
                      ),
                      ExamFilterOptionTile(
                        title: Utils.getTranslatedLabel(commingSoonKey),
                        filterValue: 'upcoming',
                        isSelected: tempFilter == 'upcoming',
                        onTap: () =>
                            setModalState(() => tempFilter = 'upcoming'),
                      ),
                    ],
                  ),

                  // ─── Student status filter section (hidden for parent) ──
                  if (!isParent) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(labelKey: filterUjianSiswaKey),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 3.5,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 5,
                      children: [
                        ExamFilterOptionTile(
                          title: Utils.getTranslatedLabel(allKey),
                          filterValue: 'all',
                          isSelected: tempFilterSiswa == 'all',
                          smallerFont: true,
                          onTap: () =>
                              setModalState(() => tempFilterSiswa = 'all'),
                        ),
                        ExamFilterOptionTile(
                          title: Utils.getTranslatedLabel(processExamKey),
                          filterValue: 'process',
                          isSelected: tempFilterSiswa == 'process',
                          smallerFont: true,
                          onTap: () =>
                              setModalState(() => tempFilterSiswa = 'process'),
                        ),
                        ExamFilterOptionTile(
                          title: Utils.getTranslatedLabel(doneExamKey),
                          filterValue: 'completed',
                          isSelected: tempFilterSiswa == 'completed',
                          smallerFont: true,
                          onTap: () => setModalState(
                              () => tempFilterSiswa = 'completed'),
                        ),
                        ExamFilterOptionTile(
                          title: Utils.getTranslatedLabel(notYetExamDoneKey),
                          filterValue: 'not_Yet',
                          isSelected: tempFilterSiswa == 'not_Yet',
                          smallerFont: true,
                          onTap: () =>
                              setModalState(() => tempFilterSiswa = 'not_Yet'),
                        ),
                      ],
                    ),
                  ],

                  // ─── Apply button ──────────────────────────────────────
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onApply(tempFilter, tempFilterSiswa);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Internal header row for a filter section inside the bottom sheet.
class _SectionHeader extends StatelessWidget {
  final String labelKey;
  const _SectionHeader({required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list_alt,
                size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              Utils.getTranslatedLabel(labelKey),
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

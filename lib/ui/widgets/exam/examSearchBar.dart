import 'package:eschool/utils/system/labelKeys.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';

/// Search bar + filter button row used at the top of the exam online list.
///
/// [onSearchChanged] fires with the lowercase query on every keystroke.
/// [onClearSearch] fires when the clear (×) button is tapped.
/// [onFilterTap] fires when the filter button is tapped.
class ExamSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterTap;
  final TextEditingController controller;

  const ExamSearchBar({
    Key? key,
    required this.controller,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  State<ExamSearchBar> createState() => _ExamSearchBarState();
}

class _ExamSearchBarState extends State<ExamSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 10.0),
      child: Row(
        children: [
          // ─── Search input ──────────────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(
                  color: primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: _isFocused ? 8 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search_rounded, color: primary, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: (value) =>
                          widget.onSearchChanged(value.toLowerCase()),
                      style: TextStyle(color: primary, fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: Utils.getTranslatedLabel(searchKey),
                        hintStyle: TextStyle(
                          color: primary.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  // Clear button
                  AnimatedOpacity(
                    opacity: widget.controller.text.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: widget.controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: widget.onClearSearch,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close,
                                    color: primary, size: 14),
                              ),
                            ),
                          )
                        : const SizedBox(width: 8),
                  ),
                ],
              ),
            ),
          ),

          // ─── Filter button ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(left: 5),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border.all(
                color: primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onFilterTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.filter_list_rounded,
                      color: primary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

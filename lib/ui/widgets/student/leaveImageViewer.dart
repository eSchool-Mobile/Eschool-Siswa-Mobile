import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/data/models/academic/studyMaterial.dart';
import 'package:eschool/data/models/student/leave.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Full-screen zoomable image viewer shown when the user taps a leave attachment.
/// Shows download and close buttons. Non-image attachments are dispatched to
/// [Utils.openDownloadBottomsheet] directly.
class LeaveImageViewer {
  /// Opens the full-screen viewer for [detail].
  /// If the attachment is not an image, opens the download sheet instead.
  static void show(BuildContext context, LeaveDetail detail) {
    final isImage = detail.fileExtension != null &&
        ['jpg', 'jpeg', 'png', 'gif']
            .contains(detail.fileExtension!.toLowerCase());

    if (isImage && detail.fileUrl != null) {
      _showFullScreen(context, detail);
    } else {
      _download(context, detail);
    }
  }

  static void _download(BuildContext context, LeaveDetail detail) {
    if (detail.fileUrl == null) return;
    Utils.openDownloadBottomsheet(
      context: context,
      storeInExternalStorage: true,
      studyMaterial: StudyMaterial(
        id: detail.id,
        fileName: detail.fileName ?? "file",
        fileUrl: detail.fileUrl ?? "",
        fileExtension: detail.fileExtension ?? "",
        fileThumbnail: "",
        studyMaterialType: StudyMaterialType.file,
      ),
    );
  }

  static void _showFullScreen(BuildContext context, LeaveDetail detail) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, _, __) {
          final url = detail.fileUrl ?? "";
          final isSvg = (detail.fileExtension?.toLowerCase() == 'svg');
          final controller = TransformationController();
          bool isZoomed = false;

          return StatefulBuilder(
            builder: (context, setState) {
              controller.addListener(() {
                final scale = controller.value.getMaxScaleOnAxis();
                final nowZoomed = scale > 1.5;
                if (nowZoomed != isZoomed) {
                  setState(() => isZoomed = nowZoomed);
                }
              });

              void snapBack() {
                final scale = controller.value.getMaxScaleOnAxis();
                if (scale <= 1.5) {
                  controller.value = Matrix4.identity();
                  if (isZoomed) setState(() => isZoomed = false);
                }
              }

              return Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Stack(
                    children: [
                      // Tap backdrop to close
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox.expand(),
                        ),
                      ),

                      // Zoomable image
                      LayoutBuilder(
                        builder: (context, constraints) => Center(
                          child: Hero(
                            tag: "leave_image_${detail.id}",
                            child: InteractiveViewer(
                              transformationController: controller,
                              panEnabled: isZoomed,
                              boundaryMargin: isZoomed
                                  ? const EdgeInsets.all(200)
                                  : EdgeInsets.zero,
                              clipBehavior: Clip.hardEdge,
                              minScale: 1.0,
                              maxScale: 4.0,
                              onInteractionEnd: (_) => snapBack(),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: isSvg
                                    ? SvgPicture.network(url,
                                        fit: BoxFit.contain)
                                    : CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.contain,
                                        placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.error,
                                                color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Top-right: download + close
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _CircleButton(
                              icon: Icons.download,
                              onTap: () => _download(context, detail),
                            ),
                            const SizedBox(width: 8),
                            _CircleButton(
                              icon: Icons.close,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),

                      // Bottom: page indicator
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "1/1",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

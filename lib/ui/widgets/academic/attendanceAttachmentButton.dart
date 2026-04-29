import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/data/models/academic/studyMaterial.dart';
import 'package:eschool/utils/system/utils.dart';
import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFFE53935);
const Color _lightColor = Color(0xFFFFEBEE);

const _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];

/// Button that opens an attachment — shows full-screen viewer for images,
/// triggers the download sheet for other file types.
class AttendanceAttachmentButton extends StatelessWidget {
  final String attachmentUrl;
  const AttendanceAttachmentButton({Key? key, required this.attachmentUrl})
      : super(key: key);

  bool get _isImage =>
      _imageExtensions.any((e) => attachmentUrl.toLowerCase().endsWith(e));

  void _handleTap(BuildContext context) {
    if (_isImage) {
      _showImageViewer(context, attachmentUrl);
    } else {
      Utils.openDownloadBottomsheet(
        context: context,
        storeInExternalStorage: true,
        studyMaterial: StudyMaterial(
          id: 0,
          fileName: Uri.parse(attachmentUrl).pathSegments.last,
          fileUrl: attachmentUrl,
          fileExtension: attachmentUrl.split('.').last,
          fileThumbnail: "",
          studyMaterialType: StudyMaterialType.file,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleTap(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _lightColor,
              border:
                  Border.all(color: _primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isImage
                      ? Icons.image_rounded
                      : Icons.attach_file_rounded,
                  size: 18,
                  color: _primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _isImage ? 'Lihat Lampiran' : 'Unduh Lampiran',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen interactive image viewer for attendance attachments.
void _showImageViewer(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, _, __) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {}, // prevent bubble-up close
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 2.5,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image,
                                  color: Colors.white, size: 64),
                              SizedBox(height: 16),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Label
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        'Lampiran',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

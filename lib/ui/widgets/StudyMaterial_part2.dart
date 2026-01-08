import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dotted_border/dotted_border.dart';

// Import sesuai struktur project kamu
import 'package:eschool/data/models/studyMaterial.dart';
import 'package:eschool/ui/widgets/downloadFileButton.dart';
import 'package:eschool/utils/utils.dart';

class StudyMaterialWithDownloadButtonContainer2 extends StatelessWidget {
  final BoxConstraints boxConstraints;
  final StudyMaterial studyMaterial;
  final int type;

  /// OPSIONAL: seluruh daftar materi (agar preview bisa di-swipe antar gambar)
  final List<StudyMaterial>? gallery;

  /// OPSIONAL: index saat ini dalam [gallery]
  final int? initialIndex;

  const StudyMaterialWithDownloadButtonContainer2({
    Key? key,
    required this.boxConstraints,
    required this.studyMaterial,
    this.type = 1,
    this.gallery,
    this.initialIndex,
  }) : super(key: key);

  bool _isImageName(String name) {
    final fileName = name.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.webp');
  }

  bool _isImage(StudyMaterial m) => _isImageName(m.fileName);

  IconData _getFileTypeIcon() {
    final fileName = studyMaterial.fileName.toLowerCase();
    if (_isImageName(fileName)) return Icons.image;
    if (fileName.endsWith('.mp4') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.mkv')) return Icons.video_file;
    if (fileName.endsWith('.mp3') ||
        fileName.endsWith('.wav') ||
        fileName.endsWith('.ogg')) return Icons.audio_file;
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx'))
      return Icons.description;
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx'))
      return Icons.table_chart;
    if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx'))
      return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  Future<File?> _downloadImageToCache(String url) async {
    if (url.isEmpty) return null;
    try {
      // Tambah headers jika backend butuh auth, contoh:
      // return await DefaultCacheManager().getSingleFile(
      //   url,
      //   headers: {'Authorization': 'Bearer ${Utils.authToken}'},
      // );
      return await DefaultCacheManager().getSingleFile(url);
    } catch (_) {
      return null;
    }
  }

  void _downloadFile(BuildContext context, StudyMaterial m) {
    Utils.openDownloadBottomsheet(
      context: context,
      storeInExternalStorage: false,
      studyMaterial: m,
    );
  }

  /// Buka preview fullscreen berisi seluruh gambar dari [gallery] (atau gambar tunggal)
  Future<void> _openImagePreview(BuildContext context) async {
    final List<StudyMaterial> candidates =
        (gallery ?? [studyMaterial]).where(_isImage).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar untuk dipratinjau')),
      );
      return;
    }

    int startIndex = 0;
    if (gallery != null) {
      if (initialIndex != null &&
          initialIndex! >= 0 &&
          initialIndex! < gallery!.length) {
        final current = gallery![initialIndex!];
        startIndex = candidates.indexWhere(
          (e) => e.fileUrl == current.fileUrl && e.fileName == current.fileName,
        );
        if (startIndex < 0) startIndex = 0;
      } else {
        startIndex = candidates.indexWhere(
          (e) =>
              e.fileUrl == studyMaterial.fileUrl &&
              e.fileName == studyMaterial.fileName,
        );
        if (startIndex < 0) startIndex = 0;
      }
    }

    // ignore: use_build_context_synchronously
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => ImagePreviewPage(
          items: candidates,
          startIndex: startIndex,
          onDownloadPressed: (current) => _downloadFile(context, current),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == 1) {
      // Tipe daftar baris (klik = download bottom sheet)
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: GestureDetector(
          onTap: () => _downloadFile(context, studyMaterial),
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: const [10, 10],
            radius: const Radius.circular(10.0),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  SizedBox(
                    width: boxConstraints.maxWidth * 0.7,
                    child: Text(
                      studyMaterial.fileName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  DownloadFileButton(studyMaterial: studyMaterial),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Kartu kecil dengan thumbnail jika gambar
    final isImage = _isImage(studyMaterial);
    final fileUrl = studyMaterial.fileUrl ?? "";

    return GestureDetector(
      onTap: isImage
          ? () => _openImagePreview(context) // gambar → preview
          : () =>
              _downloadFile(context, studyMaterial), // non-gambar → download
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: boxConstraints.maxWidth,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: type == 3
                ? const Color(0xFFFFFFFF)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FutureBuilder<File?>(
                    future: _downloadImageToCache(fileUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const AspectRatio(
                          aspectRatio: 1, // biar tetap kotak
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Icon(
                            Icons.broken_image,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        );
                      }
                      return Image.file(
                        snapshot.data!,
                        width: double.infinity,
                        fit: BoxFit.cover, // isi penuh parent
                      );
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    _getFileTypeIcon(),
                    size: 30,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
        ),
      ),
    );
  }
}

/// ======================
/// Preview fullscreen
/// ======================
class ImagePreviewPage extends StatefulWidget {
  /// Hanya item bergambar
  final List<StudyMaterial> items;
  final int startIndex;
  final void Function(StudyMaterial current) onDownloadPressed;

  const ImagePreviewPage({
    Key? key,
    required this.items,
    required this.startIndex,
    required this.onDownloadPressed,
  }) : super(key: key);

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController _pageController;
  late int _index;

  Future<File?> _cached(String url) async {
    if (url.isEmpty) return null;
    try {
      return await DefaultCacheManager().getSingleFile(url);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          children: [
            // GALERI SWIPE
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: total,
              itemBuilder: (context, i) {
                final item = widget.items[i];
                final url = item.fileUrl ?? "";

                return Center(
                  child: FutureBuilder<File?>(
                    future: _cached(url),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      if (snap.hasError || snap.data == null) {
                        return const Icon(Icons.broken_image,
                            color: Colors.white, size: 48);
                      }
                      return InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        panEnabled: true,
                        child: Image.file(snap.data!),
                      );
                    },
                  ),
                );
              },
            ),

            // ACTIONS: Download & Close (kanan atas)
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Download',
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () =>
                          widget.onDownloadPressed(widget.items[_index]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Tutup',
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),

            // Indikator index/total
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_index + 1} / $total',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

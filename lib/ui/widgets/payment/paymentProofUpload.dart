import 'dart:io';
import 'package:eschool/utils/system/errorMessageKeysAndCodes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaymentProofUpload extends StatefulWidget {
  final File? initialFile;
  final ValueChanged<File?> onFileSelected;

  const PaymentProofUpload({
    Key? key,
    this.initialFile,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  State<PaymentProofUpload> createState() => _PaymentProofUploadState();
}

class _PaymentProofUploadState extends State<PaymentProofUpload>
    with SingleTickerProviderStateMixin {
  late AnimationController _uploadController;
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
    _uploadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _uploadController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    try {
      setState(() {
        _uploadError = null;
        _isUploading = true;
      });

      _uploadController.forward();

      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (file != null) {
        final fileSize = await File(file.path).length();
        if (fileSize > 2 * 1024 * 1024) {
          setState(() {
            _uploadError = 'Ukuran file melebihi batas 2MB. Pilih file yang lebih kecil.';
            _isUploading = false;
          });
          _uploadController.reset();
          return;
        }

        final extension = file.path.toLowerCase().split('.').last;
        if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
          setState(() {
            _uploadError = 'Format file tidak valid. Pilih file JPG, JPEG, PNG, atau PDF.';
            _isUploading = false;
          });
          _uploadController.reset();
          return;
        }

        setState(() {
          _selectedFile = File(file.path);
          _isUploading = false;
        });
        widget.onFileSelected(_selectedFile);
      } else {
        setState(() {
          _isUploading = false;
        });
      }

      _uploadController.reset();
    } catch (e) {
      setState(() {
        _uploadError = 'Gagal memilih file: ' + ErrorMessageMapper.getUserFriendlyMessage(e);
        _isUploading = false;
      });
      _uploadController.reset();
    }
  }

  Future<void> _takePhoto() async {
    try {
      setState(() {
        _uploadError = null;
        _isUploading = true;
      });

      _uploadController.forward();

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (photo != null) {
        final fileSize = await File(photo.path).length();
        if (fileSize > 2 * 1024 * 1024) {
          setState(() {
            _uploadError = 'Ukuran foto melebihi batas 2MB. Coba ambil foto dengan kualitas lebih rendah.';
            _isUploading = false;
          });
          _uploadController.reset();
          return;
        }

        setState(() {
          _selectedFile = File(photo.path);
          _isUploading = false;
        });
        widget.onFileSelected(_selectedFile);
      } else {
        setState(() {
          _isUploading = false;
        });
      }

      _uploadController.reset();
    } catch (e) {
      setState(() {
        _uploadError = 'Gagal mengambil foto: ' + ErrorMessageMapper.getUserFriendlyMessage(e);
        _isUploading = false;
      });
      _uploadController.reset();
    }
  }

  void _showFileSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Pilih Bukti Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih cara untuk menambahkan bukti pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFileSourceOption(
                          icon: Icons.photo_library_outlined,
                          label: 'Galeri',
                          subtitle: 'JPG, PNG, PDF',
                          onTap: () {
                            Navigator.pop(context);
                            _pickDocument();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFileSourceOption(
                          icon: Icons.camera_alt_outlined,
                          label: 'Kamera',
                          subtitle: 'Ambil Foto',
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageFile() {
    if (_selectedFile == null) return false;
    final extension = _selectedFile!.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  IconData _getFileIcon() {
    if (_selectedFile == null) return Icons.description;

    final extension = _selectedFile!.path.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  String _getFileName() {
    if (_selectedFile == null) return '';
    return _selectedFile!.path.split('/').last;
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';
    final bytes = _selectedFile!.lengthSync();
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unggah Bukti Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      'Wajib • JPG, PNG, PDF • Maks 2MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedFile != null) ...[
            // Show selected file with image preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  // Image preview or file icon
                  if (_isImageFile()) ...[
                    // Preview gambar
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedFile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    // File icon untuk PDF
                    Icon(
                      _getFileIcon(),
                      size: 48,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    _getFileName(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFileSize(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showFileSourceDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Ganti File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _uploadError = null;
                      });
                      widget.onFileSelected(null);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red.shade400),
                      foregroundColor: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Upload button
            GestureDetector(
              onTap: _isUploading ? null : _showFileSourceDialog,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _uploadController,
                  builder: (context, child) {
                    if (_isUploading) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Memproses...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk unggah bukti pembayaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG, PDF (Maks 2MB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
          if (_uploadError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _uploadError!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

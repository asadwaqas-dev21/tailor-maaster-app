import "dart:io";

import "package:flutter/material.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:tailor_app/app/theme/app_colors.dart";
import "package:tailor_app/app/theme/app_typography.dart";

/// Compact 46×46 thumbs matching Darzi Naap Book mockup.
class PhotoPickerWidget extends StatelessWidget {
  final List<String> photoPaths;
  final void Function(String path) onPhotoAdded;
  final void Function(int index) onPhotoRemoved;
  final int maxPhotos;

  const PhotoPickerWidget({
    super.key,
    required this.photoPaths,
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
    this.maxPhotos = 5,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image != null) onPhotoAdded(image.path);
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera, color: AppColors.pine),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery, color: AppColors.pine),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _labels = ["design", "gala", "photo"];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        ...photoPaths.asMap().entries.map((entry) {
          final label = entry.key < _labels.length
              ? _labels[entry.key]
              : "photo";
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(entry.value)),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.ui(size: 8, color: Colors.white),
                  ),
                ),
              ),
              PositionedDirectional(
                top: -4,
                end: -4,
                child: GestureDetector(
                  onTap: () => onPhotoRemoved(entry.key),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.crimson,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (photoPaths.length < maxPhotos)
          GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.paperPanel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.line,
                  width: 1.5,
                ),
                // dashed look approximated with muted fill
              ),
              child: const Center(
                child: Icon(Icons.add, size: 18, color: AppColors.muted),
              ),
            ),
          ),
      ],
    );
  }
}

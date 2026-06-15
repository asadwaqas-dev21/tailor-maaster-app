import "dart:io";

import "package:flutter/material.dart";
import "package:iconsax_flutter/iconsax_flutter.dart";
import "package:image_picker/image_picker.dart";

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
    if (image != null) {
      onPhotoAdded(image.path);
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Photos", style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (photoPaths.length < maxPhotos)
                GestureDetector(
                  onTap: () => _showPickerOptions(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Iconsax.add_circle,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ...photoPaths.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(entry.value)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => onPhotoRemoved(entry.key),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

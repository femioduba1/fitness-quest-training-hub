import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/crud/progress_photo_crud.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  State<ProgressPhotosScreen> createState() =>
      _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState
    extends State<ProgressPhotosScreen> {
  final ProgressPhotoCrud _photoCrud = ProgressPhotoCrud();
  final ImagePicker _picker = ImagePicker();

  Map<String, List<Map<String, dynamic>>> _photosByMonth = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    try {
      final grouped = await _photoCrud.getPhotosByMonth();
      if (!mounted) return;
      setState(() {
        _photosByMonth = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Show source picker bottom sheet
  Future<void> _addPhoto() async {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkDivider
                      : AppTheme.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ADD PROGRESS PHOTO',
                style: TextStyle(
                  color: AppTheme.orange,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              // Camera option
              _SourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                sublabel: 'Use your camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              // Gallery option
              _SourceOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                sublabel: 'Pick an existing photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (image == null) return;

      // Show caption dialog
      if (mounted) {
        await _showCaptionDialog(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Caption dialog before saving
  Future<void> _showCaptionDialog(String photoPath) async {
    final controller = TextEditingController();
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.darkCard : AppTheme.lightCard,
        title: Text(
          'Add Caption',
          style: TextStyle(
            color: isDark
                ? AppTheme.darkTextPrimary
                : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photoPath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Week 4 check-in',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
                prefixIcon: const Icon(Icons.edit,
                    color: AppTheme.orange),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _photoCrud.insertPhoto({
                'photo_path': photoPath,
                'caption': controller.text.trim(),
              });
              if (mounted) {
                Navigator.pop(context);
                _loadPhotos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress photo saved! 📸'),
                    backgroundColor: AppTheme.orange,
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  // Delete photo with confirmation
  Future<void> _deletePhoto(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
            'Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _photoCrud.deletePhoto(id);
      _loadPhotos();
    }
  }

  // Full screen photo viewer
  void _viewPhoto(
      String photoPath, String? caption, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenPhoto(
          photoPath: photoPath,
          caption: caption,
          onDelete: () {
            Navigator.pop(context);
            _deletePhoto(id);
          },
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor =
        isDark ? AppTheme.darkDivider : AppTheme.lightDivider;
    final primaryText = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final secondaryText = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final bgColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROGRESS PHOTOS'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () =>
              menuKey.currentState?.toggleMenu(),
        ),
        actions: [
          // Add photo button
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded),
            onPressed: _addPhoto,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.orange))
          : RefreshIndicator(
              color: AppTheme.orange,
              backgroundColor: cardColor,
              displacement: 80,
              strokeWidth: 3,
              onRefresh: _loadPhotos,
              child: _photosByMonth.isEmpty
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height *
                                  0.7,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.orange
                                      .withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppTheme.orange,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'NO PHOTOS YET',
                                style: TextStyle(
                                  color: primaryText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the camera icon to add\nyour first progress photo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton.icon(
                                onPressed: _addPhoto,
                                icon: const Icon(
                                    Icons.add_a_photo_rounded),
                                label: const Text(
                                    'ADD FIRST PHOTO'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [

                        // ── STATS BANNER ──────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.orange,
                                AppTheme.orangeDark
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons.photo_library_rounded,
                                  color: Colors.white,
                                  size: 28),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_photosByMonth.values.fold(0, (a, b) => a + b.length)} PHOTOS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${_photosByMonth.keys.length} months tracked',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── TIMELINE ──────────────────
                        ..._photosByMonth.entries.map(
                            (entry) {
                          final month = entry.key;
                          final photos = entry.value;

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Month header
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                        bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration:
                                          BoxDecoration(
                                        color: AppTheme.orange,
                                        borderRadius:
                                            BorderRadius
                                                .circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      month.toUpperCase(),
                                      style: TextStyle(
                                        color: primaryText,
                                        fontWeight:
                                            FontWeight.w800,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${photos.length} photo${photos.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Photos in this month
                              ...photos.map((photo) {
                                final file =
                                    File(photo['photo_path']);
                                final exists = file.existsSync();

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                          bottom: 12),
                                  child: GestureDetector(
                                    onTap: exists
                                        ? () => _viewPhoto(
                                              photo['photo_path'],
                                              photo['caption'],
                                              photo['id'],
                                            )
                                        : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius:
                                            BorderRadius
                                                .circular(16),
                                        border: Border.all(
                                            color: borderColor),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          // Photo
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius
                                                    .vertical(
                                              top: Radius
                                                  .circular(16),
                                            ),
                                            child: exists
                                                ? Image.file(
                                                    file,
                                                    width: double
                                                        .infinity,
                                                    height: 220,
                                                    fit: BoxFit
                                                        .cover,
                                                  )
                                                : Container(
                                                    width: double
                                                        .infinity,
                                                    height: 220,
                                                    color: isDark
                                                        ? AppTheme
                                                            .darkCardLight
                                                        : AppTheme
                                                            .lightCardLight,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .broken_image_rounded,
                                                            color:
                                                                secondaryText,
                                                            size:
                                                                36),
                                                        const SizedBox(
                                                            height:
                                                                8),
                                                        Text(
                                                            'Photo not found',
                                                            style: TextStyle(
                                                                color:
                                                                    secondaryText)),
                                                      ],
                                                    ),
                                                  ),
                                          ),

                                          // Info row
                                          Padding(
                                            padding:
                                                const EdgeInsets
                                                    .all(14),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (photo['caption'] !=
                                                              null &&
                                                          photo['caption']
                                                              .toString()
                                                              .isNotEmpty)
                                                        Text(
                                                          photo[
                                                              'caption'],
                                                          style: TextStyle(
                                                              color:
                                                                  primaryText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  15),
                                                        ),
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        _formatDate(
                                                            photo[
                                                                'taken_at']),
                                                        style: TextStyle(
                                                            color:
                                                                secondaryText,
                                                            fontSize:
                                                                12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Delete button
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color: Colors
                                                          .red),
                                                  onPressed: () =>
                                                      _deletePhoto(
                                                          photo[
                                                              'id']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 8),
                            ],
                          );
                        }),

                        const SizedBox(height: 24),
                      ],
                    ),
            ),

      // FAB to add photo
      floatingActionButton: _photosByMonth.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.orange,
              onPressed: _addPhoto,
              child: const Icon(Icons.add_a_photo_rounded,
                  color: Colors.white),
            ),
    );
  }
}

// Source option tile
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.darkCardLight
              : AppTheme.lightCardLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.orange),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Full screen photo viewer
class _FullScreenPhoto extends StatelessWidget {
  final String photoPath;
  final String? caption;
  final VoidCallback onDelete;

  const _FullScreenPhoto({
    required this.photoPath,
    required this.caption,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          caption ?? 'Progress Photo',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(photoPath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
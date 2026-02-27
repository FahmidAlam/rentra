import 'package:flutter/material.dart';
import 'package:rentra/Application/property_image_controller.dart';
import 'package:rentra/Data/datasources/property_image_remote_datasource.dart';
import 'package:rentra/core/models/property.dart';
import 'package:rentra/core/models/property_image.dart';
import 'package:rentra/core/theme/app_theme.dart';
import 'package:rentra/UI/widgets/reusable_widgets.dart';

class PropertyImageManagementScreen extends StatefulWidget {
  final Property property;

  const PropertyImageManagementScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyImageManagementScreen> createState() =>
      _PropertyImageManagementScreenState();
}

class _PropertyImageManagementScreenState
    extends State<PropertyImageManagementScreen> {
  late final PropertyImageController _controller;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _controller = PropertyImageController(PropertyImageRemoteDataSource());
    _controller.loadImages(widget.property.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Property Images')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (_, __) {
          if (_controller.isLoading && _controller.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                _buildTopActions(),

                if (_controller.images.isEmpty)
                  const RentraEmptyState(
                    icon: Icons.image_not_supported,
                    title: 'No images yet',
                    subtitle: 'Upload images to showcase your property',
                  ),

                if (_controller.images.isNotEmpty)
                  _isReordering
                      ? _buildReorderableList()
                      : _buildNormalList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────── TOP ACTIONS ─────────────────────────────

  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RentraPrimaryButton(
            label: 'Upload New Image',
            icon: Icons.cloud_upload,
            isLoading: _controller.isLoading,
            onPressed: _showUploadDialog,
          ),
          const VSpace(12),
          if (_controller.images.isNotEmpty)
            RentraSecondaryButton(
              label: _isReordering ? 'Done Reordering' : 'Reorder Images',
              icon:
                  _isReordering ? Icons.check : Icons.drag_indicator_outlined,
              color: RentraColors.darkTeal,
              onPressed: _toggleReorderMode,
            ),
        ],
      ),
    );
  }

  // ───────────────────────────── NORMAL LIST VIEW ─────────────────────────────

  Widget _buildNormalList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          _controller.images.length,
          (i) => _buildImageCard(_controller.images[i], i),
        ),
      ),
    );
  }

  // ─────────────────────────── REORDERABLE LIST VIEW ──────────────────────────

  Widget _buildReorderableList() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _controller.images.removeAt(oldIndex);
          _controller.images.insert(newIndex, item);
        });
      },
      children: List.generate(
        _controller.images.length,
        (i) => _buildReorderableCard(_controller.images[i], i),
      ),
    );
  }

  // ───────────────────────────── IMAGE CARD ──────────────────────────

  Widget _buildImageCard(PropertyImage image, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: RentraColors.background,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const VSpace(12),
            Row(
              children: [
                Chip(
                  label: Text(
                    'Image ${index + 1}',
                    style: const TextStyle(color: RentraColors.darkTeal),
                  ),
                  backgroundColor:
                      RentraColors.darkTeal.withOpacity(0.1),
                ),
                const HSpace(12),
                Expanded(
                  child: Text(
                    image.caption.isEmpty ? 'No caption' : image.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const VSpace(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditCaptionDialog(image),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const HSpace(8),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(image.id),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: RentraColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── REORDERABLE CARD ─────────────────────────────

  Widget _buildReorderableCard(PropertyImage image, int index) {
    return Card(
      key: ValueKey(image.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_indicator),
        ),
        title: Text('Image ${index + 1}'),
        subtitle: Text(
          image.caption.isEmpty ? 'No caption' : image.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ────────────────────────────────── DIALOGS ─────────────────────────────────

  void _showUploadDialog() {
    final url = TextEditingController();
    final caption = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upload New Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: url, decoration: const InputDecoration(labelText: 'Image URL')),
            const VSpace(12),
            TextField(controller: caption, maxLength: 50, decoration: const InputDecoration(labelText: 'Caption')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (url.text.isEmpty) return;

              final ok = await _controller.uploadImage(
                imageUrl: url.text,
                caption: caption.text,
              );

              if (!mounted) return;
              Navigator.pop(context);

              _showSnack(ok, ok ? 'Image uploaded successfully' : _controller.errorMessage ?? 'Upload failed');
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showEditCaptionDialog(PropertyImage image) {
    final c = TextEditingController(text: image.caption);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Caption'),
        content: TextField(controller: c, maxLength: 50),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final ok = await _controller.updateCaption(image.id, c.text);
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack(ok, ok ? 'Caption updated' : _controller.errorMessage ?? 'Update failed');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RentraColors.error),
            onPressed: () async {
              final ok = await _controller.deleteImage(id);
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack(ok, ok ? 'Image deleted' : _controller.errorMessage ?? 'Delete failed');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────── HELPERS ──────────────────────────────────

  void _toggleReorderMode() async {
    if (_isReordering) {
      final ok = await _controller.reorderImages(_controller.images);
      if (!mounted) return;
      _showSnack(ok, ok ? 'Images reordered successfully' : _controller.errorMessage ?? 'Reorder failed');
    }
    setState(() => _isReordering = !_isReordering);
  }

  void _showSnack(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? RentraColors.success : RentraColors.error,
      ),
    );
  }
}

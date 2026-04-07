import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../../events/presentation/screens/event_form_screen.dart';
import '../../../settings/presentation/providers/theme_mode_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../data/openai_event_draft_service.dart';
import '../providers/smart_add_provider.dart';

class SmartAddScreen extends ConsumerStatefulWidget {
  const SmartAddScreen({super.key});

  @override
  ConsumerState<SmartAddScreen> createState() => _SmartAddScreenState();
}

class _SmartAddScreenState extends ConsumerState<SmartAddScreen> {
  late final TextEditingController _sourceController;
  final image_picker.ImagePicker _imagePicker = image_picker.ImagePicker();
  bool _isCreatingDraft = false;
  XFile? _selectedImage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(openAiApiKeyProvider);
    final model = ref.watch(openAiModelProvider);
    final hasApiKey = apiKey != null && apiKey.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Add')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turn anything into a draft event',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Paste a message, itinerary, booking details, event poster text, class reminder, or choose a photo to scan. AI will suggest event details, and you will review everything before saving.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!hasApiKey) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OpenAI key needed',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your API key in Settings to use Smart Add. The key is stored locally on this device for your personal app setup.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: _openSettings,
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isCreatingDraft ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose Image'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _isCreatingDraft ? null : _captureFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take Photo'),
                ),
                if (_selectedImage != null)
                  TextButton(
                    onPressed: _isCreatingDraft
                        ? null
                        : () => setState(() => _selectedImage = null),
                    child: const Text('Remove Image'),
                  ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _SelectedImagePreview(image: _selectedImage!),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedImage!.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceController,
              minLines: 5,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Optional details or pasted text',
                alignLabelWithHint: true,
                hintText:
                    'Add any details you want Smart Add to use when creating the draft.\n\nIf you attached an image, this box is optional. Use it to clarify anything the image might not show clearly, such as:\n- who the ticket or event is for\n- the full venue or location name\n- a note you want saved with the event\n- missing date, time, or title details from a blurry or cropped image\n\nIf you did not attach an image, you can paste event information here from messages, itineraries, booking confirmations, posters, reminders, or notes.\n\nExamples:\n\nDinner with Bea next Friday at 7 PM, The Fat Seed BGC\n\nFlight to Tokyo on Nov 12 2026, NAIA Terminal 3, depart 6:45 AM\n\nMom birthday April 18\n\nThis ticket is for my sister. Save the note: meet at the lobby 30 minutes early.',
              ),
            ),
            const SizedBox(height: 12),
            Text('Model: $model', style: Theme.of(context).textTheme.bodySmall),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isCreatingDraft ? null : _createDraft,
              icon: _isCreatingDraft
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(
                _isCreatingDraft ? 'Creating Draft...' : 'Create Draft',
              ),
            ),
            if (_isCreatingDraft) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Analyzing your input and preparing the draft...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _createDraft() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isCreatingDraft = true;
      _errorMessage = null;
    });

    try {
      SmartAddImageInput? imageInput;
      final selectedImage = _selectedImage;
      if (selectedImage != null) {
        imageInput = SmartAddImageInput(
          bytes: await selectedImage.readAsBytes(),
          mimeType: _inferMimeType(selectedImage),
        );
      }

      final draft = await ref
          .read(smartAddServiceProvider)
          .createDraft(sourceText: _sourceController.text, image: imageInput);

      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EventFormScreen(initialDraft: draft)),
      );
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingDraft = false);
      }
    }
  }

  Future<void> _openSettings() {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = _useDesktopFileSelector
          ? await openFile(acceptedTypeGroups: const [_imageTypeGroup])
          : await _imagePicker.pickImage(
              source: image_picker.ImageSource.gallery,
            );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null;
        });
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _captureFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: image_picker.ImageSource.camera,
      );
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null;
        });
      }
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _inferMimeType(XFile file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.webp')) {
      return 'image/webp';
    }
    if (path.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  bool get _useDesktopFileSelector =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
}

const XTypeGroup _imageTypeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'],
);

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({required this.image});

  final XFile image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _ImagePreviewFallback(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ImagePreviewFallback(
                color: Theme.of(context).colorScheme.surfaceContainer,
              );
            }

            return ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImagePreviewFallback extends StatelessWidget {
  const _ImagePreviewFallback({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(child: Icon(Icons.image_outlined)),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/theme_mode_provider.dart';
import '../../data/openai_event_draft_service.dart';

final smartAddServiceProvider = Provider<OpenAiEventDraftService>((ref) {
  final apiKey = ref.watch(openAiApiKeyProvider);
  final model = ref.watch(openAiModelProvider);
  return OpenAiEventDraftService(apiKey: apiKey, model: model);
});

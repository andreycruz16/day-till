import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../events/domain/entities/reminder_option.dart';
import '../../events/domain/entities/event_type.dart';
import '../domain/entities/event_draft.dart';

class SmartAddImageInput {
  const SmartAddImageInput({required this.bytes, required this.mimeType});

  final List<int> bytes;
  final String mimeType;
}

class OpenAiEventDraftException implements Exception {
  const OpenAiEventDraftException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenAiEventDraftService {
  OpenAiEventDraftService({
    required this.apiKey,
    required this.model,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String? apiKey;
  final String model;
  final http.Client _httpClient;

  Future<EventDraft> createDraft({
    String? sourceText,
    SmartAddImageInput? image,
  }) async {
    final trimmedSource = sourceText?.trim() ?? '';
    if (trimmedSource.isEmpty && image == null) {
      throw const OpenAiEventDraftException(
        'Add some text or choose an image to create a draft.',
      );
    }

    final token = apiKey?.trim();
    if (token == null || token.isEmpty) {
      throw const OpenAiEventDraftException(
        'Add your OpenAI API key in Settings before using Smart Add.',
      );
    }

    late final Map<String, dynamic> decoded;
    try {
      final response = await _httpClient.post(
        Uri.parse('https://api.openai.com/v1/responses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          _requestBody(
            sourceText: trimmedSource,
            image: image,
            now: DateTime.now(),
          ),
        ),
      );
      final responseBody = response.body;
      decoded = responseBody.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded['error'];
        final message = error is Map<String, dynamic>
            ? error['message'] as String?
            : null;
        throw OpenAiEventDraftException(
          message ?? 'OpenAI could not create a draft right now.',
        );
      }
    } on http.ClientException catch (error) {
      throw OpenAiEventDraftException(
        _networkErrorMessage(error),
      );
    } on FormatException {
      throw const OpenAiEventDraftException(
        'Smart Add received an invalid response while creating the draft.',
      );
    }

    final outputText = _extractOutputText(decoded);
    if (outputText == null || outputText.isEmpty) {
      throw const OpenAiEventDraftException(
        'Smart Add did not return a usable draft.',
      );
    }

    final payload = jsonDecode(outputText) as Map<String, dynamic>;
    if (image != null) {
      return _eventDraftFromImagePayload(
        payload: payload,
        sourceText: trimmedSource,
      );
    }

    return _eventDraftFromTextPayload(
      payload: payload,
      sourceText: trimmedSource,
    );
  }

  EventDraft _eventDraftFromTextPayload({
    required Map<String, dynamic> payload,
    required String sourceText,
  }) {
    final title = (payload['title'] as String? ?? '').trim();
    final dateIso = (payload['date_iso'] as String? ?? '').trim();
    if (title.isEmpty || dateIso.isEmpty) {
      throw const OpenAiEventDraftException(
        'Smart Add could not confidently detect a title and date.',
      );
    }

    final notes = (payload['notes'] as String?)?.trim();
    final eventType = payload['event_type'] as String? ?? 'general';
    final notificationsEnabled =
        payload['notifications_enabled'] as bool? ?? false;
    final reminder = notificationsEnabled
        ? _reminderOptionFromPayload(payload['reminder_option'] as String?)
        : ReminderOption.none;
    final reminderTime = notificationsEnabled
        ? _parseReminderTime(payload['reminder_time_24h'] as String?)
        : null;
    final warnings = (payload['warnings'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map((warning) => warning.trim())
        .where((warning) => warning.isNotEmpty)
        .toList();

    return EventDraft(
      title: title,
      date: DateTime.parse(dateIso),
      type: eventType == 'birthday' ? EventType.birthday : EventType.general,
      isDateYearKnown: payload['is_date_year_known'] as bool? ?? true,
      sourceText: sourceText,
      notificationsEnabled: notificationsEnabled,
      reminder: reminder,
      reminderHour: reminderTime?.hour,
      reminderMinute: reminderTime?.minute,
      notes: notes == null || notes.isEmpty ? null : notes,
      warnings: warnings,
    );
  }

  EventDraft _eventDraftFromImagePayload({
    required Map<String, dynamic> payload,
    required String sourceText,
  }) {
    final eventName = (payload['eventName'] as String?)?.trim();
    final dateIso = (payload['date'] as String?)?.trim();
    if (eventName == null ||
        eventName.isEmpty ||
        dateIso == null ||
        dateIso.isEmpty) {
      throw const OpenAiEventDraftException(
        'Smart Add could not confidently detect an event name and date from the image.',
      );
    }

    final details = <String?>[
      _labeledValue('Time', payload['time'] as String?),
      _labeledValue('Venue', payload['venue'] as String?),
      _labeledValue('Location', payload['location'] as String?),
      _labeledValue('Section', payload['section'] as String?),
      _labeledValue('Row', payload['row'] as String?),
      _labeledValue('Seat', payload['seat'] as String?),
      _labeledValue('Ticket #', payload['ticketNumber'] as String?),
    ].whereType<String>().toList();

    final warnings = <String>[];
    final confidence = payload['confidence'];
    if (confidence is Map<String, dynamic>) {
      final eventConfidence = _asConfidence(confidence['eventName']);
      final dateConfidence = _asConfidence(confidence['date']);
      final timeConfidence = _asConfidence(confidence['time']);
      final locationConfidence = _asConfidence(confidence['location']);

      if (eventConfidence != null && eventConfidence < 0.6) {
        warnings.add('Event name was extracted with low confidence.');
      }
      if (dateConfidence != null && dateConfidence < 0.6) {
        warnings.add('Date was extracted with low confidence.');
      }
      if (timeConfidence != null && timeConfidence < 0.6) {
        warnings.add('Time was extracted with low confidence.');
      }
      if (locationConfidence != null && locationConfidence < 0.6) {
        warnings.add('Location was extracted with low confidence.');
      }
    }

    final eventType = (payload['eventType'] as String?)?.trim().toLowerCase();
    return EventDraft(
      title: eventName,
      date: DateTime.parse(dateIso),
      type: eventType == 'birthday' ? EventType.birthday : EventType.general,
      isDateYearKnown: true,
      sourceText: sourceText,
      notificationsEnabled: false,
      reminder: ReminderOption.none,
      reminderHour: null,
      reminderMinute: null,
      notes: details.isEmpty ? null : details.join('\n'),
      warnings: warnings,
    );
  }

  Map<String, dynamic> _requestBody({
    required String sourceText,
    required SmartAddImageInput? image,
    required DateTime now,
  }) {
    if (image != null) {
      return _imageRequestBody(image: image);
    }

    return _textRequestBody(sourceText: sourceText, now: now);
  }

  Map<String, dynamic> _textRequestBody({
    required String sourceText,
    required DateTime now,
  }) {
    final todayIso = _dateOnly(now).toIso8601String().split('T').first;

    return {
      'model': model,
      'input': [
        {
          'role': 'system',
          'content': [
            {
              'type': 'input_text',
              'text':
                  '''
You extract event information from arbitrary user content and turn it into a clean event draft.

Today is $todayIso.

Rules:
- Return valid JSON only.
- Extract the single most likely event the user wants to track.
- Use "birthday" when the content clearly refers to a birthday or birth date for a person or pet, such as "my cat's birthday", "dad's birthday", or "our dog's birth date".
- Otherwise use "general".
- Always provide date_iso in YYYY-MM-DD format.
- For birthdays with no year, set is_date_year_known to false and use 2000 as the placeholder year in date_iso.
- For non-birthday events with no year, infer the next upcoming date on or after today and mention that assumption in warnings.
- Keep title concise and user-friendly.
- Do not include explicit dates or years in title unless the event itself is a multi-day or date-range title where the date is essential to distinguish it.
- Put supporting details, times, venues, booking codes, and extra context into notes.
- Set notifications_enabled to true only if the user explicitly asks for a reminder, alert, or notification. Do not enable reminders by default.
- If notifications_enabled is true, set reminder_option to the closest supported value: same_day, one_day_before, three_days_before, one_week_before, two_weeks_before, or one_month_before.
- If notifications_enabled is true and the user specifies a reminder time, return it in reminder_time_24h using HH:mm 24-hour format.
- If notifications_enabled is true and the user does not specify a reminder time, return reminder_time_24h as null.
- If the user asks for reminders but timing is ambiguous, enable reminders and default reminder_option to same_day. Mention only the reminder_option assumption in warnings.
- If reminders were not requested, set notifications_enabled to false and reminder_option to none.
- Add warnings for ambiguity, missing year inference, or low confidence.
''',
            },
          ],
        },
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': sourceText},
          ],
        },
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'event_draft',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'properties': {
              'title': {'type': 'string'},
              'date_iso': {'type': 'string'},
              'event_type': {
                'type': 'string',
                'enum': ['birthday', 'general'],
              },
              'is_date_year_known': {'type': 'boolean'},
              'notifications_enabled': {'type': 'boolean'},
              'reminder_option': {
                'type': 'string',
                'enum': [
                  'none',
                  'same_day',
                  'one_day_before',
                  'three_days_before',
                  'one_week_before',
                  'two_weeks_before',
                  'one_month_before',
                ],
              },
              'reminder_time_24h': {
                'type': ['string', 'null'],
              },
              'notes': {'type': 'string'},
              'warnings': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
            'required': [
              'title',
              'date_iso',
              'event_type',
              'is_date_year_known',
              'notifications_enabled',
              'reminder_option',
              'reminder_time_24h',
              'notes',
              'warnings',
            ],
          },
        },
      },
    };
  }

  Map<String, dynamic> _imageRequestBody({required SmartAddImageInput image}) {
    final base64Image = base64Encode(image.bytes);
    return {
      'model': model,
      'input': [
        {
          'role': 'system',
          'content': [
            {
              'type': 'input_text',
              'text':
                  '''
You are an OCR + event data extraction AI.

Your task is to analyze an image of a ticket, pass, or event document and extract structured event information.

Return ONLY valid JSON. Do not include explanations, comments, or extra text.

If a field is missing or unclear, return null.

Rules:
- Extract only what is explicitly visible in the image.
- Do not guess missing values.
- Normalize date and time into the required formats.
- Remove unnecessary words like "LIVE", "Admission", "Gate opens", etc.
- Prefer the main event title over organizer names.
- If multiple dates/times exist, choose the main event schedule.
- If the image is not a ticket or event, return all fields as null.
''',
            },
          ],
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_image',
              'image_url': 'data:${image.mimeType};base64,$base64Image',
              'detail': 'auto',
            },
          ],
        },
      ],
      'text': {
        'format': {
          'type': 'json_schema',
          'name': 'ticket_event_extraction',
          'strict': true,
          'schema': {
            'type': 'object',
            'additionalProperties': false,
            'properties': {
              'eventName': {
                'type': ['string', 'null'],
              },
              'date': {
                'type': ['string', 'null'],
              },
              'time': {
                'type': ['string', 'null'],
              },
              'location': {
                'type': ['string', 'null'],
              },
              'venue': {
                'type': ['string', 'null'],
              },
              'seat': {
                'type': ['string', 'null'],
              },
              'section': {
                'type': ['string', 'null'],
              },
              'row': {
                'type': ['string', 'null'],
              },
              'ticketNumber': {
                'type': ['string', 'null'],
              },
              'eventType': {
                'type': ['string', 'null'],
              },
              'confidence': {
                'type': 'object',
                'additionalProperties': false,
                'properties': {
                  'eventName': {'type': 'number'},
                  'date': {'type': 'number'},
                  'time': {'type': 'number'},
                  'location': {'type': 'number'},
                },
                'required': ['eventName', 'date', 'time', 'location'],
              },
            },
            'required': [
              'eventName',
              'date',
              'time',
              'location',
              'venue',
              'seat',
              'section',
              'row',
              'ticketNumber',
              'eventType',
              'confidence',
            ],
          },
        },
      },
    };
  }

  String? _extractOutputText(Map<String, dynamic> body) {
    final direct = body['output_text'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final output = body['output'];
    if (output is! List<dynamic>) {
      return null;
    }

    for (final item in output.whereType<Map<String, dynamic>>()) {
      final content = item['content'];
      if (content is! List<dynamic>) {
        continue;
      }
      for (final part in content.whereType<Map<String, dynamic>>()) {
        final text = part['text'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
      }
    }

    return null;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String? _labeledValue(String label, String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return '$label: $trimmed';
  }

  double? _asConfidence(Object? value) {
    if (value is num) {
      final normalized = value.toDouble();
      if (normalized < 0) {
        return 0;
      }
      if (normalized > 1) {
        return 1;
      }
      return normalized;
    }
    return null;
  }

  ReminderOption _reminderOptionFromPayload(String? value) {
    return switch (value) {
      'same_day' => ReminderOption.sameDay,
      'one_day_before' => ReminderOption.oneDayBefore,
      'three_days_before' => ReminderOption.threeDaysBefore,
      'one_week_before' => ReminderOption.oneWeekBefore,
      'two_weeks_before' => ReminderOption.twoWeeksBefore,
      'one_month_before' => ReminderOption.oneMonthBefore,
      _ => ReminderOption.none,
    };
  }

  _ReminderTime? _parseReminderTime(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(trimmed);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return _ReminderTime(hour: hour, minute: minute);
  }

  String _networkErrorMessage(http.ClientException error) {
    final message = error.message.toLowerCase();
    if (message.contains('failed host lookup') ||
        message.contains('no address associated with hostname')) {
      return 'Could not reach OpenAI. Check that your Android device or emulator has internet access and working DNS, then try again.';
    }
    if (message.contains('xmlhttprequest') ||
        message.contains('cors') ||
        message.contains('fetch')) {
      return 'Browser request to OpenAI failed. Check your internet connection, confirm browser access is allowed, and try again.';
    }
    return 'Network error while contacting OpenAI. Check your internet connection and try again.';
  }
}

class _ReminderTime {
  const _ReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

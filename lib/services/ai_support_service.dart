import 'dart:convert';

import 'package:dio/dio.dart';

import './openai_service.dart';

class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class StreamCompletion {
  final String content;
  final String? finishReason;
  final String? systemFingerprint;

  StreamCompletion({
    required this.content,
    this.finishReason,
    this.systemFingerprint,
  });
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}

class AISupportService {
  final OpenAIService _openAIService = OpenAIService();
  late final Dio dio;

  AISupportService() {
    dio = _openAIService.dio;
  }

  /// Standard chat completion for educational support queries
  Future<Completion> getChatSupport({
    required List<Message> messages,
    String model = 'gpt-4o-mini',
    String? reasoningEffort,
    String? verbosity,
  }) async {
    try {
      // Add system context for educational support
      final systemMessage = Message(
        role: 'system',
        content:
            '''You are an AI assistant for CollabFuture, an educational planning platform for students, families, and counselors. 

Your role is to provide helpful, accurate, and contextual support for:
- College and university search and selection
- Scholarship opportunities and applications
- Educational planning and timeline management
- Family communication about educational goals
- Academic counseling and guidance
- Payment and subscription questions
- Technical support for the app

Always be:
- Professional and supportive
- Accurate with educational information
- Encouraging and motivating
- Clear and concise
- Helpful with actionable advice

If you don't know something specific about the app or educational requirements, acknowledge it and suggest contacting support or a counselor.''',
      );

      final allMessages = [systemMessage, ...messages];

      final requestData = <String, dynamic>{
        'model': model,
        'messages':
            allMessages
                .map((m) => {'role': m.role, 'content': m.content})
                .toList(),
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      // Add GPT-5 specific parameters if using newer models
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        requestData.remove('temperature'); // Not supported in GPT-5
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        if (verbosity != null) requestData['verbosity'] = verbosity;
        requestData['max_completion_tokens'] = requestData.remove('max_tokens');
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error occurred',
      );
    } catch (e) {
      throw OpenAIException(
        statusCode: 500,
        message: 'Failed to get AI response: $e',
      );
    }
  }

  /// Stream chat for real-time responses
  Stream<String> getStreamingChatSupport({
    required List<Message> messages,
    String model = 'gpt-4o-mini',
    String? reasoningEffort,
  }) async* {
    try {
      // Add system context for educational support
      final systemMessage = Message(
        role: 'system',
        content:
            '''You are an AI assistant for CollabFuture, an educational planning platform. Provide helpful, accurate support for college planning, scholarships, and educational guidance. Be professional, encouraging, and concise.''',
      );

      final allMessages = [systemMessage, ...messages];

      final requestData = <String, dynamic>{
        'model': model,
        'messages':
            allMessages
                .map((m) => {'role': m.role, 'content': m.content})
                .toList(),
        'stream': true,
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      // Add GPT-5 specific parameters if using newer models
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        requestData.remove('temperature');
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        requestData['max_completion_tokens'] = requestData.remove('max_tokens');
      }

      final response = await dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var line in LineSplitter().bind(
        utf8.decoder.bind(stream.stream),
      )) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data.trim() == '[DONE]') break;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
            final content = delta['content'] ?? '';

            if (content.isNotEmpty) {
              yield content;
            }

            final finishReason = json['choices'][0]['finish_reason'];
            if (finishReason != null) break;
          } catch (e) {
            // Skip malformed JSON lines
            continue;
          }
        }
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data['error']['message'] ??
            e.message ??
            'Stream error occurred',
      );
    } catch (e) {
      throw OpenAIException(
        statusCode: 500,
        message: 'Failed to stream AI response: $e',
      );
    }
  }

  /// Quick educational guidance
  Future<String> getQuickGuidance(String query) async {
    try {
      final messages = [
        Message(
          role: 'user',
          content: 'Quick educational guidance needed: $query',
        ),
      ];

      final completion = await getChatSupport(messages: messages);
      return completion.text;
    } catch (e) {
      return 'I apologize, but I cannot provide guidance at the moment. Please try again or contact our support team.';
    }
  }

  /// Educational tips and insights
  Future<String> getDailyTip() async {
    try {
      final messages = [
        Message(
          role: 'user',
          content:
              'Provide a helpful daily tip for college-bound students about planning, applications, scholarships, or academic success. Keep it brief and actionable.',
        ),
      ];

      final completion = await getChatSupport(messages: messages);
      return completion.text;
    } catch (e) {
      return 'Stay organized with your college planning! Create a timeline for applications, scholarships, and important deadlines.';
    }
  }
}

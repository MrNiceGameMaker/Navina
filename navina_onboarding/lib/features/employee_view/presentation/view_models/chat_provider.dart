import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../../../models/onboarding_task.dart';

const _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'YOUR_GEMINI_API_KEY',
);

class ChatState {
  final List<Map<String, String>> messages;
  final bool isLoading;

  const ChatState({required this.messages, required this.isLoading});

  ChatState copyWith({
    List<Map<String, String>>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final String employeeId;

  ChatNotifier(this.employeeId);

  @override
  ChatState build() {
    return const ChatState(
      messages: [
        {'role': 'ai', 'text': 'שלום, איך אפשר לעזור?'},
      ],
      isLoading: false,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      messages: [...state.messages, {'role': 'user', 'text': trimmed}],
      isLoading: true,
    );

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client
          .from('onboarding_tasks')
          .select()
          .eq('employee_id', employeeId);

      final tasks = (response as List<dynamic>)
          .map((json) => OnboardingTask.fromJson(json as Map<String, dynamic>))
          .toList();

      final taskLines = tasks.isEmpty
          ? 'No tasks assigned yet.'
          : tasks
              .map((t) =>
                  '- ${t.title} (${t.category}): ${t.isCompleted ? "Completed" : "Pending"}')
              .join('\n');

      final systemText = '''You are the Navina Onboarding Assistant. '''
          '''The current employee has the following tasks:\n$taskLines\n'''
          '''Answer their questions briefly in Hebrew. '''
          '''If you don't know the answer, tell them exactly: '''
          '''"Please contact Liat directly regarding this matter."''';

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(systemText),
      );

      final result = await model.generateContent([Content.text(trimmed)]);
      final aiText = (result.text ?? '').trim().isEmpty
          ? 'Please contact Liat directly regarding this matter.'
          : result.text!.trim();

      state = state.copyWith(
        messages: [...state.messages, {'role': 'ai', 'text': aiText}],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          {
            'role': 'ai',
            'text': 'Please contact Liat directly regarding this matter.',
          },
        ],
        isLoading: false,
      );
    }
  }
}

final chatProvider =
    NotifierProvider.family<ChatNotifier, ChatState, String>(
  (employeeId) => ChatNotifier(employeeId),
);

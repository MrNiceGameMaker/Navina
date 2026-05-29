import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/onboarding_task.dart';
import '../../../../core/network/supabase_providers.dart';

class EmployeeTasksNotifier extends AsyncNotifier<List<OnboardingTask>> {
  final String employeeId;

  EmployeeTasksNotifier(this.employeeId);

  @override
  Future<List<OnboardingTask>> build() async {
    final client = ref.read(supabaseClientProvider);

    final channel = client
        .channel('tasks_$employeeId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'onboarding_tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'employee_id',
            value: employeeId,
          ),
          callback: (_) async {
            state = await AsyncValue.guard(_fetch);
          },
        )
        .subscribe();

    ref.onDispose(() => client.removeChannel(channel));

    return _fetch();
  }

  Future<List<OnboardingTask>> _fetch() async {
    final client = ref.read(supabaseClientProvider);
    final response = await client
        .from('onboarding_tasks')
        .select()
        .eq('employee_id', employeeId);
    return response.map((json) => OnboardingTask.fromJson(json)).toList();
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentValue) async {
    final client = ref.read(supabaseClientProvider);
    await client
        .from('onboarding_tasks')
        .update({'is_completed': !currentValue})
        .eq('id', taskId);
    state = await AsyncValue.guard(_fetch);
  }
}

final employeeTasksNotifierProvider = AsyncNotifierProvider.family<
    EmployeeTasksNotifier,
    List<OnboardingTask>,
    String>((employeeId) => EmployeeTasksNotifier(employeeId));

final employeeTasksProvider =
    FutureProvider.family<List<OnboardingTask>, String>((ref, employeeId) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('onboarding_tasks')
      .select()
      .eq('employee_id', employeeId);
  return response.map((json) => OnboardingTask.fromJson(json)).toList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/employee.dart';
import '../../../../core/network/supabase_providers.dart';

class HrNotifier extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() async {
    final client = ref.read(supabaseClientProvider);

    final channel = client
        .channel('employees_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'employees',
          callback: (_) async {
            state = await AsyncValue.guard(_fetch);
          },
        )
        .subscribe();

    ref.onDispose(() => client.removeChannel(channel));

    return _fetch();
  }

  Future<List<Employee>> _fetch() async {
    final client = ref.read(supabaseClientProvider);
    final response = await client.from('employees').select();
    return response.map((json) => Employee.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> addEmployee({
    required String email,
    required String fullName,
    required String role,
    required List<String> documents,
    required List<String> inventory,
    required Map<String, DateTime> meetings,
  }) async {
    final client = ref.read(supabaseClientProvider);

    final row = await client
        .from('employees')
        .insert({
          'email': email,
          'full_name': fullName,
          'role': role,
        })
        .select()
        .single();

    final created = Employee.fromJson(row);
    final employeeId = created.id!;

    final basicRows = <Map<String, dynamic>>[];

    for (final doc in documents) {
      basicRows.add({
        'employee_id': employeeId,
        'title': 'Review Document - $doc',
        'category': 'Document',
        'is_completed': false,
      });
    }

    for (final item in inventory) {
      basicRows.add({
        'employee_id': employeeId,
        'title': 'Collect - $item',
        'category': 'Equipment',
        'is_completed': false,
      });
    }

    if (basicRows.isNotEmpty) {
      await client.from('onboarding_tasks').insert(basicRows);
    }

    for (final entry in meetings.entries) {
      final staffName = entry.key;
      final scheduledAt = entry.value;
      try {
        await client.from('onboarding_tasks').insert({
          'employee_id': employeeId,
          'title': 'Meeting with $staffName',
          'category': 'Meeting',
          'is_completed': false,
          'scheduled_at': scheduledAt.toIso8601String(),
          'assigned_staff': staffName,
        });
      } catch (_) {
        await client.from('onboarding_tasks').insert({
          'employee_id': employeeId,
          'title': 'Meeting with $staffName on '
              '${scheduledAt.day.toString().padLeft(2, '0')}/'
              '${scheduledAt.month.toString().padLeft(2, '0')}/'
              '${scheduledAt.year} '
              '${scheduledAt.hour.toString().padLeft(2, '0')}:'
              '${scheduledAt.minute.toString().padLeft(2, '0')}',
          'category': 'Meeting',
          'is_completed': false,
        });
      }
    }

    await refresh();
  }
}

final hrNotifierProvider =
    AsyncNotifierProvider<HrNotifier, List<Employee>>(HrNotifier.new);

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client.from('employees').select();
  return response.map((json) => Employee.fromJson(json)).toList();
});

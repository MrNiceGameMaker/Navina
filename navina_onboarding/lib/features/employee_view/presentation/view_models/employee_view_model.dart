import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../../../../core/network/supabase_providers.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EmployeeRepository(client);
});

final employeesListProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployees();
});

class EmployeeNotifier extends AsyncNotifier<EmployeeModel?> {
  final String employeeId;

  EmployeeNotifier(this.employeeId);

  @override
  Future<EmployeeModel?> build() async {
    if (employeeId.isEmpty) return null;
    final client = ref.read(supabaseClientProvider);
    final response = await client
        .from('employees')
        .select()
        .eq('id', employeeId)
        .single();
    return EmployeeModel.fromJson(response);
  }

  Future<void> updateStatus(String newStatus) async {
    final client = ref.read(supabaseClientProvider);
    await client
        .from('employees')
        .update({'status': newStatus})
        .eq('id', employeeId);
    ref.invalidateSelf();
  }
}

final employeeNotifierProvider = AsyncNotifierProvider.family<
    EmployeeNotifier,
    EmployeeModel?,
    String>((employeeId) => EmployeeNotifier(employeeId));

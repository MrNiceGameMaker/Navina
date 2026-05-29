import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final SupabaseClient _client;

  EmployeeRepository(this._client);

  Future<List<EmployeeModel>> getEmployees() async {
    final response = await _client.from('employees').select();
    return response.map((json) => EmployeeModel.fromJson(json)).toList();
  }

  Future<EmployeeModel> getEmployeeById(String id) async {
    final response = await _client.from('employees').select().eq('id', id).single();
    return EmployeeModel.fromJson(response);
  }

  Future<void> updateEmployeeStatus(String id, String status) async {
    await _client.from('employees').update({'status': status}).eq('id', id);
  }
}

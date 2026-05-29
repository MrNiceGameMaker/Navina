import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mock_data.dart';
import '../view_models/hr_providers.dart';
import 'widgets/employee_card.dart';

const _blue = Color(0xFF0A66C2);
const _chipUnselectedBg = Color(0xFFEEEEEE);
const _chipSelectedBg = _blue;
const _chipUnselectedText = Color(0xFF0D0D0D);
const _chipSelectedText = Colors.white;

class HrDashboardScreen extends ConsumerStatefulWidget {
  const HrDashboardScreen({super.key});

  @override
  ConsumerState<HrDashboardScreen> createState() => _HrDashboardScreenState();
}

class _HrDashboardScreenState extends ConsumerState<HrDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRole;
  List<String> _selectedDocuments = [];
  List<String> _selectedInventory = [];
  Map<String, DateTime> _scheduledMeetings = {};

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleSelection(
    List<String> list,
    String item,
    void Function(List<String>) update,
  ) {
    final next = List<String>.from(list);
    if (next.contains(item)) {
      next.remove(item);
    } else {
      next.add(item);
    }
    update(next);
  }

  Future<void> _openStaffScheduler() async {
    final staff = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: _blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text(
                'Select Staff Member',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...mockStaff.map(
              (name) => InkWell(
                onTap: () => Navigator.of(ctx).pop(name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _chipUnselectedText,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: _blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );

    if (staff == null || !mounted) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _scheduledMeetings = Map.from(_scheduledMeetings)..[staff] = combined;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(hrNotifierProvider.notifier).addEmployee(
            email: _emailController.text.trim(),
            fullName: _nameController.text.trim(),
            role: _selectedRole!,
            documents: _selectedDocuments,
            inventory: _selectedInventory,
            meetings: _scheduledMeetings,
          );
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _selectedRole = null;
        _selectedDocuments = [];
        _selectedInventory = [];
        _scheduledMeetings = {};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding employee: $e'),
            backgroundColor: const Color(0xFF8B0000),
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  Widget _buildSingleSelectSection(
    BuildContext context,
    String title,
    List<String> options,
    String? selected,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: _blue,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final isSelected = selected == item;
            return GestureDetector(
              onTap: () => onSelect(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _chipSelectedBg : _chipUnselectedBg,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: _blue, width: 1),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _chipSelectedText : _chipUnselectedText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection(
    BuildContext context,
    String title,
    List<String> options,
    List<String> selectedList,
    void Function(List<String>) onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: _blue,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final isSelected = selectedList.contains(item);
            return GestureDetector(
              onTap: () => _toggleSelection(selectedList, item, onUpdate),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _chipSelectedBg : _chipUnselectedBg,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: _blue, width: 1),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _chipSelectedText : _chipUnselectedText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year} $h:$mi';
  }

  Widget _buildMeetingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Meetings',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: _blue,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _openStaffScheduler,
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue, width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            elevation: 0,
          ),
          child: const Text(
            'Add Staff Member',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _blue,
            ),
          ),
        ),
        if (_scheduledMeetings.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._scheduledMeetings.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _chipUnselectedBg,
                border: Border.all(color: _blue, width: 1),
                borderRadius: BorderRadius.zero,
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: _blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${entry.key}  —  ${_formatDateTime(entry.value)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _chipUnselectedText,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      final next =
                          Map<String, DateTime>.from(_scheduledMeetings);
                      next.remove(entry.key);
                      _scheduledMeetings = next;
                    }),
                    child: const Icon(Icons.close, size: 18, color: _blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(hrNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add New Employee',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                _buildSingleSelectSection(
                  context,
                  "New Employee's Role",
                  mockRoles,
                  _selectedRole,
                  (picked) => setState(() => _selectedRole = picked),
                ),
                const SizedBox(height: 20),
                _buildMultiSelectSection(
                  context,
                  'Required Documents',
                  mockDocuments,
                  _selectedDocuments,
                  (updated) => setState(() => _selectedDocuments = updated),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue, width: 1.5),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMultiSelectSection(
                  context,
                  'Inventory Allocation',
                  mockInventory,
                  _selectedInventory,
                  (updated) => setState(() => _selectedInventory = updated),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue, width: 1.5),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Inventory + Department',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMeetingsSection(context),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        (_isSubmitting || _selectedRole == null)
                            ? null
                            : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Employee'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.black, thickness: 1),
          const SizedBox(height: 24),
          Text(
            'Employees',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          employeesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Loading...'),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Color(0xFF8B0000)),
              ),
            ),
            data: (employees) {
              if (employees.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No employees yet. Add one above.'),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      (constraints.maxWidth / 300).floor().clamp(1, 4);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: employees.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      return EmployeeCard(employee: employees[index]);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

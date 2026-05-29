import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/view_mode_provider.dart';
import '../../hr_dashboard/presentation/views/hr_dashboard_screen.dart';
import '../../employee_view/presentation/views/employee_screen.dart';

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHrView = ref.watch(isHrViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHrView ? 'HR Dashboard' : 'Employee View',
        ),
        actions: [
          Row(
            children: [
              Text(
                'HR',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: isHrView ? Colors.white : Colors.white54,
                    ),
              ),
              Switch(
                value: !isHrView,
                onChanged: (val) {
                  ref.read(isHrViewProvider.notifier).toggle();
                },
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF444444),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF444444),
              ),
              Text(
                'Employee',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: !isHrView ? Colors.white : Colors.white54,
                    ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: isHrView
          ? const HrDashboardScreen()
          : const EmployeeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../models/employee.dart';
import '../../../../../features/employee_view/presentation/view_models/employee_providers.dart';
import '../../../../../providers/view_mode_provider.dart';

const _blue = Color(0xFF0A66C2);
const _grey = Color(0xFF555555);
const _lightGrey = Color(0xFFE0E0E0);
const _errorRed = Color(0xFF8B0000);

class EmployeeCard extends ConsumerWidget {
  final Employee employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = employee.id ?? '';
    final tasksAsync =
        id.isEmpty ? null : ref.watch(employeeTasksNotifierProvider(id));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (id.isEmpty) return;
        ref.read(selectedEmployeeIdProvider.notifier).set(id);
        ref.read(isHrViewProvider.notifier).showEmployeeView();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _blue, width: 1),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    employee.fullName,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: _blue, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              employee.email,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: _grey,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee.role.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (id.isEmpty)
              Text(
                'No ID available.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: _errorRed),
              )
            else
              tasksAsync!.when(
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: null,
                      borderRadius: BorderRadius.zero,
                      color: _blue,
                      backgroundColor: _lightGrey,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                error: (e, _) => Text(
                  'Could not load tasks.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: _errorRed),
                ),
                data: (tasks) {
                  final total = tasks.length;
                  final completed =
                      tasks.where((t) => t.isCompleted).length;
                  final progress =
                      total == 0 ? 0.0 : completed / total;

                  final nextTask =
                      tasks.where((t) => !t.isCompleted).firstOrNull;
                  final lastDone =
                      tasks.where((t) => t.isCompleted).lastOrNull;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Onboarding',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(fontSize: 11),
                          ),
                          Text(
                            '$completed / $total',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  fontSize: 11,
                                  color: _blue,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        borderRadius: BorderRadius.circular(6),
                        color: _blue,
                        backgroundColor: _lightGrey,
                        minHeight: 4,
                      ),
                      if (nextTask != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next: ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _blue,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                nextTask.title,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: _grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (lastDone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Done: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                lastDone.title,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: _grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nextTask == null && lastDone == null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'No tasks assigned yet.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: _grey),
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

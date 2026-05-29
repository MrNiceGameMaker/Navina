import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/onboarding_task.dart';
import '../../../../providers/view_mode_provider.dart';
import '../view_models/employee_providers.dart';
import 'widgets/ai_chat_bottom_sheet.dart';

const _blue = Color(0xFF0A66C2);
const _blueLight = Color(0xFFE8F1FB);
const _grey = Color(0xFF555555);
const _darkText = Color(0xFF0D0D0D);
const _completedText = Color(0xFF888888);
const _equipmentDone = Color(0xFF00E676);
const _equipmentPending = Color(0xFFFF5252);
const _errorRed = Color(0xFF8B0000);

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedEmployeeIdProvider);
    final employeeId =
        (selectedId != null && selectedId.isNotEmpty)
            ? selectedId
            : Uri.base.queryParameters['employee_id'];

    if (employeeId == null || employeeId.trim().isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: _blue, width: 2),
                vertical: BorderSide(color: _blue, width: 2),
              ),
            ),
            child: Text(
              'Error: Missing employee ID in URL.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: _errorRed,
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final tasksAsync = ref.watch(employeeTasksNotifierProvider(employeeId));

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            builder: (_) => AiChatBottomSheet(employeeId: employeeId),
          );
        },
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: const Icon(Icons.chat_outlined),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: Text('Loading tasks...')),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading tasks: $e',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: _errorRed,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (tasks) {
          final meetingTasks = tasks
              .where((t) => t.category == 'Meeting')
              .toList()
            ..sort((a, b) {
              if (a.scheduledAt == null && b.scheduledAt == null) return 0;
              if (a.scheduledAt == null) return 1;
              if (b.scheduledAt == null) return -1;
              return a.scheduledAt!.compareTo(b.scheduledAt!);
            });

          final actionTasks =
              tasks.where((t) => t.category != 'Meeting').toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: _blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text(
                    'My Schedule',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                if (meetingTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Text(
                      'No meetings scheduled.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: _grey),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: meetingTasks.asMap().entries.map((entry) {
                        final i = entry.key;
                        final task = entry.value;
                        return Column(
                          children: [
                            _MeetingRow(
                              task: task,
                              employeeId: employeeId,
                              ref: ref,
                            ),
                            if (i < meetingTasks.length - 1)
                              const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                Container(
                  color: _blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text(
                    'My Action Items',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                if (actionTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Text(
                      'No action items assigned.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: _grey),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: actionTasks.asMap().entries.map((entry) {
                        final i = entry.key;
                        final task = entry.value;
                        return Column(
                          children: [
                            _TaskRow(
                              task: task,
                              employeeId: employeeId,
                              ref: ref,
                            ),
                            if (i < actionTasks.length - 1)
                              const SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MeetingRow extends StatelessWidget {
  final OnboardingTask task;
  final String employeeId;
  final WidgetRef ref;

  const _MeetingRow({
    required this.task,
    required this.employeeId,
    required this.ref,
  });

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}  $h:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = task.scheduledAt != null
        ? _formatDate(task.scheduledAt!)
        : 'Date TBD';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: _blue, width: 1),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              color: task.isCompleted ? _equipmentDone : _blue,
            ),
            Checkbox(
              value: task.isCompleted,
              activeColor: _blue,
              checkColor: Colors.white,
              side: const BorderSide(color: _blue, width: 1.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              onChanged: task.id == null
                  ? null
                  : (_) => ref
                      .read(
                        employeeTasksNotifierProvider(employeeId).notifier,
                      )
                      .toggleTaskCompletion(task.id!, task.isCompleted),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? _completedText : _darkText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: _blue),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _grey,
                          ),
                        ),
                      ],
                    ),
                    if (task.assignedStaff != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 13, color: _blue),
                          const SizedBox(width: 4),
                          Text(
                            task.assignedStaff!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final OnboardingTask task;
  final String employeeId;
  final WidgetRef ref;

  const _TaskRow({
    required this.task,
    required this.employeeId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isEquipment = task.category.toLowerCase() == 'equipment';

    final Color equipmentColor =
        task.isCompleted ? _equipmentDone : _equipmentPending;

    final Color borderColor = isEquipment ? equipmentColor : _blue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: borderColor,
          width: isEquipment ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isEquipment)
              Container(
                width: 6,
                color: equipmentColor,
              ),
            Checkbox(
              value: task.isCompleted,
              activeColor: _blue,
              checkColor: Colors.white,
              side: const BorderSide(color: _blue, width: 1.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              onChanged: task.id == null
                  ? null
                  : (_) => ref
                      .read(
                        employeeTasksNotifierProvider(employeeId).notifier,
                      )
                      .toggleTaskCompletion(task.id!, task.isCompleted),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? _completedText : _darkText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isEquipment ? equipmentColor : _blueLight,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        task.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isEquipment ? _darkText : _blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isEquipment)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 16,
                  height: 16,
                  color: equipmentColor,
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsHrViewNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;

  void showEmployeeView() => state = false;

  void showHrView() => state = true;
}

final isHrViewProvider =
    NotifierProvider<IsHrViewNotifier, bool>(IsHrViewNotifier.new);

class _SelectedEmployeeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

final selectedEmployeeIdProvider =
    NotifierProvider<_SelectedEmployeeNotifier, String?>(
  _SelectedEmployeeNotifier.new,
);

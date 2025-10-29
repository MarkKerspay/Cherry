import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    required this.displayName,
    required this.whatsappNumber,
    required this.defaultInterestRate,
  });

  SettingsState copyWith({
    String? displayName,
    String? whatsappNumber,
    double? defaultInterestRate,
  }) {
    return SettingsState(
      displayName: displayName ?? this.displayName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      defaultInterestRate: defaultInterestRate ?? this.defaultInterestRate,
    );
  }
}

class SettingsController extends StateNotifier<AsyncValue<SettingsState>> {
  SettingsController() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final displayName = prefs.getString('displayName') ?? 'Chery Sales Pro';
    final whatsapp = prefs.getString('whatsappNumber') ?? '+27720000000';
    final rate = prefs.getDouble('interestRate') ?? 12.5;
    state = AsyncValue.data(
      SettingsState(
        displayName: displayName,
        whatsappNumber: whatsapp,
        defaultInterestRate: rate,
      ),
    );
  }

  Future<void> update(SettingsState settings) async {
    state = AsyncValue.data(settings);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', settings.displayName);
    await prefs.setString('whatsappNumber', settings.whatsappNumber);
    await prefs.setDouble('interestRate', settings.defaultInterestRate);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<SettingsState>>(
        (ref) => SettingsController());

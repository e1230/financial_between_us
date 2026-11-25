import 'package:shared_preferences/shared_preferences.dart';

/// Remembers (per device) the group the Home shows.
///
/// Stored in shared preferences, which are excluded from Android Auto
/// Backup.
class SelectedGroupRepository {
  SelectedGroupRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const String selectedGroupIdKey = 'fbu.selected_group_id';

  Future<String?> read() => _prefs.getString(selectedGroupIdKey);

  Future<void> write(String groupId) =>
      _prefs.setString(selectedGroupIdKey, groupId);
}

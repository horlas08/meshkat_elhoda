import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/location/domain/entities/location_entity.dart';
import 'dart:math' as math;

/// خدمة مركزية لإدارة تحديث الموقع التلقائي
class LocationRefreshService {
  static const String _autoRefreshKey = 'AUTO_REFRESH_LOCATION';
  static const String _lastLatKey = 'LAST_LATITUDE';
  static const String _lastLngKey = 'LAST_LONGITUDE';
  static const double _significantChangeThreshold = 0.1; // degrees (~11km)

  final SharedPreferences _prefs;

  LocationRefreshService(this._prefs);

  /// التحقق من تفعيل التحديث التلقائي
  bool get isAutoRefreshEnabled {
    return _prefs.getBool(_autoRefreshKey) ?? true; // enabled by default
  }

  /// تفعيل/تعطيل التحديث التلقائي
  Future<void> setAutoRefresh(bool enabled) async {
    await _prefs.setBool(_autoRefreshKey, enabled);
    log('✅ Auto-refresh location: ${enabled ? "enabled" : "disabled"}');
  }

  /// التحقق من تغير الموقع بشكل كبير
  bool hasLocationChangedSignificantly(double? newLat, double? newLng) {
    if (newLat == null || newLng == null) return false;

    final lastLat = _prefs.getDouble(_lastLatKey);
    final lastLng = _prefs.getDouble(_lastLngKey);

    // إذا لم يكن هناك موقع محفوظ سابقاً
    if (lastLat == null || lastLng == null) {
      log('📍 No previous location found - treating as significant change');
      return true;
    }

    // حساب المسافة بين الموقعين
    final distance = _calculateDistance(lastLat, lastLng, newLat, newLng);
    final hasChanged = distance >= _significantChangeThreshold;

    log(
      '📍 Location change check: ${distance.toStringAsFixed(4)}° (threshold: $_significantChangeThreshold°) - ${hasChanged ? "CHANGED" : "same"}',
    );

    return hasChanged;
  }

  /// حفظ الموقع الحالي
  Future<void> saveCurrentLocation(double lat, double lng) async {
    await _prefs.setDouble(_lastLatKey, lat);
    await _prefs.setDouble(_lastLngKey, lng);
    log('💾 Saved location: ($lat, $lng)');
  }

  /// الحصول على الموقع المحفوظ
  ({double? latitude, double? longitude}) getLastSavedLocation() {
    return (
      latitude: _prefs.getDouble(_lastLatKey),
      longitude: _prefs.getDouble(_lastLngKey),
    );
  }

  /// حساب المسافة بين نقطتين (بالدرجات)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = (lat2 - lat1).abs();
    final dLng = (lng2 - lng1).abs();
    return math.sqrt(dLat * dLat + dLng * dLng);
  }

  /// التحقق من الحاجة لتحديث الموقع عند بدء التطبيق
  bool shouldRefreshOnStartup(LocationEntity? currentLocation) {
    // إذا كان التحديث التلقائي معطل
    if (!isAutoRefreshEnabled) {
      log('⚠️ Auto-refresh is disabled - skipping location update');
      return false;
    }

    // إذا لم يكن هناك موقع حالي
    if (currentLocation == null ||
        currentLocation.latitude == null ||
        currentLocation.longitude == null) {
      log('📍 No current location - refresh needed');
      return true;
    }

    // التحقق من تغير الموقع
    return hasLocationChangedSignificantly(
      currentLocation.latitude,
      currentLocation.longitude,
    );
  }
}

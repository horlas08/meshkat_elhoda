import 'dart:convert';

class NotificationSettingsModel {
  final bool isAthanEnabled;
  final bool isPreAthanEnabled;
  final bool isAzkarSabahMasaEnabled;
  final bool isZikrAllahEnabled;
  final bool isKhushooModeEnabled; // وضع الخشوع
  final bool isCollectiveKhatmaEnabled; // إشعارات الختمة الجماعية
  final bool isSmartVoiceEnabled; // أذكار صوتية ذكية
  final int zikrIntervalMinutes; // 30, 60, 120 (نصف ساعة، ساعة، ساعتين)
  final int smartVoiceIntervalMinutes; // الفاصل الزمني للأذكار الصوتية

  const NotificationSettingsModel({
    this.isAthanEnabled = true,
    this.isPreAthanEnabled = true,
    this.isAzkarSabahMasaEnabled = true,
    this.isZikrAllahEnabled = false,
    this.isKhushooModeEnabled = false,
    this.isCollectiveKhatmaEnabled = true,
    this.isSmartVoiceEnabled = false,
    this.zikrIntervalMinutes = 60,
    this.smartVoiceIntervalMinutes = 60,
  });

  NotificationSettingsModel copyWith({
    bool? isAthanEnabled,
    bool? isPreAthanEnabled,
    bool? isAzkarSabahMasaEnabled,
    bool? isZikrAllahEnabled,
    bool? isKhushooModeEnabled,
    bool? isCollectiveKhatmaEnabled,
    bool? isSmartVoiceEnabled,
    int? zikrIntervalMinutes,
    int? smartVoiceIntervalMinutes,
  }) {
    return NotificationSettingsModel(
      isAthanEnabled: isAthanEnabled ?? this.isAthanEnabled,
      isPreAthanEnabled: isPreAthanEnabled ?? this.isPreAthanEnabled,
      isAzkarSabahMasaEnabled:
          isAzkarSabahMasaEnabled ?? this.isAzkarSabahMasaEnabled,
      isZikrAllahEnabled: isZikrAllahEnabled ?? this.isZikrAllahEnabled,
      isKhushooModeEnabled: isKhushooModeEnabled ?? this.isKhushooModeEnabled,
      isCollectiveKhatmaEnabled:
          isCollectiveKhatmaEnabled ?? this.isCollectiveKhatmaEnabled,
      isSmartVoiceEnabled: isSmartVoiceEnabled ?? this.isSmartVoiceEnabled,
      zikrIntervalMinutes: zikrIntervalMinutes ?? this.zikrIntervalMinutes,
      smartVoiceIntervalMinutes:
          smartVoiceIntervalMinutes ?? this.smartVoiceIntervalMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAthanEnabled': isAthanEnabled,
      'isPreAthanEnabled': isPreAthanEnabled,
      'isAzkarSabahMasaEnabled': isAzkarSabahMasaEnabled,
      'isZikrAllahEnabled': isZikrAllahEnabled,
      'isKhushooModeEnabled': isKhushooModeEnabled,
      'isCollectiveKhatmaEnabled': isCollectiveKhatmaEnabled,
      'isSmartVoiceEnabled': isSmartVoiceEnabled,
      'zikrIntervalMinutes': zikrIntervalMinutes,
      'smartVoiceIntervalMinutes': smartVoiceIntervalMinutes,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      isAthanEnabled: map['isAthanEnabled'] ?? true,
      isPreAthanEnabled: map['isPreAthanEnabled'] ?? true,
      isAzkarSabahMasaEnabled: map['isAzkarSabahMasaEnabled'] ?? true,
      isZikrAllahEnabled: map['isZikrAllahEnabled'] ?? false,
      isKhushooModeEnabled: map['isKhushooModeEnabled'] ?? false,
      isCollectiveKhatmaEnabled: map['isCollectiveKhatmaEnabled'] ?? true,
      isSmartVoiceEnabled: map['isSmartVoiceEnabled'] ?? false,
      zikrIntervalMinutes: map['zikrIntervalMinutes'] ?? 60,
      smartVoiceIntervalMinutes: map['smartVoiceIntervalMinutes'] ?? 60,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationSettingsModel.fromJson(String source) =>
      NotificationSettingsModel.fromMap(json.decode(source));
}

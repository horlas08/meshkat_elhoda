import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_radio_screen.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_reciters_screen.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/offline_audios_screen.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AudioMainScreen extends StatefulWidget {
  const AudioMainScreen({Key? key}) : super(key: key);

  @override
  State<AudioMainScreen> createState() => _AudioMainScreenState();
}

class _AudioMainScreenState extends State<AudioMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  bool _smartVoicePackReady = false;
  int _smartVoiceDownloadedCount = 0;
  int _smartVoiceTotalCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.4 + index * 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.4 + index * 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _animationController.forward();

    _refreshSmartVoicePackStatus();
  }

  Future<void> _refreshSmartVoicePackStatus() async {
    final service = SmartDhikrService();
    final total = service.getAllDhikrIds().length;
    final downloaded = await service.getDownloadedDhikrIds();
    final ready = await service.isDhikrPackFullyDownloaded();
    if (!mounted) return;
    setState(() {
      _smartVoiceTotalCount = total;
      _smartVoiceDownloadedCount = downloaded.length;
      _smartVoicePackReady = ready;
    });
  }

  Future<void> _showSmartVoicePackDialog(BuildContext context) async {
    final s = AppLocalizations.of(context)!;
    await _refreshSmartVoicePackStatus();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.smartVoiceDhikr),
          content: Text(
            '${s.downloadedAudio} ($_smartVoiceDownloadedCount/$_smartVoiceTotalCount)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () async {
                await SmartDhikrService().deleteDhikrPack();
                await _refreshSmartVoicePackStatus();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(s.delete),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                if (!context.mounted) return;
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (progressDialogContext) {
                    var started = false;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        var done = 0;
                        var total = SmartDhikrService().getAllDhikrIds().length;
                        var currentId = '';

                        if (!started) {
                          started = true;
                          Future<void>(() async {
                            try {
                              await SmartDhikrService().downloadDhikrPack(
                                onProgress: (id, d, t) {
                                  if (!progressDialogContext.mounted) return;
                                  setState(() {
                                    currentId = id;
                                    done = d;
                                    total = t;
                                  });
                                },
                              );
                            } finally {
                              await _refreshSmartVoicePackStatus();
                              if (progressDialogContext.mounted) {
                                Navigator.pop(progressDialogContext);
                              }
                            }
                          });
                        }

                        final percent = total == 0 ? 0.0 : (done / total);
                        return AlertDialog(
                          title: Text(s.downloadedAudio),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(value: percent),
                              const SizedBox(height: 12),
                              Text('$done/$total'),
                              if (currentId.isNotEmpty) Text('ID: $currentId'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text(s.downloadSuccess),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.quranAudio,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // Quran Recitations Card
            _buildAnimatedCard(
              index: 0,
              child: _buildModernOptionCard(
                context: context,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
                title: AppLocalizations.of(context)!.quranRecitations,
                description: AppLocalizations.of(context)!.quranRecitationsDesc,
                icon: Icons.auto_awesome,
                primaryColor: AppColors.goldenColor,
                secondaryColor: const Color(0xFFB8860B),
                accentColor: const Color(0xFFFFF8DC),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AudioRecitersScreen(
                        language: Localizations.localeOf(context).languageCode,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            // Quran Radio Card
            _buildAnimatedCard(
              index: 1,
              child: _buildModernOptionCard(
                context: context,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
                title: AppLocalizations.of(context)!.quranRadio,
                description: AppLocalizations.of(context)!.quranRadioDesc,
                icon: Icons.podcasts_rounded,
                primaryColor: const Color(0xFF5B7FFF),
                secondaryColor: const Color(0xFF3D5AFE),
                accentColor: const Color(0xFFE8EDFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AudioRadioScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            // Offline Audio Card
            _buildAnimatedCard(
              index: 2,
              child: _buildModernOptionCard(
                context: context,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
                title: s.downloadedAudio,
                description: s.downloadedAudioDesc,
                icon: Icons.cloud_download_rounded,
                primaryColor: const Color(0xFF00BFA5),
                secondaryColor: const Color(0xFF00897B),
                accentColor: const Color(0xFFE0F2F1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OfflineAudiosScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAnimatedCard(
              index: 3,
              child: _buildModernOptionCard(
                context: context,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
                title: s.smartVoiceDhikr,
                description: '${s.downloadedAudio} ($_smartVoiceDownloadedCount/$_smartVoiceTotalCount)',
                icon: Icons.record_voice_over,
                primaryColor: const Color(0xFF8E24AA),
                secondaryColor: const Color(0xFF6A1B9A),
                accentColor: const Color(0xFFF3E5F5),
                onTap: () => _showSmartVoicePackDialog(context),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(position: _slideAnimations[index], child: child),
    );
  }

  Widget _buildModernOptionCard({
    required BuildContext context,
    required bool isDarkMode,
    required double screenWidth,
    required String title,
    required String description,
    required IconData icon,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
                  : [Colors.white, accentColor.withOpacity(0.3)],
            ),
            border: Border.all(
              color: isDarkMode
                  ? primaryColor.withOpacity(0.3)
                  : primaryColor.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.4)
                    : primaryColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                  spreadRadius: 0,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background decorative circles
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withOpacity(isDarkMode ? 0.15 : 0.1),
                          primaryColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          secondaryColor.withOpacity(isDarkMode ? 0.1 : 0.08),
                          secondaryColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Row(
                    children: [
                      // Icon Container with gradient
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryColor, secondaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Inner glow effect
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                            Icon(icon, size: 36, color: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow indicator
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? primaryColor.withOpacity(0.15)
                              : primaryColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.arrow_back_ios_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

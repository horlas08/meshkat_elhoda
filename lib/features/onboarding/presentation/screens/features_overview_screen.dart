import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import '../../../../l10n/app_localizations.dart';

class FeaturesOverviewScreen extends StatefulWidget {
  const FeaturesOverviewScreen({Key? key}) : super(key: key);

  @override
  _FeaturesOverviewScreenState createState() => _FeaturesOverviewScreenState();
}

class _FeaturesOverviewScreenState extends State<FeaturesOverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;
  bool _showRights = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showAppBar) {
        setState(() => _showAppBar = true);
      } else if (_scrollController.offset < 100 && _showAppBar) {
        setState(() => _showAppBar = false);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom AppBar with animation
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            leading: AnimatedOpacity(
              opacity: _showAppBar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'السابق',
                  style: TextStyle(
                    color: AppColors.goldenColor,
                    fontSize: 16.sp,
                    fontFamily: AppFonts.tajawal,
                  ),
                ),
              ),
            ),
            title: AnimatedOpacity(
              opacity: _showAppBar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                localizations?.aboutApp ?? 'عن التطبيق',
                style: TextStyle(
                  color: AppColors.goldenColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.tajawal,
                ),
              ),
            ),
            centerTitle: true,
          ),

          // Main content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeaderSection(),
                  ),
                ),

                SizedBox(height: 40.h),

                // Features Grid
                _buildFeaturesGrid(),

                SizedBox(height: 40.h),

                // About and Rights Section
                _buildAboutAndRightsSection(),

                SizedBox(height: 40.h),

                // Contact and Legal Section
                _buildContactAndLegalSection(),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        children: [
          // Logo
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              border: Border.all(color: AppColors.goldenColor, width: 2),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/icon.png',
                width: 80.w,
                height: 80.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Title
          Text(
            "Mishkat Al-Hoda Pro",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.goldenColor,
              fontFamily: AppFonts.tajawal,
            ),
          ),

          SizedBox(height: 12.h),

          // Subtitle
          Text(
            localizations?.appDescription ??
                'تطبيقك الشامل للعبادات والمعرفة الإسلامية',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontFamily: AppFonts.tajawal,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Version
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.goldenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              localizations?.version ?? 'الإصدار 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.goldenColor,
                fontFamily: AppFonts.tajawal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final localizations = AppLocalizations.of(context);

    final features = [
      // العبادات
      FeatureItem(
        icon: AppAssets.mushaf,
        title: localizations?.quranKareem ?? 'القرآن الكريم',
        description:
        localizations?.quranDescription ??
            'قراءة القرآن الكريم كاملاً مع التفسير والتلاوة',
        color: Color(0xffD4AF37),
        // features: localizations?.quranFeatures ?? 
        features: ['114 سورة', 'تفسير الآيات', 'ختمة القرآن'],
      ),
      FeatureItem(
        icon: AppAssets.hadith,
        title: localizations?.hadiths ?? 'الأحاديث النبوية',
        description:
        localizations?.hadithsDescription ??
            'مجموعة صحيح الأحاديث مع الشرح والتصنيف',
        color: Color(0xff4A7C59),
        // features: localizations?.hadithFeatures ?? 
        features: ['الأحاديث الصحيحة', 'الشرح والفوائد', 'البحث المتقدم'],
      ),
      FeatureItem(
        icon: AppAssets.hand,
        title: localizations?.azkarAndDua ?? 'الأذكار والأدعية',
        description:
        localizations?.azkarDescription ??
            'أذكار الصباح والمساء والأدعية المأثورة',
        color: Color(0xffA3B18A),
        // features: localizations?.azkarFeatures ?? 
        features: ['أذكار اليوم', 'أدعية مأثورة', 'تذكيرات'],
      ),
      FeatureItem(
        icon: AppAssets.asmaaAllah,
        title: localizations?.allahNames ?? 'أسماء الله الحسنى',
        description:
        localizations?.allahNamesDescription ??
            'تعلم أسماء الله الحسنى مع المعاني والفضل',
        color: Color(0xffC66B6B),
        // features: localizations?.allahNamesFeatures ?? 
        features: ['99 اسماً', 'المعاني والشرح', 'الفضل والثواب'],
      ),
      FeatureItem(
        icon: AppAssets.khatma,
        title: localizations?.khatmaTracker ?? 'متتبع الختمة',
        description:
        localizations?.khatmaDescription ??
            'تتبع تقدمك في ختم القرآن الكريم',
        color: Color(0xffD4CF37),
        // features: localizations?.khatmaFeatures ?? 
        features: ['تتبع التقدم', 'الإحصائيات', 'الأهداف اليومية'],
      ),

      // دليل الصلاة
      FeatureItem(
        icon: AppAssets.bosla,
        title: localizations?.prayerTimes ?? 'مواقيت الصلاة',
        description:
        localizations?.prayerTimesDescription ??
            'مواقيت الصلاة الدقيقة لموقعك',
        color: Color(0xff5BC0BE),
        // features: localizations?.prayerFeatures ?? 
        features: ['5 مواقيت يومية', 'القبلة', 'التنبيهات'],
      ),
      FeatureItem(
        icon: AppAssets.location,
        title: localizations?.nearbyMosques ?? 'المساجد القريبة',
        description:
        localizations?.mosquesDescription ??
            'اكتشف المساجد القريبة من موقعك',
        color: Color(0xff14213D),
        // features: localizations?.mosqueFeatures ?? 
        features: ['خريطة المساجد', 'المسافة والوقت', 'المعلومات'],
      ),

      // الخدمات الإسلامية
      FeatureItem(
        icon: AppAssets.audio,
        title: localizations?.islamicAudio ?? 'الصوتيات الإسلامية',
        description:
        localizations?.audioDescription ?? 'قرآن وخطابات ومحاضرات صوتية',
        color: Color(0xffB25986),
        // features: localizations?.audioFeatures ?? 
        features: ['قرآن كريم', 'خطب ومحاضرات', 'إذاعة قرآنية'],
      ),
      FeatureItem(
        icon: AppAssets.haram,
        title: localizations?.liveBroadcast ?? 'البث المباشر',
        description:
        localizations?.broadcastDescription ??
            'شاهد البث المباشر من الحرم المكي',
        color: Color(0xff14213D),
        // features: localizations?.broadcastFeatures ?? 
        features: ['الحرم المكي', 'المسجد النبوي', 'القنوات الإسلامية'],
      ),
      FeatureItem(
        icon: AppAssets.ai,
        title: localizations?.smartAssistant ?? 'المساعد الذكي',
        description:
        localizations?.assistantDescription ??
            'أسلوبك الإسلامي للإجابة على أسئلتك',
        color: Color(0xff5C7AEA),
        // features: localizations?.assistantFeatures ?? 
        features: ['فتاوى شرعية', 'إجابات دقيقة', 'دليل إرشادي'],
      ),
      FeatureItem(
        icon: AppAssets.zaka,
        title: localizations?.zakatCalculator ?? 'حاسبة الزكاة',
        description:
        localizations?.zakatDescription ?? 'احسب زكاتك بدقة وسهولة',
        color: Color(0xffD4AF92),
        // features: localizations?.zakatFeatures ?? 
        features: ['زكاة المال', 'زكاة الذهب', 'زكاة التجارة'],
      ),
      FeatureItem(
        icon: AppAssets.date,
        title: localizations?.dateConverter ?? 'محول التاريخ',
        description:
        localizations?.dateConverterDescription ??
            'تحويل بين الهجري والميلادي',
        color: Color(0xffE9C46A),
        features: ['تحويل التواريخ', 'التقويم الهجري', 'مناسبات إسلامية'],
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
            child: Text(
              localizations?.mainFeatures ?? 'المميزات الرئيسية',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.goldenColor,
                fontFamily: AppFonts.tajawal,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.65,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return FeatureCard(feature: features[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAndRightsSection() {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.aboutAndRights ?? 'عن التطبيق والحقوق',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.goldenColor,
              fontFamily: AppFonts.tajawal,
            ),
          ),
          SizedBox(height: 16.h),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppColors.goldenColor,
                    ),
                    title: Text(
                      localizations?.generalInfo ?? 'معلومات عامة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    subtitle: Text(
                      localizations?.appFullDescription ??
                          'تطبيق مشكاة الهدى برو هو تطبيق إسلامي شامل يهدف إلى تيسير العبادات والمعرفة الإسلامية للمسلمين حول العالم.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.copyright,
                      color: AppColors.goldenColor,
                    ),
                    title: Text(
                      localizations?.intellectualRights ?? 'الحقوق الفكرية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جميع الحقوق محفوظة © 2024-2025 مشكاة الهدى',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          localizations?.copyProhibition ??
                              '• يمنع نسخ أو توزيع المحتوى دون إذن مسبق',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                        Text(
                          localizations?.contentSource ??
                              '• المحتوى الإسلامي من مصادر موثوقة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                        Text(
                          localizations?.designProtection ??
                              '• تصميم وبرمجة التطبيق محمية بحقوق الطبع',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndLegalSection() {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.legalInformation ?? 'المعلومات القانونية',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.goldenColor,
              fontFamily: AppFonts.tajawal,
            ),
          ),
          SizedBox(height: 16.h),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Privacy Policy
                  ExpansionTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.goldenColor,
                    ),
                    title: Text(
                      localizations?.privacyPolicy ?? 'سياسة الخصوصية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPolicySection(
                              localizations?.dataCollection ?? 'جمع المعلومات',
                              '${localizations?.locationDataCollect ?? "• نحن نجمع بيانات الموقع لتوفير مواقيت الصلاة الدقيقة"}\n${localizations?.accountDataStorage ?? "• بيانات الحساب تُخزن بأمان للنسخ الاحتياطي"}\n${localizations?.noDataSharing ?? "• لا نشارك بياناتك الشخصية مع أطراف ثالثة"}',
                            ),
                            SizedBox(height: 12.h),
                            _buildPolicySection(
                              localizations?.guestData ?? 'بيانات الضيف',
                              '${localizations?.guestUsage ?? "• يمكن استخدام التطبيق كضيف دون تسجيل"}\n${localizations?.localStorage ?? "• بيانات الضيف تُخزن محلياً على جهازك فقط"}\n${localizations?.accountConversion ?? "• يمكنك التحويل إلى حساب مسجل في أي وقت"}',
                            ),
                            SizedBox(height: 12.h),
                            _buildPolicySection(
                              localizations?.security ?? 'الأمان',
                              '${localizations?.sslEncryption ?? "• نستخدم تشفير SSL لجميع الاتصالات"}\n${localizations?.passwordEncryption ?? "• كلمات المرور تُخزن بشكل مشفر"}\n${localizations?.dataProtection ?? "• نلتزم بمعايير حماية البيانات العالمية"}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),

                  // Terms of Use
                  ExpansionTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: AppColors.goldenColor,
                    ),
                    title: Text(
                      localizations?.termsOfUse ?? 'شروط الاستخدام',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPolicySection(
                              localizations?.acceptableUse ??
                                  'الاستخدام المقبول',
                              '${localizations?.worshipUsage ?? "• استخدام التطبيق لأغراض العبادة والمعرفة الإسلامية"}\n${localizations?.respectIntellectualProperty ?? "• احترام حقوق الملكية الفكرية للمحتوى"}\n${localizations?.complyWithLaws ?? "• الالتزام بالقوانين المحلية والدولية"}',
                            ),
                            SizedBox(height: 12.h),
                            _buildPolicySection(
                              localizations?.restrictions ?? 'القيود',
                              '${localizations?.illegalUsageProhibition ?? "• لا يُسمح باستخدام التطبيق لأغراض غير قانونية"}\n${localizations?.copyModifyProhibition ?? "• منع نسخ أو تعديل المحتوى دون إذن"}\n${localizations?.respectfulEnvironment ?? "• الحفاظ على بيئة استخدام محترمة"}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),

                  // Contact
                  ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color: AppColors.goldenColor,
                    ),
                    title: Text(
                      localizations?.contactUs ?? 'الاتصال بنا',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'waleedd2369@gmail.com',
                              queryParameters: {
                                'subject':
                                localizations?.appInquiry ??
                                    'استفسار عن تطبيق مشكاة الهدى',
                              },
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              await launchUrl(emailLaunchUri);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                size: 16.sp,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'waleedd2369@gmail.com',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: AppFonts.tajawal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          localizations?.welcomeQuestions ??
                              'نرحب بأسئلتكم واستفساراتكم حول التطبيق',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Legal Info
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          localizations?.legalInformation ?? 'معلومات قانونية',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${localizations?.lastUpdate ?? "آخر تحديث: 10 ديسمبر 2025"}\n${localizations?.compatibility ?? "متوافق مع: iOS 13+ / Android 8+"}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Copyright Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.goldenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.goldenColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.copyright,
                          color: AppColors.goldenColor,
                          size: 24.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'جميع الحقوق محفوظة © 2024-2025\nتطبيق مشكاة الهدى',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenColor,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          localizations?.version ?? 'الإصدار 1.0.0',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontFamily: AppFonts.tajawal,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontFamily: AppFonts.tajawal,
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatefulWidget {
  final FeatureItem feature;

  const FeatureCard({required this.feature});

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.h),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.h),
                      topRight: Radius.circular(16.h),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: widget.feature.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          widget.feature.icon,
                          width: 32.w,
                          height: 32.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.feature.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: AppFonts.tajawal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Description
                      Text(
                        widget.feature.description,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                          fontFamily: AppFonts.tajawal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Features list
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.feature.features.take(2).map((
                            feature,
                            ) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 10.w,
                                  color: widget.feature.color,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.grey[700],
                                      fontFamily: AppFonts.tajawal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}

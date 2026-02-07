import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/back_icon.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/tasbeh_container.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/tasbeh_with_action.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class TasbehVeiw extends StatefulWidget {
  const TasbehVeiw({super.key});

  @override
  State<TasbehVeiw> createState() => _TasbehVeiwState();
}

class _TasbehVeiwState extends State<TasbehVeiw> {
  String selectedZikr = 'سبحان الله';
  int counter = 0;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ✅ تحميل البيانات المحفوظة من Firebase
  Future<void> _loadSavedData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // تحميل آخر تسبيح مختار
      final currentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeh')
          .doc('current')
          .get();

      if (currentDoc.exists && mounted) {
        final lastZikr = currentDoc.data()?['zikr'] ?? 'سبحان الله';
        setState(() {
          selectedZikr = lastZikr;
        });
      }

      // تحميل العداد الخاص بهذا التسبيح
      await _loadCounterForZikr(selectedZikr);
    } catch (e) {
      print('Error loading tasbeh data: $e');
    }
  }

  // ✅ تحميل العداد الخاص بتسبيح معين
  Future<void> _loadCounterForZikr(String zikr) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeh')
          .doc(zikr)
          .get();

      if (mounted) {
        setState(() {
          counter = doc.exists ? (doc.data()?['count'] ?? 0) : 0;
        });
      }
    } catch (e) {
      print('Error loading counter for $zikr: $e');
    }
  }

  Future<void> _saveToFirebase() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage(
          AppLocalizations.of(context)!.mustLoginFirst,
          isError: true,
        );
        return;
      }

      // حفظ العداد الخاص بهذا التسبيح
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeh')
          .doc(selectedZikr)
          .set({
            'count': counter,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // حفظ آخر تسبيح مختار
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeh')
          .doc('current')
          .set({
            'zikr': selectedZikr,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // حفظ في السجل أيضاً
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeh')
          .doc('history')
          .collection('records')
          .add({
            'zikr': selectedZikr,
            'count': counter,
            'savedAt': FieldValue.serverTimestamp(),
          });

      _showMessage(AppLocalizations.of(context)!.savedSuccessfully);
    } catch (e) {
      final s = AppLocalizations.of(context)!;
      print('${s.errorSavingTasbeh}: $e');
      _showMessage(s.saveFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, fontFamily: AppFonts.tajawal),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _onZikrChanged(String newZikr) async {
    setState(() {
      selectedZikr = newZikr;
    });

    // تحميل العداد الخاص بالتسبيح الجديد
    await _loadCounterForZikr(newZikr);

    // حفظ آخر تسبيح مختار
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasbeh')
            .doc('current')
            .set({
              'zikr': newZikr,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (e) {
        print('Error saving selected zikr: $e');
      }
    }
  }

  void _onCounterChanged(int newCounter) {
    setState(() {
      counter = newCounter;
    });
  }

  void _resetCounter() async {
    setState(() {
      counter = 0;
    });

    // حفظ القيمة الصفرية في قاعدة البيانات
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasbeh')
            .doc(selectedZikr)
            .set({
              'count': 0,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error resetting counter in Firebase: $e');
    }
  }

  final List<String> _baseAzkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
  ];

  int _getSelectedIndex(BuildContext context) {
    int index = _baseAzkar.indexOf(selectedZikr);
    if (index != -1) return index;

    final s = AppLocalizations.of(context)!;
    final localList = [
      s.subhanAllah,
      s.alhamdulillah,
      s.allahuAkbar,
      s.laIlahaIllallah,
      s.astaghfirullah,
    ];
    index = localList.indexOf(selectedZikr);
    if (index != -1) return index;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackIcon(
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                s.rememberAllah,
                style: AppTextStyles.surahName.copyWith(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                s.rememberAllahDescription,
                style: AppTextStyles.surahName.copyWith(
                  color: AppColors.greyColor,
                  fontFamily: AppFonts.tajawal,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 85.h),

              TasbehContainer(
                selectedIndex: _getSelectedIndex(context),
                onZikrChanged: (index) {
                  _onZikrChanged(_baseAzkar[index]);
                },
              ),
              SizedBox(height: 44.h),

              SebhaWithActions(
                counter: counter,
                onCounterChanged: _onCounterChanged,
                onReset: _resetCounter,
                onSave: _saveToFirebase,
                isSaving: isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

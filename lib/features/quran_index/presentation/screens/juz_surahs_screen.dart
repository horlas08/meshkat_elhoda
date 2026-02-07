import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/juz_entity.dart';

import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_event.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/surah_screen.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/loading_widget.dart';

class JuzSurahsScreen extends StatefulWidget {
  final int juzNumber;
  const JuzSurahsScreen({Key? key, required this.juzNumber}) : super(key: key);

  @override
  State<JuzSurahsScreen> createState() => _JuzSurahsScreenState();
}

class _JuzSurahsScreenState extends State<JuzSurahsScreen> {
  @override
  void initState() {
    super.initState();
    // جلب بيانات الجزء بشكل دقيق
    context.read<QuranBloc>().add(GetJuzSurahsEvent(number: widget.juzNumber));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        // عند الرجوع بالسهم الخلفي للأندرويد
        context.read<QuranBloc>().add(GetAllSurahsEvent());
        return true; // اسمح بالرجوع
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${localizations?.juzSurahsTitle ?? 'Surahs of Juz'} ${widget.juzNumber}',
          ),
          centerTitle: true,
          backgroundColor:
              Theme.of(context).appBarTheme.backgroundColor ??
              const Color(0xFFD4A574),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<QuranBloc>().add(GetAllSurahsEvent());
              Navigator.pop(context);
            },
          ),
        ),
        body: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state is Loading) {
              return const QuranLottieLoading();
            }
            if (state is Error) {
              log(state.message);
              return Center(
                child: Text(
                  '${localizations?.errorMessage ?? 'An error occurred'}: ${state.message}',
                ),
              );
            }
            if (state is JuzLoaded) {
              final juz = state.juz;

              // تجميع السور الفريدة في الجزء
              final uniqueSurahs = <int, JuzSurah>{};
              for (final surah in juz.surahs) {
                if (!uniqueSurahs.containsKey(surah.number)) {
                  uniqueSurahs[surah.number] = surah;
                }
              }

              if (uniqueSurahs.isEmpty) {
                return Center(
                  child: Text(
                    localizations?.noSurahsInJuz ??
                        'No surahs found for this Juz',
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(8.w),
                itemCount: uniqueSurahs.length,
                itemBuilder: (context, index) {
                  final surah = uniqueSurahs.values.elementAt(index);

                  // احسب عدد الآيات من هذه السورة في هذا الجزء
                  final ayahsInThisJuz = juz.surahs
                      .where((s) => s.number == surah.number)
                      .length;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: ListTile(
                      title: Text(
                        surah.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.h),
                          // Text(
                          //   surah.englishName,
                          //   style: TextStyle(
                          //     fontSize: 14.sp,
                          //     color: Theme.of(
                          //       context,
                          //     ).textTheme.bodyMedium?.color,
                          //   ),
                          // ),
                          SizedBox(height: 2.h),
                          Text(
                            'عدد الآيات في الجزء: $ayahsInThisJuz',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: const Color(0xFFD4A574),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahScreen(
                              surahNumber: surah.number,
                              surahName: surah.name,
                            ),
                          ),
                        ).then((_) {
                          if (mounted) {
                            context.read<QuranBloc>().add(
                              GetJuzSurahsEvent(number: widget.juzNumber),
                            );
                          }
                        });
                      },
                    ),
                  );
                },
              );
            }

            if (state is SurahsLoaded) {
              // fallback للعودة للسور الكاملة
              final juzSurahs = state.surahs
                  .where((s) => s.juzNumber == widget.juzNumber)
                  .toList();

              if (juzSurahs.isEmpty) {
                return Center(
                  child: Text(
                    localizations?.noSurahsInJuz ??
                        'No surahs found for this Juz',
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(8.w),
                itemCount: juzSurahs.length,
                itemBuilder: (context, index) {
                  final surah = juzSurahs[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: ListTile(
                      title: Text(
                        surah.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        surah.englishName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: const Color(0xFFD4A574),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahScreen(
                              surahNumber: surah.number,
                              surahName: surah.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

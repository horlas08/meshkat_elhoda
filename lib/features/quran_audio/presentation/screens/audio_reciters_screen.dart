import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_surahs_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AudioRecitersScreen extends StatefulWidget {
  final String language;

  const AudioRecitersScreen({Key? key, required this.language})
    : super(key: key);

  @override
  State<AudioRecitersScreen> createState() => _AudioRecitersScreenState();
}

class _AudioRecitersScreenState extends State<AudioRecitersScreen> {
  late TextEditingController _searchController;
  bool _isFirstLoad = true;

  // القراء المتاحون للنسخة المجانية
  static const List<String> freeReciters = [
    "محمد صديق المنشاوي",
    "محمود خليل الحصري",
    "محمد أيوب",
    "مشاري العفاسي",
    "علي جابر",
    "ياسر الدوسري",
    "بدر التركي",
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ تحميل البيانات المرة الأولى فقط
    if (_isFirstLoad) {
      _isFirstLoad = false;
      print('📥 Loading reciters for language: ${widget.language}');

      // تحميل بيانات الاشتراك أولاً
      context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());

      // ثم تحميل القراء
      context.read<QuranAudioBloc>().add(
        LoadRecitersEvent(language: widget.language),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.reciters,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<QuranAudioBloc, QuranAudioState>(
        buildWhen: (previous, current) {
          // ✅ أعد البناء فقط عند تغيير الريسيترز أو البحث
          return current is RecitersLoading ||
              current is RecitersLoaded ||
              current is RecitersError;
        },
        builder: (context, state) {
          if (state is RecitersLoading) {
            return QuranLottieLoading();
          }

          if (state is RecitersError) {
            return Center(
              child: Text(state.message, textAlign: TextAlign.center),
            );
          }

          if (state is RecitersLoaded) {
            final reciters = state.filteredReciters.isNotEmpty
                ? state.filteredReciters
                : state.reciters;

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<QuranAudioBloc>().add(
                        SearchRecitersEvent(query: query),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.searchRecitersHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.goldenColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.goldenColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Reciters list with subscription-based access control
                Expanded(
                  child: reciters.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noResultsFound,
                          ),
                        )
                      : BlocBuilder<SubscriptionBloc, SubscriptionState>(
                          builder: (context, subscriptionState) {
                            // Default to free tier until subscription is loaded
                            final isPremium =
                                subscriptionState is SubscriptionLoaded &&
                                subscriptionState.subscription.isPremium;

                            // Sort reciters: free reciters first, then premium
                            final sortedReciters = List<Reciter>.from(reciters);
                            sortedReciters.sort((a, b) {
                              final aIsFree = freeReciters.contains(a.name);
                              final bIsFree = freeReciters.contains(b.name);

                              if (aIsFree && !bIsFree) return -1;
                              if (!aIsFree && bIsFree) return 1;
                              return 0;
                            });

                            return ListView.builder(
                              itemCount: sortedReciters.length,
                              itemBuilder: (context, index) {
                                final reciter = sortedReciters[index];
                                final isAccessible =
                                    isPremium ||
                                    freeReciters.contains(reciter.name);

                                return ReciterCard(
                                  reciter: reciter,
                                  isAccessible: isAccessible,
                                  isPremium: isPremium,
                                  onTap: () {
                                    if (!isAccessible) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.reciterPremiumOnly,
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    context.read<QuranAudioBloc>().add(
                                      SelectReciterEvent(reciter: reciter),
                                    );
                                    context.read<QuranAudioBloc>().add(
                                      LoadSurahsEvent(reciter: reciter),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AudioSurahsScreen(reciter: reciter),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ReciterCard extends StatelessWidget {
  final Reciter reciter;
  final VoidCallback onTap;
  final bool isAccessible;
  final bool isPremium;

  const ReciterCard({
    Key? key,
    required this.reciter,
    required this.onTap,
    required this.isAccessible,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Opacity(
          opacity: isAccessible ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isAccessible
                            ? AppColors.goldenColor
                            : Colors.grey.shade400,
                        isAccessible
                            ? AppColors.goldenColor.withOpacity(0.6)
                            : Colors.grey.shade300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      reciter.letter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reciter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reciter.rewaya,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.surahsCount.replaceAll(
                          '{count}',
                          reciter.count.toString(),
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // Lock icon or Arrow
                if (!isAccessible)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.goldenColor,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

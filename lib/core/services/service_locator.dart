import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Hajj & Umrah Imports
import 'package:meshkat_elhoda/features/hajj_umrah/data/datasources/hajj_umrah_local_data_source.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/data/repositories/hajj_umrah_repository_impl.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/repositories/hajj_umrah_repository.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/bloc/hajj_umrah_cubit.dart';

import 'package:get_it/get_it.dart';
import 'package:meshkat_elhoda/core/services/in_app_purchase_service.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:meshkat_elhoda/core/services/audio_player/audio_player_service.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/core/services/quran_audio_services.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:meshkat_elhoda/core/services/admob_service.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/data_sources/prayer_times_local_data_source.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/data_sources/prayer_times_remote_data_source.dart';
import 'package:meshkat_elhoda/features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_data_source.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_local_data_source_impl.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/datasources/quran_audio_remote_data_source_impl.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/repositories/quran_audio_repository_impl.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/repositories/quran_audio_repository.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/add_to_recently_played.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_radio_stations.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_reciters.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_surahs.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/save_favorite_reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_call_handler.dart';
import '../network/firebase_service.dart';
import '../network/network_info.dart';
import '../network/network_info_impl.dart';
import '../network/quran_api_service.dart';
import '../../features/quran_index/data/datasources/quran_local_data_source.dart';
import '../../features/quran_index/data/datasources/quran_remote_data_source.dart';
import '../../features/quran_index/data/repositories/quran_repository_impl.dart';
import '../../features/quran_index/data/usecases/get_audio_url_impl.dart';
import '../../features/quran_index/domain/repositories/quran_repository.dart';
import '../../features/quran_index/domain/usecases/get_all_surahs.dart';
import '../../features/quran_index/domain/usecases/get_ayah_tafsir.dart';
import '../../features/quran_index/domain/usecases/get_audio_url.dart';
import '../../features/quran_index/domain/usecases/get_juz_surahs.dart';
import '../../features/quran_index/domain/usecases/get_last_position.dart';
import '../../features/quran_index/domain/usecases/get_reciters.dart'
    as quran_index_get_reciters;
import '../../features/quran_index/domain/usecases/get_surah_by_number.dart';
import '../../features/quran_index/domain/usecases/save_last_position.dart';
import '../../features/quran_index/domain/usecases/get_available_tafsirs.dart';
import '../../features/quran_index/domain/usecases/get_available_reciters.dart'
    as quran_index_get_available_reciters;
import '../../features/quran_index/presentation/bloc/quran_bloc.dart';
import '../../features/quran_index/presentation/bloc/quran_settings_cubit.dart';
import '../../features/bookmarks/data/datasources/bookmark_local_data_source.dart';
import '../../features/bookmarks/data/datasources/bookmark_remote_data_source.dart';
import '../../features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import '../../features/bookmarks/domain/repositories/bookmark_repository.dart';
import '../../features/bookmarks/domain/usecases/add_bookmark.dart';
import '../../features/bookmarks/domain/usecases/delete_bookmark.dart';
import '../../features/bookmarks/domain/usecases/get_bookmark_id.dart';
import '../../features/bookmarks/domain/usecases/get_bookmarks.dart';
import '../../features/bookmarks/domain/usecases/is_bookmarked.dart';
import '../../features/bookmarks/presentation/bloc/bookmark_bloc.dart';
import '../../features/hadith/data/datasources/hadith_local_data_source.dart';
import '../../features/hadith/data/datasources/hadith_remote_data_source.dart';
import '../../features/hadith/data/repositories/hadith_repository_impl.dart';
import '../../features/hadith/domain/repositories/hadith_repository.dart';
import '../../features/hadith/domain/usecases/get_categories.dart';
import '../../features/hadith/domain/usecases/get_hadith_by_id.dart';
import '../../features/hadith/domain/usecases/get_random_hadith.dart';
import '../../features/hadith/domain/usecases/get_hadiths_by_category.dart';
import '../../features/hadith/presentation/bloc/hadith_bloc.dart';
import '../../features/azkar/data/datasources/azkar_local_data_source.dart';
import '../../features/azkar/data/datasources/azkar_remote_data_source.dart';
import '../../features/azkar/data/repositories/azkar_repository_impl.dart';
import '../../features/azkar/data/repositories/allah_names_repository_impl.dart';
import '../../features/azkar/domain/repositories/azkar_repository.dart';
import '../../features/azkar/domain/repositories/allah_names_repository.dart';
import '../../features/azkar/domain/usecases/get_azkar_categories.dart';
import '../../features/azkar/domain/usecases/get_azkar_items.dart';
import '../../features/azkar/domain/usecases/get_azkar_audio.dart';
import '../../features/azkar/domain/usecases/get_allah_names.dart';
import '../../features/azkar/presentation/bloc/azkar_bloc.dart';
import '../../features/mosques/data/datasources/mosques_remote_data_source.dart';
import '../../features/mosques/data/datasources/mosques_local_data_source.dart';
import '../../features/mosques/data/repositories/mosque_repository_impl.dart';
import '../../features/mosques/domain/repositories/mosque_repository.dart';
import '../../features/mosques/domain/usecases/get_nearby_mosques.dart';
import '../../features/mosques/presentation/bloc/mosque_bloc.dart';
import '../../features/halal_restaurants/data/datasources/halal_restaurants_remote_data_source.dart';
import '../../features/halal_restaurants/data/datasources/halal_restaurants_local_data_source.dart';
import '../../features/halal_restaurants/data/repositories/halal_restaurants_repository_impl.dart';
import '../../features/halal_restaurants/domain/repositories/halal_restaurants_repository.dart';
import '../../features/halal_restaurants/domain/usecases/get_nearby_halal_restaurants.dart';
import '../../features/halal_restaurants/presentation/bloc/halal_restaurants_bloc.dart';
import '../../features/assistant/data/datasources/assistant_remote_data_source.dart';
import '../../features/assistant/data/datasources/assistant_local_data_source.dart';
import '../../features/assistant/data/repositories/assistant_repository_impl.dart';
import '../../features/assistant/domain/repositories/assistant_repository.dart';
import '../../features/assistant/domain/usecases/send_message.dart';
import '../../features/assistant/domain/usecases/get_chat_history.dart';
import '../../features/assistant/domain/usecases/create_new_chat.dart';
import '../../features/assistant/domain/usecases/get_chat_list.dart';
import '../../features/assistant/presentation/bloc/assistant_bloc.dart';

// Hisn al-Muslim Feature
import '../../features/hisn_muslim/data/datasources/hisn_muslim_local_data_source.dart';
import '../../features/hisn_muslim/data/repositories/hisn_muslim_repository_impl.dart';
import '../../features/hisn_muslim/domain/repositories/hisn_repository.dart';
import '../../features/hisn_muslim/presentation/bloc/hisn_muslim_bloc.dart';

// ✅ Favorites Feature
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';

import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_muezzins.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/manage_muezzin.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_prayer_times.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/usecases/get_cached_prayer_times.dart';

// Subscription Feature
import 'package:meshkat_elhoda/features/subscription/data/datasources/subscription_local_data_source.dart';
import 'package:meshkat_elhoda/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:meshkat_elhoda/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';

import 'package:meshkat_elhoda/features/quran_audio/data/datasources/audio_download_service.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/download_surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/get_offline_audios.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/usecases/delete_offline_audio.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/offline_audios_cubit.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/surah_download_cubit.dart';

// Theme Feature
import 'package:meshkat_elhoda/features/settings/data/datasources/theme_local_data_source.dart';
import 'package:meshkat_elhoda/features/settings/data/repositories/theme_repository_impl.dart';
import 'package:meshkat_elhoda/features/settings/domain/repositories/theme_repository.dart';
import 'package:meshkat_elhoda/features/settings/domain/usecases/get_theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/domain/usecases/save_theme_settings.dart';
import 'package:meshkat_elhoda/features/settings/presentation/cubit/theme_cubit.dart';

// Notification Settings
import 'package:meshkat_elhoda/features/settings/presentation/cubit/notification_settings_cubit.dart';

// Khatma Progress Feature
import 'package:meshkat_elhoda/features/quran_index/data/datasources/khatma_progress_data_source.dart';
import 'package:meshkat_elhoda/features/quran_index/data/repositories/khatma_progress_repository_impl.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/repositories/khatma_progress_repository.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_bloc.dart';

// Quran Khatmah Imports
import '../../features/quran_khatmah/data/datasources/khatmah_remote_datasource.dart';
import '../../features/quran_khatmah/data/repositories/khatmah_repository_impl.dart';
import '../../features/quran_khatmah/domain/repositories/khatmah_repository.dart';
import '../../features/quran_khatmah/domain/usecases/get_page_details_usecase.dart';
import '../../features/quran_khatmah/domain/usecases/get_user_khatmah_progress_usecase.dart';
import '../../features/quran_khatmah/domain/usecases/update_khatmah_progress_usecase.dart';
import '../../features/quran_khatmah/presentation/bloc/khatmah_bloc.dart';

// Collective Khatma Imports
import '../../features/collective_khatma/data/datasources/collective_khatma_remote_datasource.dart';
import '../../features/collective_khatma/data/repositories/collective_khatma_repository_impl.dart';
import '../../features/collective_khatma/domain/repositories/collective_khatma_repository.dart';
import '../../features/collective_khatma/domain/usecases/create_khatma_usecase.dart';
import '../../features/collective_khatma/domain/usecases/join_khatma_usecase.dart';
import '../../features/collective_khatma/domain/usecases/complete_part_usecase.dart';
import '../../features/collective_khatma/domain/usecases/get_khatma_details_usecase.dart';
import '../../features/collective_khatma/domain/usecases/get_public_khatmas_usecase.dart';
import '../../features/collective_khatma/domain/usecases/get_user_collective_khatmas_usecase.dart';
import '../../features/collective_khatma/domain/usecases/get_user_created_khatmas_usecase.dart';
import '../../features/collective_khatma/presentation/bloc/collective_khatma_bloc.dart';

final getIt = GetIt.instance;


@injectableInit
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // HTTP and Network
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<InternetConnectionChecker>()),
  );

  // Services
  getIt.registerLazySingleton<FirebaseService>(
    () => FirebaseService(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  getIt.registerLazySingleton<QuranApiService>(
    () => QuranApiService(getIt<http.Client>()),
  );

  getIt.registerLazySingleton<ApiCallHandler>(
    () => ApiCallHandler(client: getIt<http.Client>()),
  );

  // أضف هذا: Audio Service
  getIt.registerLazySingleton<QuranAudioService>(() => QuranAudioService());
  getIt.registerLazySingleton<AthanAudioService>(() => AthanAudioService());

  // AdMob Service
  getIt.registerLazySingleton<AdMobService>(() => AdMobService());

  // Quran Feature
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () =>
        QuranLocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<QuranRemoteDataSource>(
    () => QuranRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      firebaseService: getIt<FirebaseService>(),
    ),
  );

  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      remoteDataSource: getIt<QuranRemoteDataSource>(),
      localDataSource: getIt<QuranLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Quran Use Cases
  // Quran Use Cases
  getIt.registerLazySingleton(() => GetAllSurahs(getIt<QuranRepository>()));
  getIt.registerLazySingleton(() => GetSurahByNumber(getIt<QuranRepository>()));
  getIt.registerLazySingleton(() => GetJuzSurahs(getIt<QuranRepository>()));
  getIt.registerLazySingleton(() => GetAyahTafsir(getIt<QuranRepository>()));
  getIt.registerLazySingleton(
    () => quran_index_get_reciters.GetReciters(getIt<QuranRepository>()),
  );
  getIt.registerLazySingleton(() => SaveLastPosition(getIt<QuranRepository>()));
  getIt.registerLazySingleton(() => GetLastPosition(getIt<QuranRepository>()));
  getIt.registerLazySingleton(
    () => GetAvailableTafsirs(getIt<QuranRepository>()),
  );
  getIt.registerLazySingleton(
    () => quran_index_get_available_reciters.GetAvailableReciters(
      getIt<QuranRepository>(),
    ),
  );

  // ✅ تسجيل GetAudioUrl - تم إصلاح الخطأ
  getIt.registerLazySingleton<GetAudioUrl>(
    () => GetAudioUrlImpl(getIt<QuranRepository>()),
  );

  // Quran BLoC
  getIt.registerFactory(
    () => QuranBloc(
      getAllSurahs: getIt<GetAllSurahs>(),
      getSurahByNumber: getIt<GetSurahByNumber>(),
      getJuzSurahs: getIt<GetJuzSurahs>(),
      getAyahTafsir: getIt<GetAyahTafsir>(),
      getReciters: getIt<quran_index_get_reciters.GetReciters>(),
      saveLastPosition: getIt<SaveLastPosition>(),
      getLastPosition: getIt<GetLastPosition>(),
      getAudioUrl: getIt<GetAudioUrl>(),
    ),
  );

  getIt.registerFactory(
    () => QuranSettingsCubit(
      getAvailableTafsirs: getIt<GetAvailableTafsirs>(),
      getAvailableReciters:
          getIt<quran_index_get_available_reciters.GetAvailableReciters>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Bookmark Feature
  getIt.registerLazySingleton<BookmarkLocalDataSource>(
    () => BookmarkLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<BookmarkRemoteDataSource>(
    () => BookmarkRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(
      remoteDataSource: getIt<BookmarkRemoteDataSource>(),
      localDataSource: getIt<BookmarkLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Bookmark Use Cases
  getIt.registerLazySingleton(() => AddBookmark(getIt<BookmarkRepository>()));
  getIt.registerLazySingleton(() => GetBookmarks(getIt<BookmarkRepository>()));
  getIt.registerLazySingleton(
    () => DeleteBookmark(getIt<BookmarkRepository>()),
  );
  getIt.registerLazySingleton(() => IsBookmarked(getIt<BookmarkRepository>()));
  getIt.registerLazySingleton(() => GetBookmarkId(getIt<BookmarkRepository>()));

  // Bookmark BLoC
  getIt.registerFactory(
    () => BookmarkBloc(
      addBookmark: getIt<AddBookmark>(),
      getBookmarks: getIt<GetBookmarks>(),
      deleteBookmark: getIt<DeleteBookmark>(),
      isBookmarked: getIt<IsBookmarked>(),
      getBookmarkId: getIt<GetBookmarkId>(),
    ),
  );

  // Prayer Times Feature
  getIt.registerLazySingleton<PrayerTimesLocalDataSource>(
    () => PrayerTimesLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(client: getIt<http.Client>()),
  );
  getIt.registerLazySingleton<PrayerTimesRepository>(
    () => PrayerTimesRepositoryImpl(
      remoteDataSource: getIt<PrayerTimesRemoteDataSource>(),
      localDataSource: getIt<PrayerTimesLocalDataSource>(),
    ),
  );

  // Prayer Times Use Cases
  getIt.registerLazySingleton(
    () => GetPrayerTimes(getIt<PrayerTimesRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCachedPrayerTimes(getIt<PrayerTimesRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetMuezzins(getIt<PrayerTimesRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSelectedMuezzinId(getIt<PrayerTimesRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveSelectedMuezzinId(getIt<PrayerTimesRepository>()),
  );

  // Prayer Times BLoC
  getIt.registerFactory(
    () => PrayerTimesBloc(
      getPrayerTimes: getIt<GetPrayerTimes>(),
      getCachedPrayerTimes: getIt<GetCachedPrayerTimes>(),
      getMuezzins: getIt<GetMuezzins>(),
      getSelectedMuezzinId: getIt<GetSelectedMuezzinId>(),
      saveSelectedMuezzinId: getIt<SaveSelectedMuezzinId>(),
    ),
  );

  // Hadith Feature
  getIt.registerLazySingleton<HadithRemoteDataSource>(
    () => HadithRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      firebaseService: getIt<FirebaseService>(),
    ),
  );
  getIt.registerLazySingleton<HadithLocalDataSource>(
    () => HadithLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<HadithRepository>(
    () => HadithRepositoryImpl(
      remoteDataSource: getIt<HadithRemoteDataSource>(),
      localDataSource: getIt<HadithLocalDataSource>(),
    ),
  );

  // Hadith Use Cases
  getIt.registerLazySingleton(() => GetCategories(getIt<HadithRepository>()));
  getIt.registerLazySingleton(
    () => GetHadithsByCategory(getIt<HadithRepository>()),
  );
  getIt.registerLazySingleton(() => GetHadithById(getIt<HadithRepository>()));
  getIt.registerLazySingleton(() => GetRandomHadith(getIt<HadithRepository>()));

  // Hadith BLoC
  getIt.registerFactory(
    () => HadithBloc(
      getCategories: getIt<GetCategories>(),
      getHadithsByCategory: getIt<GetHadithsByCategory>(),
      getHadithById: getIt<GetHadithById>(),
      getRandomHadith: getIt<GetRandomHadith>(),
    ),
  );

  // Azkar Feature
  getIt.registerLazySingleton<AzkarRemoteDataSource>(
    () => AzkarRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<AzkarLocalDataSource>(
    () =>
        AzkarLocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(
      remoteDataSource: getIt<AzkarRemoteDataSource>(),
      localDataSource: getIt<AzkarLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<AllahNamesRepository>(
    () => AllahNamesRepositoryImpl(
      remoteDataSource: getIt<AzkarRemoteDataSource>(),
      localDataSource: getIt<AzkarLocalDataSource>(),
    ),
  );

  // Azkar Use Cases
  getIt.registerLazySingleton(
    () => GetAzkarCategories(getIt<AzkarRepository>()),
  );
  getIt.registerLazySingleton(() => GetAzkarItems(getIt<AzkarRepository>()));
  getIt.registerLazySingleton(() => GetAzkarAudio(getIt<AzkarRepository>()));
  getIt.registerLazySingleton(
    () => GetAllahNames(getIt<AllahNamesRepository>()),
  );

  // Azkar BLoC
  getIt.registerFactory(
    () => AzkarBloc(
      getAzkarCategories: getIt<GetAzkarCategories>(),
      getAzkarItems: getIt<GetAzkarItems>(),
      getAzkarAudio: getIt<GetAzkarAudio>(),
      getAllahNames: getIt<GetAllahNames>(),
    ),
  );

  // Mosques Feature
  getIt.registerLazySingleton<MosquesRemoteDataSource>(
    () => MosquesRemoteDataSourceImpl(client: getIt<http.Client>()),
  );
  getIt.registerLazySingleton<MosquesLocalDataSource>(
    () => MosquesLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<MosqueRepository>(
    () => MosqueRepositoryImpl(
      remoteDataSource: getIt<MosquesRemoteDataSource>(),
      localDataSource: getIt<MosquesLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetNearbyMosques(getIt<MosqueRepository>()),
  );
  getIt.registerFactory(
    () => MosqueBloc(getNearbyMosques: getIt<GetNearbyMosques>()),
  );

  // Halal Restaurants Feature
  getIt.registerLazySingleton<HalalRestaurantsRemoteDataSource>(
    () => HalalRestaurantsRemoteDataSourceImpl(client: getIt<http.Client>()),
  );
  getIt.registerLazySingleton<HalalRestaurantsLocalDataSource>(
    () => HalalRestaurantsLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<HalalRestaurantsRepository>(
    () => HalalRestaurantsRepositoryImpl(
      remoteDataSource: getIt<HalalRestaurantsRemoteDataSource>(),
      localDataSource: getIt<HalalRestaurantsLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetNearbyHalalRestaurants(getIt<HalalRestaurantsRepository>()),
  );
  getIt.registerFactory(
    () => HalalRestaurantsBloc(
        getNearbyHalalRestaurants: getIt<GetNearbyHalalRestaurants>()),
  );

  // Assistant Feature
  getIt.registerLazySingleton<AssistantRemoteDataSource>(
    () => AssistantRemoteDataSourceImpl(client: getIt<http.Client>()),
  );
  getIt.registerLazySingleton<AssistantLocalDataSource>(
    () => AssistantLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(
      remoteDataSource: getIt<AssistantRemoteDataSource>(),
      localDataSource: getIt<AssistantLocalDataSource>(),
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // Assistant Use Cases
  getIt.registerLazySingleton(() => SendMessage(getIt<AssistantRepository>()));
  getIt.registerLazySingleton(
    () => GetChatHistory(getIt<AssistantRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateNewChat(getIt<AssistantRepository>()),
  );
  getIt.registerLazySingleton(() => GetChatList(getIt<AssistantRepository>()));

  // Assistant BLoC
  getIt.registerFactory(
    () => AssistantBloc(
      getChatHistory: getIt<GetChatHistory>(),
      sendMessage: getIt<SendMessage>(),
      createNewChat: getIt<CreateNewChat>(),
      getChatList: getIt<GetChatList>(),
      localDataSource: getIt<AssistantLocalDataSource>(),
    ),
  );

  // Hisn al-Muslim Feature
  getIt.registerLazySingleton<HisnMuslimLocalDataSource>(
    () => HisnMuslimLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<HisnMuslimRepository>(
    () => HisnMuslimRepositoryImpl(localDataSource: getIt<HisnMuslimLocalDataSource>()),
  );
  getIt.registerFactory(
    () => HisnMuslimBloc(repository: getIt<HisnMuslimRepository>()),
  );

  // ... existing imports ...

  // ====== Quran Audio Feature ======
  // Audio Player Service
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());

  // Audio Download Service
  getIt.registerLazySingleton<AudioDownloadService>(
    () => AudioDownloadServiceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
      client: getIt<http.Client>(),
    ),
  );

  // Quran Audio Data Sources
  getIt.registerLazySingleton<QuranAudioRemoteDataSource>(
    () => QuranAudioRemoteDataSourceImpl(client: getIt<http.Client>()),
  );

  getIt.registerLazySingleton<QuranAudioLocalDataSource>(
    () => QuranAudioLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Quran Audio Repository
  getIt.registerLazySingleton<QuranAudioRepository>(
    () => QuranAudioRepositoryImpl(
      remoteDataSource: getIt<QuranAudioRemoteDataSource>(),
      localDataSource: getIt<QuranAudioLocalDataSource>(),
      audioDownloadService: getIt<AudioDownloadService>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Quran Audio Use Cases
  getIt.registerLazySingleton(() => GetReciters(getIt<QuranAudioRepository>()));
  getIt.registerLazySingleton(() => GetSurahs(getIt<QuranAudioRepository>()));
  getIt.registerLazySingleton(
    () => GetRadioStations(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetAudioTrack(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveFavoriteReciter(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => AddToRecentlyPlayed(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => DownloadSurah(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetOfflineAudios(getIt<QuranAudioRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteOfflineAudio(getIt<QuranAudioRepository>()),
  );

  // Quran Audio BLoC
  getIt.registerFactory(
    () => QuranAudioBloc(
      getReciters: getIt<GetReciters>(),
      getSurahs: getIt<GetSurahs>(),
      getRadioStations: getIt<GetRadioStations>(),
      getAudioTrack: getIt<GetAudioTrack>(),
      saveFavoriteReciter: getIt<SaveFavoriteReciter>(),
      addToRecentlyPlayed: getIt<AddToRecentlyPlayed>(),
      downloadSurah: getIt<DownloadSurah>(),
      audioPlayerService: getIt<AudioPlayerService>(),
    ),
  );

  // Offline Audios Cubit
  getIt.registerFactory(
    () => OfflineAudiosCubit(
      getOfflineAudios: getIt<GetOfflineAudios>(),
      deleteOfflineAudio: getIt<DeleteOfflineAudio>(),
    ),
  );

  // Surah Download Cubit
  getIt.registerFactory(() => SurahDownloadCubit(getIt<DownloadSurah>()));

  // ====== Favorites Feature ======
  // ... rest of the file ...
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      remoteDataSource: getIt<FavoritesRemoteDataSource>(),
    ),
  );

  getIt.registerFactory(
    () => FavoritesBloc(repository: getIt<FavoritesRepository>()),
  );

  // ====== Subscription Feature ======
  getIt.registerLazySingleton<InAppPurchaseService>(
    () => InAppPurchaseService(),
  );

  getIt.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSourceImpl(
      firebaseService: getIt<FirebaseService>(),
    ),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localDataSource: getIt<SubscriptionLocalDataSource>(),
      iapService: getIt<InAppPurchaseService>(),
    ),
  );

  getIt.registerFactory(
    () => SubscriptionBloc(repository: getIt<SubscriptionRepository>()),
  );

  // ====== Theme Feature ======
  // Data Sources
  getIt.registerLazySingleton<ThemeLocalDataSource>(
    () =>
        ThemeLocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(localDataSource: getIt<ThemeLocalDataSource>()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetThemeSettings(getIt<ThemeRepository>()));
  getIt.registerLazySingleton(
    () => SaveThemeSettings(getIt<ThemeRepository>()),
  );
  getIt.registerLazySingleton(() => SaveThemeMode(getIt<ThemeRepository>()));

  // Cubit
  getIt.registerFactory(
    () => ThemeCubit(
      getThemeSettings: getIt<GetThemeSettings>(),
      saveThemeMode: getIt<SaveThemeMode>(),
    ),
  );

  // ====== Notification Settings ======
  getIt.registerFactory(
    () => NotificationSettingsCubit(
      getIt<SharedPreferences>(),
      PrayerNotificationService(),
    ),
  );

  // ====== Khatma Progress Feature ======
  getIt.registerLazySingleton<KhatmaProgressDataSource>(
    () => KhatmaProgressDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<KhatmaProgressRepository>(
    () => KhatmaProgressRepositoryImpl(
      dataSource: getIt<KhatmaProgressDataSource>(),
    ),
  );

  getIt.registerFactory(
    () => KhatmaProgressBloc(repository: getIt<KhatmaProgressRepository>()),
  );

  // ====== Quran Khatmah Feature (Refactored) ======
  getIt.registerLazySingleton<KhatmahRemoteDataSource>(
    () => KhatmahRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<KhatmahRepository>(
    () => KhatmahRepositoryImpl(dataSource: getIt<KhatmahRemoteDataSource>()),
  );

  getIt.registerLazySingleton(
    () => GetUserKhatmahProgressUseCase(getIt<KhatmahRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateKhatmahProgressUseCase(getIt<KhatmahRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPageDetailsUseCase(getIt<QuranRepository>()),
  );

  getIt.registerFactory(
    () => KhatmahBloc(
      getUserKhatmahProgress: getIt<GetUserKhatmahProgressUseCase>(),
      updateKhatmahProgress: getIt<UpdateKhatmahProgressUseCase>(),
      getPageDetails: getIt<GetPageDetailsUseCase>(),
    ),
  );

  // ====== Collective Khatma Feature ======
  // Data Source
  getIt.registerLazySingleton<CollectiveKhatmaRemoteDataSource>(
    () => CollectiveKhatmaRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<CollectiveKhatmaRepository>(
    () => CollectiveKhatmaRepositoryImpl(
      dataSource: getIt<CollectiveKhatmaRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => CreateKhatmaUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => JoinKhatmaUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => CompletePartUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetKhatmaDetailsUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetKhatmaByInviteLinkUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPublicKhatmasUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserCollectiveKhatmasUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserCreatedKhatmasUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetUserCompletedKhatmasCountUseCase(
      getIt<CollectiveKhatmaRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetUserReservedPartUseCase(getIt<CollectiveKhatmaRepository>()),
  );
  getIt.registerLazySingleton(
    () => WatchKhatmaUseCase(getIt<CollectiveKhatmaRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => CollectiveKhatmaBloc(
      createKhatma: getIt<CreateKhatmaUseCase>(),
      joinKhatma: getIt<JoinKhatmaUseCase>(),
      completePart: getIt<CompletePartUseCase>(),
      getKhatmaDetails: getIt<GetKhatmaDetailsUseCase>(),
      getKhatmaByInviteLink: getIt<GetKhatmaByInviteLinkUseCase>(),
      getPublicKhatmas: getIt<GetPublicKhatmasUseCase>(),
      getUserCollectiveKhatmas: getIt<GetUserCollectiveKhatmasUseCase>(),
      getUserCreatedKhatmas: getIt<GetUserCreatedKhatmasUseCase>(),
      getUserCompletedKhatmasCount:
          getIt<GetUserCompletedKhatmasCountUseCase>(),
      getUserReservedPart: getIt<GetUserReservedPartUseCase>(),
      watchKhatma: getIt<WatchKhatmaUseCase>(),
      repository: getIt<CollectiveKhatmaRepository>(),
    ),
  );
  // ====== Hajj & Umrah Feature ======
  getIt.registerLazySingleton<HajjUmrahLocalDataSource>(
    () => HajjUmrahLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<HajjUmrahRepository>(
    () => HajjUmrahRepositoryImpl(
      localDataSource: getIt<HajjUmrahLocalDataSource>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerFactory(
    () => HajjUmrahCubit(getIt<HajjUmrahRepository>()),
  );
}

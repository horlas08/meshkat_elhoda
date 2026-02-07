import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';

import '../../../../l10n/app_localizations.dart';

class TafsirDialog extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const TafsirDialog({
    Key? key,
    required this.surahNumber,
    required this.ayahNumber,
  }) : super(key: key);

  @override
  State<TafsirDialog> createState() => _TafsirDialogState();
}

class _TafsirDialogState extends State<TafsirDialog> {
  @override
  void initState() {
    super.initState();
    // اطلب التفسير لما الـ dialog يفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = getIt<SharedPreferences>();
      final tafsirId = prefs.getString('selected_tafsir_id');
      context.read<QuranBloc>().add(
        GetAyahTafsirEvent(
          surahNumber: widget.surahNumber,
          ayahNumber: widget.ayahNumber,
          language: 'ar',
          tafsirId: tafsirId,
        ),
      );
    });
  }

  void _closeDialog() {
    // استخدم ClearTafsirEvent بدلاً من ResetStateEvent
    context.read<QuranBloc>().add(ClearTafsirEvent());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _closeDialog();
      },
      child: Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: BlocConsumer<QuranBloc, QuranState>(
          listener: (context, state) {
            // إذا حدث خطأ، يمكن إضافة handling إضافي هنا
          },
          builder: (context, state) {
            if (state is Loading) {
              return _buildLoading();
            }

            if (state is TafsirLoaded) {
              return _buildTafsirContent(state);
            }

            if (state is Error) {
              return _buildError(state);
            }

            // الحالة الافتراضية - تظهر loading حتى يحمل التفسير
            return _buildLoading();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFD4A574)),
          SizedBox(height: 20),
          Text(
            localizations?.tafsirLoadingMessage ?? 'Loading tafsir...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirContent(TafsirLoaded state) {
    final ayahNum = widget.ayahNumber;
    final tafsirTxt = state.tafsir.text;
    final tafsirNm = state.tafsir.tafsirName;
    final localizations = AppLocalizations.of(context);

    log('Tafsir loaded for Surah ${widget.surahNumber}, Ayah $ayahNum');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: _closeDialog,
              ),
              Text(
                '${localizations?.tafsirOfAyah ?? "Tafsir of Ayah"} $ayahNum',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  //color: Colors.black87,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const Divider(height: 30, thickness: 1),

          // نص التفسير
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // اسم التفسير
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tafsirNm,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4A574),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // نص التفسير
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      tafsirTxt,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // زر الإغلاق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _closeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                localizations?.close ?? 'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Error state) {
    final localizations = AppLocalizations.of(context);
    log('Error fetching tafsir: ${state.message}');
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            localizations?.errorMessage ?? 'Error occurred',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _closeDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
            ),
            child: Text(localizations?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }
}

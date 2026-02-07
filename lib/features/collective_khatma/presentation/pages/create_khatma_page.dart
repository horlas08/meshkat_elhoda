import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/collective_khatma_entity.dart';
import '../bloc/collective_khatma_bloc.dart';
import '../bloc/collective_khatma_event.dart';
import '../bloc/collective_khatma_state.dart';

/// Page for creating a new collective khatma
class CreateKhatmaPage extends StatelessWidget {
  const CreateKhatmaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CollectiveKhatmaBloc>(),
      child: const _CreateKhatmaPageContent(),
    );
  }
}

class _CreateKhatmaPageContent extends StatefulWidget {
  const _CreateKhatmaPageContent();

  @override
  State<_CreateKhatmaPageContent> createState() =>
      _CreateKhatmaPageContentState();
}

class _CreateKhatmaPageContentState extends State<_CreateKhatmaPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  KhatmaType _selectedType = KhatmaType.public;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.createKhatmaTitle,
          style: AppTextStyles.surahName.copyWith(
            fontFamily: AppFonts.tajawal,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<CollectiveKhatmaBloc, CollectiveKhatmaState>(
        listener: (context, state) {
          if (state is KhatmaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.khatmaCreatedSuccess,
                  style: TextStyle(fontFamily: AppFonts.tajawal),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is CollectiveKhatmaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(fontFamily: AppFonts.tajawal),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                _buildSectionTitle(
                  AppLocalizations.of(context)!.khatmaTitleLabel,
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontFamily: AppFonts.tajawal),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.khatmaTitleExample,
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.tajawal,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.goldenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.khatmaTitleRequired;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Type Selection
                _buildSectionTitle(
                  AppLocalizations.of(context)!.khatmaTypeLabel,
                ),

                SizedBox(height: 8.h),
                Row(
                  children: [
                    // خيارات النوع
                    Expanded(
                      child: _buildTypeOption(
                        title: AppLocalizations.of(context)!.public,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.publicDescription,
                        icon: Icons.public,
                        isSelected: _selectedType == KhatmaType.public,
                        onTap: () =>
                            setState(() => _selectedType = KhatmaType.public),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTypeOption(
                        title: AppLocalizations.of(context)!.private,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.privateDescription,
                        icon: Icons.lock_outline,
                        isSelected: _selectedType == KhatmaType.private,
                        onTap: () =>
                            setState(() => _selectedType = KhatmaType.private),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Date Selection
                _buildSectionTitle(
                  AppLocalizations.of(context)!.dateRangeLabel,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: AppLocalizations.of(context)!.startDate,
                        date: _startDate,
                        onDateSelected: (date) {
                          setState(() {
                            _startDate = date;
                            if (_endDate.isBefore(_startDate)) {
                              _endDate = _startDate.add(
                                const Duration(days: 7),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDatePicker(
                        label: AppLocalizations.of(context)!.endDate,
                        date: _endDate,
                        firstDate: _startDate,
                        onDateSelected: (date) {
                          setState(() => _endDate = date);
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Duration Info
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.goldenColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.goldenColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.khatmaDuration.replaceAll(
                            '{0}',
                            _endDate.difference(_startDate).inDays.toString(),
                          ),
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 14.sp,
                            color: AppColors.goldenColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Create Button
                BlocBuilder<CollectiveKhatmaBloc, CollectiveKhatmaState>(
                  builder: (context, state) {
                    final isLoading = state is CollectiveKhatmaLoading;
                    return SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createKhatma,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldenColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                AppLocalizations.of(context)!.createKhatma,
                                style: TextStyle(
                                  fontFamily: AppFonts.tajawal,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.surahName.copyWith(
        fontFamily: AppFonts.tajawal,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldenColor.withValues(alpha: 0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.goldenColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: isSelected ? AppColors.goldenColor : Colors.grey,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.goldenColor : null,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 12.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    DateTime? firstDate,
    required Function(DateTime) onDateSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createKhatma() {
    if (_formKey.currentState!.validate()) {
      context.read<CollectiveKhatmaBloc>().add(
        CreateKhatmaEvent(
          title: _titleController.text.trim(),
          type: _selectedType,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }
  }
}

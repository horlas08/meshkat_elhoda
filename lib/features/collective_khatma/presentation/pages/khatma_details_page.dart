import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
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
import '../widgets/parts_grid.dart';
import '../widgets/khatma_progress_header.dart';

/// Page showing details of a specific khatma with parts grid
class KhatmaDetailsPage extends StatelessWidget {
  final String khatmaId;

  const KhatmaDetailsPage({super.key, required this.khatmaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CollectiveKhatmaBloc>()
        ..add(LoadKhatmaDetailsEvent(khatmaId))
        ..add(WatchKhatmaEvent(khatmaId)),
      child: _KhatmaDetailsPageContent(khatmaId: khatmaId),
    );
  }
}

class _KhatmaDetailsPageContent extends StatelessWidget {
  final String khatmaId;

  const _KhatmaDetailsPageContent({required this.khatmaId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: BlocBuilder<CollectiveKhatmaBloc, CollectiveKhatmaState>(
          builder: (context, state) {
            if (state is KhatmaLoaded) {
              return Text(
                state.khatma.title,
                style: AppTextStyles.surahName.copyWith(
                  fontFamily: AppFonts.tajawal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: isDark ? Colors.white : Colors.black,
                ),
              );
            }
            return Text(
              AppLocalizations.of(context)!.khatmaDetails,
              style: AppTextStyles.surahName.copyWith(
                fontFamily: AppFonts.tajawal,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CollectiveKhatmaBloc, CollectiveKhatmaState>(
            builder: (context, state) {
              if (state is KhatmaLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _handleMenuAction(context, value, state.khatma, user),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share),
                          SizedBox(width: 8.w),
                          Text(
                            AppLocalizations.of(context)!.share,
                            style: TextStyle(fontFamily: AppFonts.tajawal),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'copy_link',
                      child: Row(
                        children: [
                          const Icon(Icons.copy),
                          SizedBox(width: 8.w),
                          Text(
                            AppLocalizations.of(context)!.copyLink,
                            style: TextStyle(fontFamily: AppFonts.tajawal),
                          ),
                        ],
                      ),
                    ),

                    if (state.khatma.createdBy == user?.uid) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8.w),
                            Text(
                              AppLocalizations.of(context)!.deleteKhatma,
                              style: TextStyle(
                                fontFamily: AppFonts.tajawal,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CollectiveKhatmaBloc, CollectiveKhatmaState>(
        listener: (context, state) {
          if (state is KhatmaJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.partReservedSuccess(
                    state.partNumber.toString(),
                  ),
                  style: TextStyle(fontFamily: AppFonts.tajawal),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PartCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.partCompletedSuccess(
                    state.partNumber.toString(),
                  ),
                  style: TextStyle(fontFamily: AppFonts.tajawal),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is KhatmaDeleted) {
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
        builder: (context, state) {
          if (state is CollectiveKhatmaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KhatmaLoaded) {
            return _buildContent(context, state, user);
          }

          if (state is CollectiveKhatmaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(
                      fontFamily: AppFonts.tajawal,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CollectiveKhatmaBloc>().add(
                        LoadKhatmaDetailsEvent(khatmaId),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, KhatmaLoaded state, User? user) {
    final khatma = state.khatma;

    return Column(
      children: [
        // Progress Header
        KhatmaProgressHeader(khatma: khatma),

        // Parts Grid
        Expanded(
          child: PartsGrid(
            khatma: khatma,
            userReservedPart: state.userReservedPart,
            currentUserId: user?.uid,
            onPartSelected: (partNumber) {
              _showPartActionDialog(context, khatma, partNumber, state, user);
            },
          ),
        ),
      ],
    );
  }

  void _showPartActionDialog(
    BuildContext context,
    CollectiveKhatmaEntity khatma,
    int partNumber,
    KhatmaLoaded state,
    User? user,
  ) {
    final part = khatma.parts[partNumber - 1];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomContext) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: SizedBox(
            height: 300.h,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 24.h),

                // Part Number
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.goldenColor, AppColors.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$partNumber',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  AppLocalizations.of(
                    context,
                  )!.partNumber(partNumber.toString()),
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.tajawal,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),

                // Status
                if (part.isCompleted)
                  _buildStatusChip(
                    AppLocalizations.of(context)!.partCompletedStatus,
                    Colors.green,
                  )
                else if (part.isReserved)
                  _buildStatusChip(
                    AppLocalizations.of(context)!.reservedForUser(
                      part.userName ?? 'Unknown',
                    ),
                    Colors.orange,
                  )
                else
                  _buildStatusChip(
                    AppLocalizations.of(context)!.availableForReservation,
                    AppColors.goldenColor,
                  ),

                SizedBox(height: 24.h),

                // Actions
                if (user != null) ...[
                  // Allow users to reserve multiple parts
                  if (!part.isReserved)
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomContext);
                          context.read<CollectiveKhatmaBloc>().add(
                            JoinKhatmaEvent(
                              khatmaId: khatma.id,
                              partNumber: partNumber,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldenColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.reserveThisPart,
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (part.userId == user.uid && !part.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomContext);
                          context.read<CollectiveKhatmaBloc>().add(
                            CompletePartEvent(
                              khatmaId: khatma.id,
                              partNumber: partNumber,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.completeThisPart,
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.tajawal,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    CollectiveKhatmaEntity khatma,
    User? user,
  ) {
    switch (action) {
      case 'share':
        Share.share(
          '${AppLocalizations.of(context)!.joinedKhatmasTab}: "${khatma.title}"!\n\n${khatma.inviteLink}',
        );
        break;
      case 'copy_link':
        Clipboard.setData(ClipboardData(text: khatma.inviteLink));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.linkCopied,
              style: TextStyle(fontFamily: AppFonts.tajawal),
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, khatma);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CollectiveKhatmaEntity khatma,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteConfirmationTitle,
          style: TextStyle(fontFamily: AppFonts.tajawal),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteConfirmationMessage,
          style: TextStyle(fontFamily: AppFonts.tajawal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontFamily: AppFonts.tajawal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CollectiveKhatmaBloc>().add(
                DeleteKhatmaEvent(khatma.id),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(fontFamily: AppFonts.tajawal, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isPurchaseFlow = false;

  @override
  void initState() {
    super.initState();
    // Load products when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionBloc>().add(LoadProductsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Localizations not available',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final s = localizations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.blacColor : AppColors.whiteColor,
      appBar: AppBar(
        title: Text(s.upgradeAccount),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            _isPurchaseFlow = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SubscriptionLoaded &&
              state.subscription.isPremium &&
              _isPurchaseFlow) {
            _isPurchaseFlow = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Success'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final subTitleStyle = AppTextStyles.surahName.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.whiteColor.withOpacity(0.7)
                : AppColors.blacColor.withOpacity(0.7),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(s),
                SizedBox(height: 30.h),
                _buildFeaturesList(s, isDark, subTitleStyle),
                SizedBox(height: 40.h),
                if (state is SubscriptionLoading || state is PurchaseProcessing)
                  const Center(child: CircularProgressIndicator())
                else if (state is SubscriptionLoaded)
                  Column(
                    children: [
                      if (state.subscription.isPremium)
                        Container(
                          padding: EdgeInsets.all(16.r),
                          margin: EdgeInsets.only(bottom: 20.h),
                          decoration: BoxDecoration(
                            color: AppColors.goldenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: AppColors.goldenColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stars, color: AppColors.goldenColor),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  'You are already a premium subscriber',
                                  style: AppTextStyles.surahName.copyWith(
                                    fontSize: 16.sp,
                                    color: AppColors.goldenColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildProductsList(
                        context,
                        state.products,
                        s,
                        isDark,
                        subTitleStyle,
                      ),
                    ],
                  )
                else
                  Center(
                    child: Column(
                      children: [
                        Text(s.errorLoadingData),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          onPressed: () => context.read<SubscriptionBloc>().add(
                            LoadProductsEvent(),
                          ),
                          child: Text(s.retry),
                        ),
                      ],
                    ),
                  ),
                /*SizedBox(height: 20.h),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isPurchaseFlow = true;
                    });
                    context.read<SubscriptionBloc>().add(
                      RestorePurchasesEvent(),
                    );
                  },
                  child: Text(
                    s.manageSubscription,
                    style: TextStyle(color: AppColors.goldenColor),
                  ),
                ),*/
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations s) {
    return Column(
      children: [
        Icon(Icons.star_rounded, size: 80.r, color: AppColors.goldenColor),
        SizedBox(height: 10.h),
        Text(
          s.premiumSubscription,
          style: AppTextStyles.surahName.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          s.appTitle,
          style: AppTextStyles.surahName.copyWith(
            fontSize: 16.sp,
            color: AppColors.goldenColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(
    AppLocalizations s,
    bool isDark,
    TextStyle subTitleStyle,
  ) {
    final subscriptionFeatures = [
      s.featureRemoveAds,
      s.featureUnlockReciters, 
      s.featureDownloadContent,
    ];

    return Column(
      children: subscriptionFeatures
          .map(
            (feature) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.goldenColor,
                    size: 24.r,
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: subTitleStyle.copyWith(
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blacColor,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    List<ProductDetails> products,
    AppLocalizations s,
    bool isDark,
    TextStyle subTitleStyle,
  ) {
    if (products.isEmpty) {
      return Text(s.noProductsAvailable);
    }

    return Column(
      children: products
          .map(
            (product) =>
                _buildProductCard(context, product, s, isDark, subTitleStyle),
          )
          .toList(),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductDetails product,
    AppLocalizations s,
    bool isDark,
    TextStyle subTitleStyle,
  ) {
    // Check for yearly subscription (Android: yearly, iOS: premium_yearly)
    bool isYearly =
        product.id.contains('yearly') || product.id == 'premium_yearly';

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.blacColor : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.goldenColor,
          width: isYearly ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isPurchaseFlow = true;
          });
          context.read<SubscriptionBloc>().add(BuySubscriptionEvent(product));
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isYearly)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldenColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        s.mostSaving,
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ),
                  Text(
                    isYearly ? s.yearlySubscription : s.monthlySubscription,
                    style: AppTextStyles.surahName.copyWith(fontSize: 18.sp),
                  ),
                  Text(
                    product.description,
                    style: subTitleStyle.copyWith(fontSize: 12.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.price,
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 20.sp,
                    color: AppColors.goldenColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isYearly
                      ? "/ ${s.yearlySubscription}"
                      : "/ ${s.monthlySubscription}",
                  style: subTitleStyle.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsLinks(AppLocalizations s) {
    return Column(
      children: [
        Text(
          "يتم تجديد الاشتراك تلقائياً ما لم يتم إلغاؤه",
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Add privacy policy link
              },
              child: Text(s.privacyPolicy, style: TextStyle(fontSize: 10.sp)),
            ),
            Text(
              "|",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                // TODO: Add terms of use link
              },
              child: Text(s.termsOfUse, style: TextStyle(fontSize: 10.sp)),
            ),
          ],
        ),
      ],
    );
  }
}

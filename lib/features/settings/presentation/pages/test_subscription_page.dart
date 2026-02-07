import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/domain/entities/user_subscription_entity.dart';

class TestSubscriptionPage extends StatefulWidget {
  const TestSubscriptionPage({Key? key}) : super(key: key);

  @override
  State<TestSubscriptionPage> createState() => _TestSubscriptionPageState();
}

class _TestSubscriptionPageState extends State<TestSubscriptionPage> {
  @override
  void initState() {
    super.initState();
    // تحميل الاشتراك الحالي
    context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 اختبار الاشتراكات'),
        backgroundColor: Colors.deepPurple,
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: QuranLottieLoading());
          }

          if (state is SubscriptionLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // تنبيه
                  _buildWarningCard(),
                  const SizedBox(height: 16),

                  // عرض حالة الاشتراك الحالية
                  _buildCurrentSubscriptionCard(state),
                  const SizedBox(height: 24),

                  // أزرار الاختبار الوهمية
                  const Text(
                    '🎮 اختبار وهمي (بدون دفع حقيقي)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اضغط على أي زر لمحاكاة الشراء وتحديث Firebase',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // زر الاشتراك الشهري
                  _buildMockSubscriptionButton(
                    context,
                    title: '📅 اشتراك شهري',
                    subtitle: 'محاكاة شراء اشتراك شهري',
                    price: '\$2.99',
                    type: 'monthly',
                    days: 30,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  // زر الاشتراك السنوي
                  _buildMockSubscriptionButton(
                    context,
                    title: '🎯 اشتراك سنوي',
                    subtitle: 'محاكاة شراء اشتراك سنوي',
                    price: '\$19.99',
                    type: 'yearly',
                    days: 365,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 12),

                  // زر إلغاء الاشتراك
                  _buildMockCancelButton(context),

                  const SizedBox(height: 24),

                  // معلومات Firebase
                  _buildFirebaseInfoCard(state),
                ],
              ),
            );
          }

          return const Center(child: Text('حدث خطأ ما'));
        },
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضع الاختبار الوهمي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'هذه محاكاة للاختبار فقط. لن يتم خصم أي أموال.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionLoaded state) {
    final subscription = state.subscription;
    final isActive = subscription.type != 'free';

    return Card(
      elevation: 4,
      color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.info_outline,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'الاشتراك الحالي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.green.shade900
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('النوع', _getSubscriptionTypeName(subscription.type)),
            if (subscription.expireAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('ينتهي في', _formatDate(subscription.expireAt!)),
              const SizedBox(height: 12),
              _buildInfoRow(
                'الأيام المتبقية',
                _getDaysRemaining(subscription.expireAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMockSubscriptionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required String type,
    required int days,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _simulatePurchase(context, type, days),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type == 'monthly'
                      ? Icons.calendar_month
                      : Icons.calendar_today,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '+$days يوم',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockCancelButton(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: InkWell(
        onTap: () => _simulateCancel(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cancel, color: Colors.red, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ إلغاء الاشتراك',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'محاكاة إلغاء الاشتراك والعودة للمجاني',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirebaseInfoCard(SubscriptionLoaded state) {
    final subscription = state.subscription;
    final jsonData =
        '''
{
  "subscription": {
    "type": "${subscription.type}",
    "expiresAt": "${subscription.expireAt?.toIso8601String() ?? 'null'}"
  }
}''';

    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Colors.orange.shade300),
                const SizedBox(width: 8),
                const Text(
                  'البيانات في Firebase',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                jsonData,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePurchase(BuildContext context, String type, int days) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('محاكاة شراء $type'),
        content: Text(
          'سيتم تحديث Firebase بالبيانات التالية:\n\n'
          'النوع: $type\n'
          'تاريخ الانتهاء: بعد $days يوم من الآن\n\n'
          'هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // حساب تاريخ الانتهاء
              final expiryDate = DateTime.now().add(Duration(days: days));

              // إنشاء اشتراك جديد
              final subscription = UserSubscriptionEntity(
                type: type,
                expireAt: expiryDate,
              );

              // حفظ في Firebase
              context.read<SubscriptionBloc>().repository.saveSubscription(
                subscription,
              );

              // إعادة تحميل الاشتراك
              context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());

              // إظهار رسالة نجاح
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم تحديث الاشتراك إلى $type'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _simulateCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text(
          'سيتم تحديث Firebase إلى:\n\n'
          'النوع: free\n'
          'تاريخ الانتهاء: null\n\n'
          'هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // إنشاء اشتراك مجاني
              const subscription = UserSubscriptionEntity(
                type: 'free',
                expireAt: null,
              );

              // حفظ في Firebase
              context.read<SubscriptionBloc>().repository.saveSubscription(
                subscription,
              );

              // إعادة تحميل الاشتراك
              context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());

              // إظهار رسالة نجاح
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إلغاء الاشتراك'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionTypeName(String type) {
    switch (type) {
      case 'monthly':
        return '📅 شهري';
      case 'yearly':
        return '🎯 سنوي';
      case 'premium':
        return '⭐ مميز';
      case 'free':
        return '🆓 مجاني';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysRemaining(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference < 0) {
      return 'منتهي';
    } else if (difference == 0) {
      return 'ينتهي اليوم';
    } else {
      return '$difference يوم';
    }
  }
}

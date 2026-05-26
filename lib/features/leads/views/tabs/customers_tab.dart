import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../controllers/leads_controller.dart';
import '../../models/lead_model.dart';
import '../lead_details_screen.dart';

class CustomersTab extends StatelessWidget {
  const CustomersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeadsController>();

    return Column(
      children: [
        // ── Search Customers Bar ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: const InputDecoration(
                      hintText: 'Search customers...',
                      hintStyle: TextStyle(color: AppColors.textColorHint, fontSize: 14),
                      prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Symmetrical Ledger List ──
        Expanded(
          child: Obx(() {
            final customers = controller.leads.where((l) => l.leadStatus == 'Converted').toList();
            
            // Apply search query
            var filtered = customers;
            if (controller.searchQuery.value.isNotEmpty) {
              final q = controller.searchQuery.value.toLowerCase();
              filtered = customers.where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.companyName.toLowerCase().contains(q)
              ).toList();
            }

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.user_tick, size: 40, color: AppColors.successColor),
                    ),
                    const SizedBox(height: 16),
                    const AppText('No Converted Customers', fontSize: 15, fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    const AppText(
                      'Convert leads to see them listed in the ledger accounts.',
                      fontSize: 11,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];
                return _CustomerCardItem(customer: customer);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CustomerCardItem extends StatelessWidget {
  final Lead customer;
  const _CustomerCardItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    final formattedVal = "₹${_formatAmount(customer.dealValue?.toInt() ?? customer.estimatedValue.toInt())}";
    final formattedDate = customer.conversionDate != null 
        ? DateFormat('dd MMMM yyyy').format(customer.conversionDate!)
        : DateFormat('dd MMMM yyyy').format(customer.expectedClosingDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // View customer lead details directly
            final controller = Get.find<LeadsController>();
            controller.selectedLead.value = customer;
            controller.selectedTabIdx.value = 0;
            Get.to(() => const LeadDetailsScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Initials Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successColor.withValues(alpha: 0.15),
                        AppColors.infoColor.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                  child: Center(
                    child: AppText(
                      customer.name.substring(0, 2).toUpperCase(),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        customer.name,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        customer.companyName,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorSecondary,
                      ),
                    ],
                  ),
                ),

                // Deal Details Right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      formattedVal,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.successColor,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      formattedDate,
                      fontSize: 10,
                      color: AppColors.textColorHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount < 1000) return amount.toString();
    final str = amount.toString();
    var result = '';
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count == 3 && i > 0) {
        result = ',$result';
        count = 0;
      } else if (count == 2 && i > 0 && result.contains(',')) {
        result = ',$result';
        count = 0;
      }
    }
    return result;
  }
}

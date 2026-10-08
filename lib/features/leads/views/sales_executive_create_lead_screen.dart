import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class SalesExecutiveCreateLeadScreen extends StatefulWidget {
  const SalesExecutiveCreateLeadScreen({super.key});

  @override
  State<SalesExecutiveCreateLeadScreen> createState() => _SalesExecutiveCreateLeadScreenState();
}

class _SalesExecutiveCreateLeadScreenState extends State<SalesExecutiveCreateLeadScreen> {
  // Common styles to match the provided UI
  final Color _sectionTitleColor = AppColors.primaryColor; 
  final Color _labelColor = const Color(0xFF1E293B);
  final Color _hintColor = const Color(0xFF94A3B8);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _bgColor = const Color(0xFFF8FAFC); // Very light greyish-blue for fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Add / Edit Lead',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              _showSuccessAndPop();
            },
            child: AppText(
              'Save',
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    'Cancel',
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    _showSuccessAndPop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const AppText(
                    'Save Lead',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildLabeledTextField(label: 'Full Name *', hint: 'e.g. Rohan Mehta'),
                const SizedBox(height: 16),
                _buildLabeledTextField(label: 'Company Name', hint: 'e.g. Mehta Enterprises'),
                const SizedBox(height: 16),
                _buildLabeledTextField(label: 'Email', hint: 'e.g. rohan.mehta@mehta.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildLabeledTextField(label: 'Mobile Number *', hint: 'e.g. 9876543210', keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildLabeledTextField(label: 'Designation', hint: 'e.g. Proprietor'),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Lead Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildLabeledDropdown(label: 'Lead Source *', hint: 'Select Lead Source'),
                const SizedBox(height: 16),
                _buildLabeledDropdown(label: 'Lead Status *', hint: 'Select Lead Status'),
                const SizedBox(height: 16),
                _buildLabeledDropdown(label: 'Assign to *', hint: 'Select Sales Representative'),
              ],
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 12),
            _buildWhiteContainer(
              children: [
                _buildLabeledTextField(
                  label: 'Location',
                  hint: 'e.g. Mumbai, Maharashtra',
                  suffixIcon: Iconsax.location,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  label: 'Estimated Value',
                  hint: 'e.g. 2,50,000',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  label: 'Expected Closing Date',
                  hint: 'Select Date',
                  suffixIcon: Iconsax.calendar_1,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                  label: 'Notes',
                  hint: 'Interested in our premium product...',
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSuccessAndPop() {
    Get.back();
    Get.snackbar(
      'Lead Saved',
      'The lead has been successfully added to your CRM.',
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: _sectionTitleColor,
    );
  }

  Widget _buildWhiteContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    IconData? suffixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _hintColor, fontSize: 13, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFF64748B), size: 18)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, fontWeight: FontWeight.bold, color: _labelColor),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: AppText(hint, fontSize: 13, color: _hintColor),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: const [],
              onChanged: (value) {},
            ),
          ),
        ),
      ],
    );
  }
}

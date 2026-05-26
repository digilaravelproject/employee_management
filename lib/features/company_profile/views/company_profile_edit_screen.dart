import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/company_profile_controller.dart';
import '../models/company_profile_model.dart';

class CompanyProfileEditScreen extends StatefulWidget {
  const CompanyProfileEditScreen({super.key});

  @override
  State<CompanyProfileEditScreen> createState() => _CompanyProfileEditScreenState();
}

class _CompanyProfileEditScreenState extends State<CompanyProfileEditScreen> {
  final controller = Get.find<CompanyProfileController>();
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController taglineController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController websiteController;
  late TextEditingController addressController;
  late TextEditingController aboutController;
  late TextEditingController visionController;
  late TextEditingController missionController;

  final selectedIndustry = ''.obs;
  final selectedCompanySize = ''.obs;
  final selectedFoundedYear = 2015.obs;
  final aboutLength = 0.obs;

  @override
  void initState() {
    super.initState();
    final profile = controller.profile.value;

    nameController = TextEditingController(text: profile.name);
    taglineController = TextEditingController(text: profile.tagline);
    emailController = TextEditingController(text: profile.email);
    phoneController = TextEditingController(text: profile.phone);
    websiteController = TextEditingController(text: profile.website);
    addressController = TextEditingController(text: profile.address);
    aboutController = TextEditingController(text: profile.about);
    visionController = TextEditingController(text: profile.vision);
    missionController = TextEditingController(text: profile.mission);

    selectedIndustry.value = profile.industry;
    selectedCompanySize.value = profile.companySize;
    selectedFoundedYear.value = profile.foundedYear;
    aboutLength.value = profile.about.length;
  }

  @override
  void dispose() {
    nameController.dispose();
    taglineController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    addressController.dispose();
    aboutController.dispose();
    visionController.dispose();
    missionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (formKey.currentState!.validate()) {
      controller.saveProfile(
        name: nameController.text.trim(),
        tagline: taglineController.text.trim(),
        industry: selectedIndustry.value,
        companySize: selectedCompanySize.value,
        foundedYear: selectedFoundedYear.value,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        website: websiteController.text.trim(),
        address: addressController.text.trim(),
        about: aboutController.text.trim(),
        vision: visionController.text.trim(),
        mission: missionController.text.trim(),
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textColorPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'Add / Edit Company Profile',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textColorPrimary,
            ),
            const SizedBox(height: 2),
            const AppText(
              'Update your company information',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textColorHint,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // AppBar Save Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _onSave,
              child: const AppText(
                'Save',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── I. BASIC INFORMATION GROUP ───
                const _FormSectionTitle(title: 'Basic Information'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo picker (centered, clean and spacious)
                      Center(
                        child: Column(
                          children: [
                            const AppText('Company Logo', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textColorPrimary),
                            const SizedBox(height: 8),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Obx(() => Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.slate50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.slate200, width: 1.5),
                                        image: DecorationImage(
                                          image: NetworkImage(controller.tempLogoUrl.value),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () => controller.changeLogo(),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'JPG, PNG or SVG (Max. 2MB)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textColorHint,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Company Name
                      AppInputField(
                        controller: nameController,
                        label: 'Company Name',
                        isRequired: true,
                        hint: 'e.g. TechNova Solutions Pvt. Ltd.',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Company Name field is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tagline
                      AppInputField(
                        controller: taglineController,
                        label: 'Tagline',
                        hint: 'e.g. Innovating Tomorrow, Together.',
                      ),
                      const SizedBox(height: 16),

                      // Industry Dropdown
                      Obx(() => CustomBottomSheetDropdown(
                            label: 'Industry',
                            selectedValue: selectedIndustry.value,
                            items: controller.industries,
                            onChanged: (val) {
                              selectedIndustry.value = val;
                            },
                          )),
                      const SizedBox(height: 16),

                      // Company Size Dropdown
                      Obx(() => CustomBottomSheetDropdown(
                            label: 'Company Size',
                            selectedValue: selectedCompanySize.value,
                            items: controller.companySizes,
                            onChanged: (val) {
                              selectedCompanySize.value = val;
                            },
                          )),
                      const SizedBox(height: 16),

                      // Founded Year picker
                      Obx(() => _buildFoundedYearField(
                            context: context,
                            label: 'Founded Year',
                            value: selectedFoundedYear.value,
                            onChanged: (val) {
                              selectedFoundedYear.value = val;
                            },
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ─── II. CONTACT INFORMATION GROUP ───
                const _FormSectionTitle(title: 'Contact Information'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      AppInputField(
                        controller: emailController,
                        label: 'Email',
                        isRequired: true,
                        hint: 'e.g. info@technova.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email field is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      AppInputField(
                        controller: phoneController,
                        label: 'Phone',
                        isRequired: true,
                        hint: 'e.g. +91 98765 43210',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone field is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Website
                      AppInputField(
                        controller: websiteController,
                        label: 'Website',
                        hint: 'e.g. www.technova.com',
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),

                      // Address with Pin Suffix
                      AppInputField(
                        controller: addressController,
                        label: 'Address',
                        isRequired: true,
                        hint: 'Enter full address details...',
                        maxLines: 2,
                        suffixIcon: const Icon(Iconsax.location, color: AppColors.textColorHint, size: 18),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address field is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ─── III. COMPANY DETAILS GROUP ───
                const _FormSectionTitle(title: 'Company Details'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Company (with Character Limit Counter)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              AppText('About Company', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textColorPrimary),
                              AppText(' *', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.errorColor),
                            ],
                          ),
                          Obx(() => AppText(
                                '${aboutLength.value}/500',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: aboutLength.value > 500 ? AppColors.errorColor : AppColors.textColorSecondary,
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: aboutController,
                        maxLines: 4,
                        maxLength: 500,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                        decoration: InputDecoration(
                          hintText: 'Describe your company vision, services and domain...',
                          hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12.5),
                          counterText: '',
                          contentPadding: const EdgeInsets.all(12),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          aboutLength.value = val.length;
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'About Company description is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vision Statement
                      AppInputField(
                        controller: visionController,
                        label: 'Vision',
                        isRequired: true,
                        hint: 'To be a global leader in delivering...',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vision field is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mission Statement
                      AppInputField(
                        controller: missionController,
                        label: 'Mission',
                        isRequired: true,
                        hint: 'To empower businesses through technology...',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mission field is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ─── IV. DYNAMIC SOCIAL LINKS GROUP ───
                const _FormSectionTitle(title: 'Social Links'),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.tempSocialLinks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = controller.tempSocialLinks[index];
                              return _buildSocialRowItem(index, item);
                            },
                          )),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => controller.addSocialLink(),
                        icon: const Icon(Icons.add, color: AppColors.primaryColor, size: 16),
                        label: const AppText(
                          'Add More Link',
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── INPUT BOX DECORATION HELPER ──
  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.slate200),
    );
  }



  // ── FOUNDED YEAR FIELD BUILDER ──
  Widget _buildFoundedYearField({
    required BuildContext context,
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textColorPrimary),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now().year;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const AppText('Select Founded Year', fontSize: 14, fontWeight: FontWeight.w800),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: YearPicker(
                    firstDate: DateTime(1900),
                    lastDate: DateTime(now),
                    selectedDate: DateTime(value),
                    onChanged: (dateTime) {
                      onChanged(dateTime.year);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            );
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('$value', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
                const Icon(Iconsax.calendar_1, color: AppColors.textColorHint, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── DYNAMIC SOCIAL LINK ROW FIELD BUILDER ──
  Widget _buildSocialRowItem(int index, SocialLink item) {
    final linkTextController = TextEditingController(text: item.url);
    linkTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: linkTextController.text.length),
    );

    return Row(
      children: [
        _buildDynamicBrandIcon(item.url),
        const SizedBox(width: 10),

        // URL input text field
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextFormField(
              controller: linkTextController,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textColorPrimary),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),
              onChanged: (val) {
                String plat = item.platform;
                final lower = val.toLowerCase();
                if (lower.contains('linkedin')) {
                  plat = 'LinkedIn';
                } else if (lower.contains('twitter') || lower.contains('x.com')) {
                  plat = 'Twitter';
                } else if (lower.contains('facebook')) {
                  plat = 'Facebook';
                }
                controller.updateSocialLink(index, platform: plat, url: val);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Remove row icon button
        GestureDetector(
          onTap: () => controller.removeSocialLink(index),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.errorColorAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: AppColors.errorColor, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicBrandIcon(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('linkedin')) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF0077B5),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: const Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      );
    } else if (lower.contains('twitter') || lower.contains('x.com')) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: const Text(
          '𝕏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (lower.contains('facebook')) {
      return const Icon(
        Icons.facebook,
        color: Color(0xFF1877F2),
        size: 24,
      );
    }
    return const Icon(
      Iconsax.link,
      color: AppColors.textColorHint,
      size: 22,
    );
  }
}

// ── CORE SUB-HEADER ──
class _FormSectionTitle extends StatelessWidget {
  final String title;

  const _FormSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppText(
      title,
      fontSize: 13.5,
      fontWeight: FontWeight.w800,
      color: AppColors.primaryColor,
    );
  }
}

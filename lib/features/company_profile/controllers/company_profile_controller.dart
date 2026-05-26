import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/company_profile_model.dart';

class CompanyProfileController extends GetxController {
  // Main reactive company profile state
  final profile = CompanyProfile(
    logoUrl: 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=200&auto=format&fit=crop&q=80',
    name: 'TechNova Solutions Pvt. Ltd.',
    tagline: 'Innovating Tomorrow, Together.',
    isVerified: true,
    industry: 'Information Technology',
    companySize: '201 - 500',
    foundedYear: 2015,
    email: 'info@technova.com',
    phone: '+91 98765 43210',
    website: 'www.technova.com',
    address: '123, Tech Park, Sector 62, Noida, Uttar Pradesh - 201309, India',
    about: 'TechNova Solutions is a leading IT services and consulting company specializing in digital transformation, cloud solutions, and enterprise software development. We help businesses innovate and grow in the digital era.',
    vision: 'To be a global leader in delivering innovative technology solutions.',
    mission: 'To empower businesses through technology and drive sustainable growth.',
    socialLinks: [
      SocialLink(platform: 'LinkedIn', url: 'https://linkedin.com/company/technova'),
      SocialLink(platform: 'Twitter', url: 'https://twitter.com/technova'),
      SocialLink(platform: 'Facebook', url: 'https://facebook.com/technova'),
    ],
  ).obs;

  // Available options for dropdowns
  final List<String> industries = [
    'Information Technology',
    'Finance & Banking',
    'Healthcare & Biotech',
    'Education & E-Learning',
    'Manufacturing & Logistics',
    'Real Estate',
  ];

  final List<String> companySizes = [
    '1 - 10',
    '11 - 50',
    '51 - 200',
    '201 - 500',
    '501 - 1000',
    '1000+',
  ];

  // Temporary editing state
  final tempSocialLinks = <SocialLink>[].obs;
  final tempLogoUrl = ''.obs;

  void initializeEditing() {
    tempSocialLinks.value = List.from(profile.value.socialLinks);
    tempLogoUrl.value = profile.value.logoUrl;
  }

  void addSocialLink() {
    tempSocialLinks.add(SocialLink(platform: 'LinkedIn', url: ''));
  }

  void removeSocialLink(int index) {
    if (index >= 0 && index < tempSocialLinks.length) {
      tempSocialLinks.removeAt(index);
    }
  }

  void updateSocialLink(int index, {String? platform, String? url}) {
    if (index >= 0 && index < tempSocialLinks.length) {
      tempSocialLinks[index] = tempSocialLinks[index].copyWith(
        platform: platform,
        url: url,
      );
    }
  }

  void changeLogo() {
    // Gracefully toggle between two mock logo links for UI demonstration
    if (tempLogoUrl.value.contains('photo-1560179707')) {
      tempLogoUrl.value = 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=200&auto=format&fit=crop&q=80';
    } else {
      tempLogoUrl.value = 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=200&auto=format&fit=crop&q=80';
    }
  }

  void saveProfile({
    required String name,
    required String tagline,
    required String industry,
    required String companySize,
    required int foundedYear,
    required String email,
    required String phone,
    required String website,
    required String address,
    required String about,
    required String vision,
    required String mission,
  }) {
    profile.value = CompanyProfile(
      logoUrl: tempLogoUrl.value,
      name: name,
      tagline: tagline,
      isVerified: true, // Remains verified
      industry: industry,
      companySize: companySize,
      foundedYear: foundedYear,
      email: email,
      phone: phone,
      website: website,
      address: address,
      about: about,
      vision: vision,
      mission: mission,
      socialLinks: List.from(tempSocialLinks),
    );
    
    Get.snackbar(
      'Profile Saved',
      'Company information updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981), // Success Color
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}

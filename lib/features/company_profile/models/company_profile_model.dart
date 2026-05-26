class SocialLink {
  final String platform;
  final String url;

  SocialLink({required this.platform, required this.url});

  SocialLink copyWith({String? platform, String? url}) {
    return SocialLink(
      platform: platform ?? this.platform,
      url: url ?? this.url,
    );
  }
}

class CompanyProfile {
  final String logoUrl;
  final String name;
  final String tagline;
  final bool isVerified;
  final String industry;
  final String companySize;
  final int foundedYear;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String about;
  final String vision;
  final String mission;
  final List<SocialLink> socialLinks;

  CompanyProfile({
    required this.logoUrl,
    required this.name,
    required this.tagline,
    required this.isVerified,
    required this.industry,
    required this.companySize,
    required this.foundedYear,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.about,
    required this.vision,
    required this.mission,
    required this.socialLinks,
  });

  CompanyProfile copyWith({
    String? logoUrl,
    String? name,
    String? tagline,
    bool? isVerified,
    String? industry,
    String? companySize,
    int? foundedYear,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? about,
    String? vision,
    String? mission,
    List<SocialLink>? socialLinks,
  }) {
    return CompanyProfile(
      logoUrl: logoUrl ?? this.logoUrl,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      isVerified: isVerified ?? this.isVerified,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      foundedYear: foundedYear ?? this.foundedYear,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      about: about ?? this.about,
      vision: vision ?? this.vision,
      mission: mission ?? this.mission,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}

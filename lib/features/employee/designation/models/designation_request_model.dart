class DesignationRequestModel {
  final String name;
  final String hierarchyLevel;
  final List<String> skills;

  DesignationRequestModel({
    required this.name,
    required this.hierarchyLevel,
    required this.skills,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "hierarchy_level": hierarchyLevel.toLowerCase(),
      "skills": skills,
    };
  }
}

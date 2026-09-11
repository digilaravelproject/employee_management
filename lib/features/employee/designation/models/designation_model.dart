class DesignationModel {
  final String id;
  final String name;
  final String hierarchyLevel; // 'Junior', 'Senior', 'Manager'
  final List<String> skills;

  DesignationModel({
    required this.id,
    required this.name,
    required this.hierarchyLevel,
    this.skills = const [],
  });
}

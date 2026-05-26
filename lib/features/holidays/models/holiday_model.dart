class Holiday {
  final String id;
  final String name;
  final DateTime date;
  final String type; // 'National Holiday', 'Optional Holiday', 'Restricted Holiday'
  final String location; // 'All Locations' or other specific office branches
  final bool repeatEveryYear;
  final String description;
  final String addedBy;
  final DateTime addedOn;

  const Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.location,
    required this.repeatEveryYear,
    required this.description,
    required this.addedBy,
    required this.addedOn,
  });

  Holiday copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? type,
    String? location,
    bool? repeatEveryYear,
    String? description,
    String? addedBy,
    DateTime? addedOn,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      location: location ?? this.location,
      repeatEveryYear: repeatEveryYear ?? this.repeatEveryYear,
      description: description ?? this.description,
      addedBy: addedBy ?? this.addedBy,
      addedOn: addedOn ?? this.addedOn,
    );
  }
}

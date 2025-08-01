class Organization {
  final String orgId;
  final String name;
  final String description;
  final String? contactEmail;
  final bool isPublic;

  Organization({
    required this.orgId,
    required this.name,
    required this.description,
    this.contactEmail,
    this.isPublic = false,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['org_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      contactEmail: json['contact_email'],
      isPublic: json['is_public'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'org_id': orgId,
    'name': name,
    'description': description,
    if (contactEmail != null) 'contact_email': contactEmail,
    'is_public': isPublic,
  };
}

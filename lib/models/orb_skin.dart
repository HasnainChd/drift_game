class OrbSkin {
  final String id;
  final String name;
  final int unlockScoreThreshold;
  final int primaryColorValue;
  final int glowColorValue;
  final bool isUnlocked;

  OrbSkin({
    required this.id,
    required this.name,
    required this.unlockScoreThreshold,
    required this.primaryColorValue,
    required this.glowColorValue,
    required this.isUnlocked,
  });

  OrbSkin copyWith({
    String? id,
    String? name,
    int? unlockScoreThreshold,
    int? primaryColorValue,
    int? glowColorValue,
    bool? isUnlocked,
  }) {
    return OrbSkin(
      id: id ?? this.id,
      name: name ?? this.name,
      unlockScoreThreshold: unlockScoreThreshold ?? this.unlockScoreThreshold,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      glowColorValue: glowColorValue ?? this.glowColorValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unlockScoreThreshold': unlockScoreThreshold,
        'primaryColorValue': primaryColorValue,
        'glowColorValue': glowColorValue,
        'isUnlocked': isUnlocked,
      };

  factory OrbSkin.fromJson(Map<String, dynamic> json) => OrbSkin(
        id: json['id'] as String,
        name: json['name'] as String,
        unlockScoreThreshold: json['unlockScoreThreshold'] as int,
        primaryColorValue: json['primaryColorValue'] as int,
        glowColorValue: json['glowColorValue'] as int,
        isUnlocked: json['isUnlocked'] as bool,
      );
}

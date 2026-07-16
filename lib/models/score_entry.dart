class ScoreEntry {
  final int score;
  final String timestamp;

  ScoreEntry({
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'timestamp': timestamp,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        score: json['score'] as int,
        timestamp: json['timestamp'] as String,
      );
}

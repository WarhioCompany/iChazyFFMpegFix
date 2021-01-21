class   Stats {
  final int likes;
  final int dislikes;

  Stats({this.likes, this.dislikes});

  Stats copyWith({
    int likes,
    int dislikes,
  }) =>
      Stats(
        likes: likes ?? this.likes,
        dislikes: dislikes ?? this.dislikes,
      );

  factory Stats.fromMap(Map<String, dynamic> json) => Stats(
    likes: json["likes"],
    dislikes: json["dislikes"],
  );
}
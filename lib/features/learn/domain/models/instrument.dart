class Lesson {
  final String id;
  final String title;
  final String duration;
  final String level;
  final String description;
  final List<String> steps;
  final List<String> tips;
  final int xp;
  final String? youtubeUrl;
  final bool completed;

  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.description,
    required this.steps,
    required this.tips,
    required this.xp,
    this.youtubeUrl,
    this.completed = false,
  });
}

class Song {
  final String title;
  final String artist;
  final String duration;

  const Song({
    required this.title,
    required this.artist,
    required this.duration,
  });
}

class Instrument {
  final String id;
  final String name;
  final String englishName;
  final String region;
  final String category;
  final String emoji;
  final String color;
  final String imageUrl;
  final String shortDesc;
  final String description;
  final String origin;
  final String material;
  final String soundRange;
  final int difficulty;
  final int popularity;
  final List<Lesson> lessons;
  final List<Song> songs;
  final List<String> facts;

  const Instrument({
    required this.id,
    required this.name,
    required this.englishName,
    required this.region,
    required this.category,
    required this.emoji,
    required this.color,
    required this.imageUrl,
    required this.shortDesc,
    required this.description,
    required this.origin,
    required this.material,
    required this.soundRange,
    required this.difficulty,
    required this.popularity,
    required this.lessons,
    required this.songs,
    required this.facts,
  });
}

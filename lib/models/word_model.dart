class Word {
  int? id;
  String word;
  String translation;
  String type;
  String difficulty;
  int isMemorized;
  String sentence;

  Word({
    this.id,
    required this.word,
    required this.translation,
    required this.type,
    required this.difficulty,
    this.isMemorized = 0,
    required this.sentence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'type': type,
      'difficulty': difficulty,
      'isMemorized': isMemorized,
      'sentence': sentence,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      translation: map['translation'],
      type: map['type'],
      difficulty: map['difficulty'],
      isMemorized: map['isMemorized'],
      sentence: map['sentence'],
    );
  }
}
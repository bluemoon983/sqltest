class Word {
  final int id;
  final String name;
  final String meaning;

  Word({required this.id, required this.name, required this.meaning});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'meaning': meaning};
  }
}

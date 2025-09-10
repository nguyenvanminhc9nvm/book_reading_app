class Book {
  final int id;
  final String title;
  final List<String> tags;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.title,
    required this.tags,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      chapters: (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
}

class Chapter {
  final String id;
  final String title;
  final String rewrittenText;
  final int orderNum;

  Chapter({
    required this.id,
    required this.title,
    required this.rewrittenText,
    required this.orderNum,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      rewrittenText: json['rewritten_text'],
      orderNum: json['order_num'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'rewritten_text': rewrittenText,
      'order_num': orderNum,
    };
  }

  // Get the cost to unlock this chapter (in coins)
  int get unlockCost {
    return orderNum * 10; // 10 coins for chapter 1, 20 for chapter 2, etc.
  }
}

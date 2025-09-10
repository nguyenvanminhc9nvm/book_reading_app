import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../services/storage_service.dart';
import 'reader_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  Book? book;
  int coinBalance = 0;
  List<String> unlockedChapters = [];
  bool isLoading = true;
  late StorageService storageService;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      storageService = await StorageService.getInstance();
      
      // Load book data
      final String response = await rootBundle.loadString('assets/book.json');
      final data = await json.decode(response);
      book = Book.fromJson(data);
      
      // Load user data
      coinBalance = await storageService.getCoinBalance();
      unlockedChapters = await storageService.getUnlockedChapters();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading book: $e')),
        );
      }
    }
  }

  Future<void> _unlockChapter(Chapter chapter) async {
    final cost = chapter.unlockCost;
    if (coinBalance >= cost) {
      final success = await storageService.spendCoins(cost);
      if (success) {
        await storageService.unlockChapter(chapter.id);
        setState(() {
          coinBalance -= cost;
          unlockedChapters.add(chapter.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chapter "${chapter.title}" unlocked!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough coins! Need $cost coins.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openChapter(Chapter chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          chapter: chapter,
          book: book!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (book == null) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to load book'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(book!.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$coinBalance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Book info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade100, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: book!.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.deepPurple.shade50,
                    labelStyle: TextStyle(color: Colors.deepPurple.shade700),
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // Chapters list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: book!.chapters.length,
              itemBuilder: (context, index) {
                final chapter = book!.chapters[index];
                final isUnlocked = unlockedChapters.contains(chapter.id);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isUnlocked ? Colors.green : Colors.grey,
                      child: Icon(
                        isUnlocked ? Icons.lock_open : Icons.lock,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      'Chapter ${chapter.orderNum}',
                      style: TextStyle(
                        color: isUnlocked ? Colors.grey.shade600 : Colors.grey,
                      ),
                    ),
                    trailing: isUnlocked
                        ? const Icon(Icons.arrow_forward_ios)
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${chapter.unlockCost}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    onTap: () {
                      if (isUnlocked) {
                        _openChapter(chapter);
                      } else {
                        _showUnlockDialog(chapter);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock "${chapter.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This chapter costs ${chapter.unlockCost} coins to unlock.'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your coins: $coinBalance'),
                Text('Cost: ${chapter.unlockCost}'),
              ],
            ),
            if (coinBalance < chapter.unlockCost)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Not enough coins!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: coinBalance >= chapter.unlockCost
                ? () {
                    Navigator.pop(context);
                    _unlockChapter(chapter);
                  }
                : null,
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

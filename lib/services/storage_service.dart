import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _coinBalanceKey = 'coin_balance';
  static const String _unlockedChaptersKey = 'unlocked_chapters';
  static const int _defaultCoinBalance = 50;

  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Coin balance methods
  Future<int> getCoinBalance() async {
    return _prefs?.getInt(_coinBalanceKey) ?? _defaultCoinBalance;
  }

  Future<void> setCoinBalance(int balance) async {
    await _prefs?.setInt(_coinBalanceKey, balance);
  }

  Future<bool> spendCoins(int amount) async {
    final currentBalance = await getCoinBalance();
    if (currentBalance >= amount) {
      await setCoinBalance(currentBalance - amount);
      return true;
    }
    return false;
  }

  Future<void> addCoins(int amount) async {
    final currentBalance = await getCoinBalance();
    await setCoinBalance(currentBalance + amount);
  }

  // Chapter unlock methods
  Future<List<String>> getUnlockedChapters() async {
    return _prefs?.getStringList(_unlockedChaptersKey) ?? ['1']; // Chapter 1 is always unlocked
  }

  Future<void> unlockChapter(String chapterId) async {
    final unlockedChapters = await getUnlockedChapters();
    if (!unlockedChapters.contains(chapterId)) {
      unlockedChapters.add(chapterId);
      await _prefs?.setStringList(_unlockedChaptersKey, unlockedChapters);
    }
  }

  Future<bool> isChapterUnlocked(String chapterId) async {
    final unlockedChapters = await getUnlockedChapters();
    return unlockedChapters.contains(chapterId);
  }

  // Reset all data (for testing purposes)
  Future<void> resetAllData() async {
    await _prefs?.remove(_coinBalanceKey);
    await _prefs?.remove(_unlockedChaptersKey);
  }
}

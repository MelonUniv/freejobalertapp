import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import '../utils/app_logger.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarked_jobs';

  // Save a job to bookmarks
  static Future<bool> addBookmark(Job job) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();

      // Check if already bookmarked
      if (bookmarks.any((j) => j.postId == job.postId)) {
        return false; // Already bookmarked
      }

      bookmarks.add(job);

      // Convert to JSON
      final List<String> jsonList = bookmarks.map((j) => json.encode(j.toJson())).toList();

      await prefs.setStringList(_bookmarksKey, jsonList);
      return true;
    } catch (e) {
      AppLogger.error('Error adding bookmark', e);
      return false;
    }
  }

  // Remove a job from bookmarks
  static Future<bool> removeBookmark(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();

      bookmarks.removeWhere((j) => j.postId == postId);

      // Convert to JSON
      final List<String> jsonList = bookmarks.map((j) => json.encode(j.toJson())).toList();

      await prefs.setStringList(_bookmarksKey, jsonList);
      return true;
    } catch (e) {
      AppLogger.error('Error removing bookmark', e);
      return false;
    }
  }

  // Get all bookmarked jobs
  static Future<List<Job>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_bookmarksKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((jsonStr) => Job.fromJson(json.decode(jsonStr))).toList();
    } catch (e) {
      AppLogger.error('Error getting bookmarks', e);
      return [];
    }
  }

  // Check if a job is bookmarked
  static Future<bool> isBookmarked(String postId) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((j) => j.postId == postId);
    } catch (e) {
      AppLogger.error('Error checking bookmark', e);
      return false;
    }
  }

  // Toggle bookmark (add if not bookmarked, remove if bookmarked)
  static Future<bool> toggleBookmark(Job job) async {
    final isCurrentlyBookmarked = await isBookmarked(job.postId);

    if (isCurrentlyBookmarked) {
      return await removeBookmark(job.postId);
    } else {
      return await addBookmark(job);
    }
  }

  // Get bookmark count
  static Future<int> getBookmarkCount() async {
    final bookmarks = await getBookmarks();
    return bookmarks.length;
  }

  // Clear all bookmarks
  static Future<bool> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      return true;
    } catch (e) {
      AppLogger.error('Error clearing bookmarks', e);
      return false;
    }
  }
}
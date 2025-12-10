import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';
import '../services/screen_wrapper.dart';
import '../services/ad_manager.dart';
import '../models/job_model.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Job> _bookmarkedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    final bookmarks = await BookmarkService.getBookmarks();

    setState(() {
      _bookmarkedJobs = bookmarks;
      _isLoading = false;
    });
  }

  Future<void> _removeBookmark(String postId) async {
    await BookmarkService.removeBookmark(postId);
    _loadBookmarks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (_bookmarkedJobs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: ScreenWrapper(
        showBannerAd: true,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on jobs to save them',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _bookmarkedJobs.length,
        itemBuilder: (context, index) {
          final job = _bookmarkedJobs[index];
          return JobCard(
            job: job,
            isBookmarked: true,
            onTap: () async {
              // Check and show interstitial ad based on timing
              final adManager = AdManager();
              if (adManager.isFirstInteraction) {
                // First click - show ad immediately
                adManager.showInterstitialAd(isFirstClick: true);
              } else if (adManager.shouldShowAd()) {
                // After 3 minutes - show ad on click
                adManager.showInterstitialAd();
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(
                    postId: job.postId,
                    jobTitle: job.displayTitle,
                  ),
                ),
              );
              _loadBookmarks();
            },
            onBookmarkToggle: () => _removeBookmark(job.postId),
          );
        },
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks?'),
        content: const Text('Are you sure you want to remove all bookmarks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await BookmarkService.clearAllBookmarks();
              _loadBookmarks();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All bookmarks cleared')),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
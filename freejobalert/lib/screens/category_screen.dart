import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../services/screen_wrapper.dart';
import '../services/ad_manager.dart';
import '../models/job_model.dart';
import '../widgets/job_card.dart';
import '../widgets/pagination_widget.dart';
import 'job_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Job> _jobs = [];
  final Map<String, bool> _bookmarkStatus = {};
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _error;
  int? _totalJobs;
  bool _hasNext = false;
  bool _hasPrevious = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.fetchJobsByCategory(
        categoryGroup: widget.category,
        page: _currentPage,
      );

      if (response.success && response.data != null) {
        final List<Job> jobs = response.data!.map((json) => Job.fromJson(json)).toList();

        // Check bookmark status for all jobs
        await _loadBookmarkStatus(jobs);

        setState(() {
          _jobs.clear();
          _jobs.addAll(jobs);
          _totalJobs = response.totalJobs;
          _totalPages = response.pagination?.totalPages ?? 1;
          _hasNext = response.pagination?.hasNext ?? false;
          _hasPrevious = response.pagination?.hasPrevious ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _jobs.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookmarkStatus(List<Job> jobs) async {
    // Load all bookmark statuses in parallel for faster performance
    final results = await Future.wait(
      jobs.map((job) => BookmarkService.isBookmarked(job.postId)),
    );

    for (int i = 0; i < jobs.length; i++) {
      _bookmarkStatus[jobs[i].postId] = results[i];
    }
  }

  Future<void> _toggleBookmark(Job job) async {
    final success = await BookmarkService.toggleBookmark(job);

    if (success) {
      setState(() {
        _bookmarkStatus[job.postId] = !(_bookmarkStatus[job.postId] ?? false);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _bookmarkStatus[job.postId] == true
                    ? 'Bookmark added'
                    : 'Bookmark removed'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _goToNextPage() {
    if (_hasNext && !_isLoading) {
      setState(() {
        _currentPage++;
      });
      _loadJobs();
    }
  }

  void _goToPreviousPage() {
    if (_hasPrevious && !_isLoading && _currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: ScreenWrapper(
        showBannerAd: true,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No jobs available in ${widget.categoryName}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.work, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${_totalJobs ?? 0} Jobs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                'Page $_currentPage of $_totalPages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _loadJobs,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _jobs.length + 1, // +1 for pagination buttons
              itemBuilder: (context, index) {
                // Show pagination buttons at the end
                if (index == _jobs.length) {
                  return PaginationWidget(
                    hasPrevious: _hasPrevious,
                    hasNext: _hasNext,
                    isLoading: _isLoading,
                    onPrevious: _goToPreviousPage,
                    onNext: _goToNextPage,
                  );
                }

                // Build job card with container banner ad after it (if position is 3, 6, or 9)
                final position = index + 1; // 1-based position
                final job = _jobs[index];
                final isBookmarked = _bookmarkStatus[job.postId] ?? false;

                return JobCard(
                  job: job,
                  isBookmarked: isBookmarked,
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
                    _loadBookmarkStatus(_jobs);
                    setState(() {});
                  },
                  onBookmarkToggle: () => _toggleBookmark(job),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

}
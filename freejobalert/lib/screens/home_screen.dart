import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../services/firebase_service.dart';
import '../services/screen_wrapper.dart';
import '../services/ad_manager.dart';
import '../utils/app_logger.dart';
import '../models/job_model.dart';
import '../models/state_model.dart';
import '../widgets/job_card.dart';
import '../widgets/pagination_widget.dart';
import 'job_detail_screen.dart';
import 'category_screen.dart';
import 'bookmarks_screen.dart';
import 'disclaimer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Job> _jobs = [];
  final Map<String, bool> _bookmarkStatus = {};
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _error;
  int? _totalJobs;
  bool _hasNext = false;
  bool _hasPrevious = false;

  // State dropdown
  StateModel _selectedState = IndianStates.states[0]; // Default to "All States"

  @override
  void initState() {
    super.initState();
    _loadJobs();
    // Initialize Firebase Messaging and subscribe to topics
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // Run after frame is built to ensure UI context is ready for permission dialog
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // This will show the permission dialog on Android 13+
        await FirebaseService.initialize();

        // Subscribe to topics after permission is granted
        await FirebaseService.subscribeToTopic('all_jobs');
        await FirebaseService.subscribeToTopic('new_updates');
      } catch (e) {
        // Silently fail - notifications will still work with default topics
        AppLogger.warning('Failed to initialize notifications: $e');
      }
    });
  }

  Future<void> _loadJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.fetchJobs(page: _currentPage);

      if (response.success && response.data != null) {
        final List<Job> jobs = response.data!.map((json) => Job.fromJson(json)).toList();
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
        title: Row(
          children: [
            // Logo in AppBar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: 'https://img2.freejobalert.com/common/logo.jpg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 32,
                  height: 32,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/icon/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.work,
                      size: 28,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Free Job Alert'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: ScreenWrapper(
        showBannerAd: true,
        enableExitDialog: true,
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
              'No jobs available at the moment',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
        // State Dropdown - Single Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<StateModel>(
              value: _selectedState,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
              dropdownColor: Colors.blue.shade50,
              items: IndianStates.states.map((StateModel state) {
                return DropdownMenuItem<StateModel>(
                  value: state,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        state.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (StateModel? newState) {
                if (newState != null) {
                  setState(() {
                    _selectedState = newState;
                  });
                  // Navigate to CategoryScreen with state as cat_group
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryScreen(
                        category: newState.value,
                        categoryName: newState.name,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
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
              itemCount: _jobs.length + 1,
              itemBuilder: (context, index) {
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


  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Logo without box background
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: 'https://img2.freejobalert.com/common/logo.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/icon/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.work,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Free Job Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Government Job Portal',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Not an official government app',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to HomeScreen (replace current route to avoid stacking)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.blue),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              ).then((_) {
                _loadBookmarkStatus(_jobs);
                setState(() {});
              });
            },
          ),
          _buildDrawerItem(Icons.new_releases, 'New Updates', 'new-updates'),
          _buildDrawerItem(Icons.work, 'All Government Jobs', 'government-jobs'),
          _buildDrawerItem(Icons.train, 'Railway Jobs', 'railway-jobs'),
          _buildDrawerItem(Icons.account_balance, 'Banking Jobs', 'bank-jobs'),
          _buildDrawerItem(Icons.school, 'Teaching Jobs', 'teaching-faculty-jobs'),
          _buildDrawerItem(Icons.engineering, 'Engineering Jobs', 'engineering-jobs'),
          _buildDrawerItem(Icons.shield, 'Police/Defence Jobs', 'police-defence-jobs'),
          _buildDrawerItem(Icons.assessment, 'Results', 'exam-results'),
          _buildDrawerItem(Icons.card_membership, 'Admit Card', 'admit-card'),
          _buildDrawerItem(Icons.question_answer, 'Answer Key', 'answer-key'),
          _buildDrawerItem(Icons.menu_book, 'Syllabus', 'syllabus'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.orange),
            title: const Text('Disclaimer'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DisclaimerScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String? category) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (category != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(
                category: category,
                categoryName: title,
              ),
            ),
          );
        }
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Free Job Alert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Version: 1.0.0'),
              const SizedBox(height: 10),
              const Text(
                'Get the latest government job notifications, results, admit cards, and more.',
              ),
              const SizedBox(height: 10),
              Text('Total Jobs: ${_totalJobs ?? 'Loading...'}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disclaimer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'This is NOT an official government app. Job information is sourced from freejobalert.com. Please verify all information from official government sources.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data Source: freejobalert.com',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              const Text('© 2025 Free Job Alert'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DisclaimerScreen()),
              );
            },
            child: const Text('View Full Disclaimer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
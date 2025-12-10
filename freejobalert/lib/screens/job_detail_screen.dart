import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';
import '../services/screen_wrapper.dart';
import '../services/admanager_content_banner_widget.dart';
import '../models/job_model.dart';
import '../models/job_detail_model.dart';
import 'package:html/dom.dart' as dom;

class JobDetailScreen extends StatefulWidget {
  final String postId;
  final String jobTitle;

  const JobDetailScreen({
    super.key,
    required this.postId,
    required this.jobTitle,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobDetail? _jobDetail;
  bool _isLoading = true;
  String? _error;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetail();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final bookmarked = await BookmarkService.isBookmarked(widget.postId);
    setState(() {
      _isBookmarked = bookmarked;
    });
  }

  Future<void> _toggleBookmark() async {
    final job = Job(
      id: widget.postId,
      postId: widget.postId,
      companyName: _jobDetail?.pageTitle ?? widget.jobTitle,
      url: _jobDetail?.urlText != null
          ? 'https://www.freejobalert.com/${_jobDetail!.urlText}'
          : '',
      updatedAt: _jobDetail?.updatedAt ?? '',
      shortTitle: _jobDetail?.shortTitle,
      postExamName: _jobDetail?.pageTitle,
      qualification: null,
      vacancy: null,
      lastDate: null,
      state: null,
    );

    final success = await BookmarkService.toggleBookmark(job);

    if (success) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Bookmark added' : 'Bookmark removed'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadJobDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.fetchJobDetail(jobId: widget.postId);

      if (response.success && response.data != null) {
        setState(() {
          _jobDetail = JobDetail.fromJson(response.data!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load job details';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobDetail,
          ),
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _jobDetail != null ? () => _shareJob() : null,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading job details...'),
          ],
        ),
      );
    }

    if (_error != null) {
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
              onPressed: _loadJobDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_jobDetail == null) {
      return const Center(
        child: Text('No job details available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Page Title
            if (_jobDetail!.pageTitle != null && _jobDetail!.pageTitle!.isNotEmpty) ...[
              Text(
                _jobDetail!.pageTitle!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 2. Page Description
            if (_jobDetail!.pageDesc != null && _jobDetail!.pageDesc!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  _jobDetail!.pageDesc!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 3. Updated At Date
            if (_jobDetail!.updatedAt != null && _jobDetail!.updatedAt!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.update, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Last Updated: ${_jobDetail!.formattedUpdatedAt ?? _jobDetail!.updatedAt}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // 4. Image
            if (_jobDetail!.fullImageUrl != null && _jobDetail!.fullImageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: _jobDetail!.fullImageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // AdManager Content Banner Ad (below image)
            const AdManagerContentBannerWidget(),

            // 5. Content (HTML) with CUSTOM TABLE RENDERING
            if (_jobDetail!.content != null && _jobDetail!.content!.isNotEmpty) ...[
              Html(
                data: _jobDetail!.content,
                onLinkTap: (url, attributes, element) {
                  if (url != null) {
                    _openUrl(url);
                  }
                },
                // CUSTOM TABLE RENDERER
                extensions: [
                  TagExtension(
                    tagsToExtend: {"table"},
                    builder: (extensionContext) {
                      final element = extensionContext.element;
                      if (element != null) {
                        return _buildCustomTable(element);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
                style: {
                  "body": Style(
                    fontSize: FontSize(15),
                    lineHeight: LineHeight.number(1.6),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "h1": Style(
                    fontSize: FontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    margin: Margins.only(top: 16, bottom: 12),
                  ),
                  "h2": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                    margin: Margins.only(top: 14, bottom: 10),
                  ),
                  "h3": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                    margin: Margins.only(top: 12, bottom: 8),
                  ),
                  "h4, h5, h6": Style(
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade500,
                    margin: Margins.only(top: 10, bottom: 8),
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 12, left: 20),
                  ),
                  "ol": Style(
                    margin: Margins.only(bottom: 12, left: 20),
                  ),
                  "li": Style(
                    margin: Margins.only(bottom: 6),
                  ),
                  "a": Style(
                    color: Colors.blue,
                    textDecoration: TextDecoration.underline,
                  ),
                  "strong, b": Style(
                    fontWeight: FontWeight.bold,
                  ),
                  "em, i": Style(
                    fontStyle: FontStyle.italic,
                  ),
                  "blockquote": Style(
                    backgroundColor: Colors.grey.shade100,
                    padding: HtmlPaddings.all(12),
                    margin: Margins.only(bottom: 12, left: 16),
                    border: Border(
                      left: BorderSide(
                        color: Colors.blue.shade300,
                        width: 4,
                      ),
                    ),
                  ),
                },
              ),
              const SizedBox(height: 24),
            ],

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _shareJob,
                icon: const Icon(Icons.share),
                label: const Text(
                  'Share This Job',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMPROVED CUSTOM TABLE BUILDER - No more errors!
  Widget _buildCustomTable(dom.Element element) {
    try {
      // Get all rows
      final trElements = element.querySelectorAll('tr');
      if (trElements.isEmpty) return const SizedBox.shrink();

      // Build table as Column of Rows (more reliable than Table widget)
      final rows = <Widget>[];

      for (var tr in trElements) {
        final tdElements = tr.querySelectorAll('td, th');
        if (tdElements.isEmpty) continue;

        final cellWidgets = <Widget>[];

        for (var td in tdElements) {
          final isHeader = td.localName == 'th' ||
              td.querySelector('strong') != null ||
              td.querySelector('b') != null;

          final cellContent = td.innerHtml.trim();
          final isEmpty = cellContent.isEmpty ||
              cellContent == '&nbsp;' ||
              cellContent == '<br>' ||
              cellContent == '<br/>';

          cellWidgets.add(
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHeader ? Colors.blue.shade50 : Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: isEmpty
                    ? const SizedBox(height: 16)
                    : Html(
                  data: cellContent,
                  shrinkWrap: true,
                  onLinkTap: (url, attributes, element) {
                    if (url != null) {
                      _openUrl(url);
                    }
                  },
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14),
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      lineHeight: LineHeight.number(1.3),
                    ),
                    "p": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "strong, b": Style(
                      fontWeight: FontWeight.bold,
                    ),
                    "a": Style(
                      color: Colors.blue,
                      textDecoration: TextDecoration.underline,
                    ),
                  },
                ),
              ),
            ),
          );
        }

        // Add row
        if (cellWidgets.isNotEmpty) {
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cellWidgets,
              ),
            ),
          );
        }
      }

      if (rows.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            children: rows,
          ),
        ),
      );
    } catch (e) {
      // If any error, return empty widget instead of crashing
      debugPrint('Error rendering table: $e');
      return const SizedBox.shrink();
    }
  }

  Future<void> _openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  void _shareJob() {
    if (_jobDetail == null) return;

    final url = _jobDetail!.urlText != null && _jobDetail!.urlText!.isNotEmpty
        ? 'https://www.freejobalert.com/articles/${_jobDetail!.urlText}'
        : 'https://www.freejobalert.com';

    final text = '''
${_jobDetail!.pageTitle ?? widget.jobTitle}

${_jobDetail!.pageDesc ?? ''}

Read more: $url

Shared via Free Job Alert App
''';
    Share.share(text, subject: _jobDetail!.pageTitle ?? widget.jobTitle);
  }
}
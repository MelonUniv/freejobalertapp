class Job {
  final String id;
  final String postId;
  final String? postExamName;
  final String companyName;
  final String? qualification;
  final String? vacancy;
  final String? lastDate;
  final String url;
  final String updatedAt;
  final String? shortTitle;
  final String? state;

  Job({
    required this.id,
    required this.postId,
    this.postExamName,
    required this.companyName,
    this.qualification,
    this.vacancy,
    this.lastDate,
    required this.url,
    required this.updatedAt,
    this.shortTitle,
    this.state,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '0',
      postId: json['post_id']?.toString() ?? '0',
      postExamName: json['post_exam_name']?.toString(),
      companyName: json['company_name']?.toString() ?? 'N/A',
      qualification: json['qualification']?.toString(),
      vacancy: json['vacancy']?.toString(),
      lastDate: json['last_date']?.toString(),
      url: json['url']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      shortTitle: json['short_title']?.toString(),
      state: json['state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'post_exam_name': postExamName,
      'company_name': companyName,
      'qualification': qualification,
      'vacancy': vacancy,
      'last_date': lastDate,
      'url': url,
      'updated_at': updatedAt,
      'short_title': shortTitle,
      'state': state,
    };
  }

  // Helper method to get display title
  String get displayTitle {
    if (shortTitle != null && shortTitle!.isNotEmpty) {
      return shortTitle!;
    }
    if (postExamName != null && postExamName!.isNotEmpty) {
      return postExamName!;
    }
    return companyName;
  }

  // Helper method to format last date
  String? get formattedLastDate {
    if (lastDate == null || lastDate!.isEmpty || lastDate == '0000-00-00') {
      return null;
    }
    try {
      // Try to parse and format the date
      final parts = lastDate!.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // DD-MM-YYYY
      }
      return lastDate;
    } catch (e) {
      return lastDate;
    }
  }
}
class JobDetail {
  final String id;
  final String? shortTitle;
  final String? pageTitle;
  final String? pageDesc;
  final String? content;
  final String? metaTitle;
  final String? metaDesc;
  final String? urlText;
  final String? image;
  final String? stateId;
  final String? cityId;
  final String? addedAt;
  final String? updatedAt;

  JobDetail({
    required this.id,
    this.shortTitle,
    this.pageTitle,
    this.pageDesc,
    this.content,
    this.metaTitle,
    this.metaDesc,
    this.urlText,
    this.image,
    this.stateId,
    this.cityId,
    this.addedAt,
    this.updatedAt,
  });

  factory JobDetail.fromJson(Map<String, dynamic> json) {
    return JobDetail(
      id: json['id']?.toString() ?? '0',
      shortTitle: json['short_title']?.toString(),
      pageTitle: json['page_title']?.toString(),
      pageDesc: json['page_desc']?.toString(),
      content: json['content']?.toString(),
      metaTitle: json['meta_title']?.toString(),
      metaDesc: json['meta_desc']?.toString(),
      urlText: json['url_text']?.toString(),
      image: json['image']?.toString(),
      stateId: json['state_id']?.toString(),
      cityId: json['city_id']?.toString(),
      addedAt: json['added_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // Helper method to get display title
  String get displayTitle {
    if (pageTitle != null && pageTitle!.isNotEmpty) {
      return pageTitle!;
    }
    if (shortTitle != null && shortTitle!.isNotEmpty) {
      return shortTitle!;
    }
    if (metaTitle != null && metaTitle!.isNotEmpty) {
      return metaTitle!;
    }
    return 'Job Details';
  }

  // Helper method to format dates
  String? formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }
    try {
      // Format: "2024-11-08 10:30:00" -> "08 Nov 2024"
      if (dateStr.contains(' ')) {
        final parts = dateStr.split(' ')[0].split('-');
        if (parts.length == 3) {
          final months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          final month = int.parse(parts[1]);
          return '${parts[2]} ${months[month - 1]} ${parts[0]}';
        }
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String? get formattedAddedAt => formatDate(addedAt);
  String? get formattedUpdatedAt => formatDate(updatedAt);

  // Get full image URL if needed
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;

    // If image already has http/https, return as is
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image;
    }

    // Otherwise, prepend your domain
    return 'https://www.freejobalert.com/$image';
  }
}
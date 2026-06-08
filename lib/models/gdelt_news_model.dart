class GdeltNewsModel {
  final String url;
  final String title;
  final String snippet;
  final String source;
  final DateTime publishedDate;
  final String imageUrl;
  final double relevanceScore;

  GdeltNewsModel({
    required this.url,
    required this.title,
    required this.snippet,
    required this.source,
    required this.publishedDate,
    required this.imageUrl,
    required this.relevanceScore,
  });

  factory GdeltNewsModel.fromJson(Map<String, dynamic> json) {
    // Parse date from various formats GDELT might use
    DateTime parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return DateTime.now();

      try {
        // Try different date formats
        if (dateStr.contains('T')) {
          return DateTime.parse(dateStr);
        } else if (dateStr.length == 14) {
          // Format: YYYYMMDDHHMMSS
          return DateTime.parse('${dateStr.substring(0, 4)}-'
              '${dateStr.substring(4, 6)}-'
              '${dateStr.substring(6, 8)}T'
              '${dateStr.substring(8, 10)}:'
              '${dateStr.substring(10, 12)}:'
              '${dateStr.substring(12, 14)}Z');
        }
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    // GDELT may use different field names for the article excerpt across
    // its API modes; read from the known text fields and fall back to empty.
    final snippetText = json['excerpt']?.toString() ??
        json['snippet']?.toString() ??
        json['description']?.toString() ??
        '';

    // GDELT `tone` is a sentiment value (roughly -100..+100) and can arrive as
    // a String or a num. Parse it safely and normalize to a 0..1 score so it
    // matches the thresholds used by [relevanceDisplay].
    final rawTone = _parseDouble(json['tone']);
    final normalizedRelevance = ((rawTone + 100) / 200).clamp(0.0, 1.0);

    return GdeltNewsModel(
      url: json['url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      snippet: snippetText,
      source: json['domain']?.toString() ?? '',
      publishedDate: parseDate(json['seendate']?.toString()),
      imageUrl: json['socialimage']?.toString() ?? '',
      relevanceScore: normalizedRelevance,
    );
  }

  /// Safely parses a dynamic JSON value (num, String, or null) into a double.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'snippet': snippet,
      'source': source,
      'publishedDate': publishedDate.toIso8601String(),
      'imageUrl': imageUrl,
      'relevanceScore': relevanceScore,
    };
  }

  // Helper getters
  String get timeAgo {
    final difference = DateTime.now().difference(publishedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get shortTitle {
    if (title.length <= 80) return title;
    return '${title.substring(0, 80)}...';
  }

  String get displaySource {
    // Remove www. and .com for cleaner display
    return source.replaceAll('www.', '').replaceAll('.com', '');
  }

  bool get hasImage => imageUrl.isNotEmpty && imageUrl.startsWith('http');

  bool get isRecent => DateTime.now().difference(publishedDate).inDays < 7;

  String get relevanceDisplay {
    if (relevanceScore > 0.7) return 'High relevance';
    if (relevanceScore > 0.4) return 'Medium relevance';
    return 'Low relevance';
  }

  // News category based on keywords in title
  String get category {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('admission') ||
        titleLower.contains('application')) {
      return 'Admissions';
    } else if (titleLower.contains('scholarship') ||
        titleLower.contains('financial aid')) {
      return 'Financial Aid';
    } else if (titleLower.contains('ranking') ||
        titleLower.contains('rating')) {
      return 'Rankings';
    } else if (titleLower.contains('campus') ||
        titleLower.contains('student life')) {
      return 'Campus Life';
    } else if (titleLower.contains('research') ||
        titleLower.contains('academic')) {
      return 'Academics';
    }

    return 'General';
  }
}

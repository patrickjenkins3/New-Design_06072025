class CareerOneStopScholarshipModel {
  final String id;
  final String title;
  final String description;
  final String sponsor;
  final String eligibility;
  final String amount;
  final String deadline;
  final String applicationUrl;
  final String category;
  final List<String> requirements;

  CareerOneStopScholarshipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sponsor,
    required this.eligibility,
    required this.amount,
    required this.deadline,
    required this.applicationUrl,
    required this.category,
    required this.requirements,
  });

  factory CareerOneStopScholarshipModel.fromJson(Map<String, dynamic> json) {
    // Parse requirements from string or list
    List<String> parseRequirements(dynamic reqData) {
      if (reqData == null) return [];
      if (reqData is String) {
        return reqData.split('\n').where((s) => s.trim().isNotEmpty).toList();
      }
      if (reqData is List) {
        return reqData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return CareerOneStopScholarshipModel(
      id: json['ScholarshipID']?.toString() ?? '',
      title: json['ScholarshipName']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      sponsor: json['Sponsor']?.toString() ?? '',
      eligibility: json['Eligibility']?.toString() ?? '',
      amount: json['Award']?.toString() ?? '',
      deadline: json['Deadline']?.toString() ?? '',
      applicationUrl: json['ApplicationURL']?.toString() ?? '',
      category: json['Category']?.toString() ?? '',
      requirements: parseRequirements(json['Requirements']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sponsor': sponsor,
      'eligibility': eligibility,
      'amount': amount,
      'deadline': deadline,
      'applicationUrl': applicationUrl,
      'category': category,
      'requirements': requirements,
    };
  }

  // Helper getters
  bool get hasDeadline =>
      deadline.isNotEmpty && deadline.toLowerCase() != 'n/a';

  DateTime? get deadlineDate {
    if (!hasDeadline) return null;
    try {
      return DateTime.parse(deadline);
    } catch (e) {
      return null;
    }
  }

  String get shortDescription {
    if (description.length <= 150) return description;
    return '${description.substring(0, 150)}...';
  }

  bool get isExpired {
    final date = deadlineDate;
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  String get amountDisplay {
    if (amount.isEmpty || amount.toLowerCase() == 'n/a') {
      return 'Amount varies';
    }
    return amount;
  }

  int get priorityScore {
    int score = 0;

    // Higher priority for larger amounts
    if (amount.toLowerCase().contains('full')) score += 10;
    if (amount.contains('\$')) {
      // Match amounts with or without thousands separators (e.g. $5000 or $5,000).
      final numMatch = RegExp(r'\$(\d[\d,]*)').firstMatch(amount);
      if (numMatch != null) {
        final amountNum =
            int.tryParse(numMatch.group(1)?.replaceAll(',', '') ?? '0') ?? 0;
        if (amountNum >= 5000) score += 5;
        if (amountNum >= 10000) score += 5;
      }
    }

    // Bonus for deadlines coming up
    if (hasDeadline && deadlineDate != null) {
      final daysUntil = deadlineDate!.difference(DateTime.now()).inDays;
      if (daysUntil > 0 && daysUntil <= 30) score += 3;
    }

    return score;
  }
}

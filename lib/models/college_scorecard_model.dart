class CollegeScoreCardModel {
  final String id;
  final String name;
  final String state;
  final String city;
  final int? inStateTuition;
  final int? outOfStateTuition;
  final int? satScoreAverage;
  final int? actScoreAverage;
  final int? studentSize;
  final String? schoolUrl;

  CollegeScoreCardModel({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    this.inStateTuition,
    this.outOfStateTuition,
    this.satScoreAverage,
    this.actScoreAverage,
    this.studentSize,
    this.schoolUrl,
  });

  factory CollegeScoreCardModel.fromJson(Map<String, dynamic> json) {
    final school = json['school'] ?? {};
    final latest = json['latest'] ?? {};
    final cost = latest['cost'] ?? {};
    final tuition = cost['tuition'] ?? {};
    final admissions = latest['admissions'] ?? {};
    final satScores = admissions['sat_scores'] ?? {};
    final actScores = admissions['act_scores'] ?? {};
    final student = latest['student'] ?? {};

    return CollegeScoreCardModel(
      id: json['id']?.toString() ?? '',
      name: school['name']?.toString() ?? '',
      state: school['state']?.toString() ?? '',
      city: school['city']?.toString() ?? '',
      inStateTuition: _parseInt(tuition['in_state']),
      outOfStateTuition: _parseInt(tuition['out_of_state']),
      satScoreAverage: _parseInt(satScores['average']?['overall']),
      actScoreAverage: _parseInt(actScores['midpoint']?['cumulative']),
      studentSize: _parseInt(student['size']),
      schoolUrl: school['school_url']?.toString(),
    );
  }

  /// Safely parses a dynamic JSON value into an int. The College Scorecard API
  /// frequently returns these fields as doubles (e.g. 12345.0) or strings, so a
  /// direct cast to int? would throw at runtime.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'city': city,
      'inStateTuition': inStateTuition,
      'outOfStateTuition': outOfStateTuition,
      'satScoreAverage': satScoreAverage,
      'actScoreAverage': actScoreAverage,
      'studentSize': studentSize,
      'schoolUrl': schoolUrl,
    };
  }

  // Helper getters
  String get displayLocation => '$city, $state';

  String get tuitionRange {
    if (inStateTuition != null && outOfStateTuition != null) {
      return '\$${_formatCurrency(inStateTuition!)} - \$${_formatCurrency(outOfStateTuition!)}';
    } else if (inStateTuition != null) {
      return '\$${_formatCurrency(inStateTuition!)}';
    } else if (outOfStateTuition != null) {
      return '\$${_formatCurrency(outOfStateTuition!)}';
    }
    return 'N/A';
  }

  String get testScoresDisplay {
    final scores = <String>[];
    if (satScoreAverage != null) {
      scores.add('SAT: $satScoreAverage');
    }
    if (actScoreAverage != null) {
      scores.add('ACT: $actScoreAverage');
    }
    return scores.isEmpty ? 'N/A' : scores.join(', ');
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }
}

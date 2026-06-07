import 'package:dio/dio.dart';
import '../models/college_scorecard_model.dart';
import '../models/careeronestop_model.dart';
import '../models/gdelt_news_model.dart';

class ExternalApiService {
  static ExternalApiService? _instance;
  static ExternalApiService get instance =>
      _instance ??= ExternalApiService._();
  ExternalApiService._();

  late final Dio _dio;

  // API Keys from environment
  static const String collegeScoreCardKey = String.fromEnvironment(
    'COLLEGE_SCORECARD_KEY',
    defaultValue: '',
  );

  static const String careerOneStopUserId = String.fromEnvironment(
    'CAREERONESTOP_USERID',
    defaultValue: '',
  );

  static const String careerOneStopToken = String.fromEnvironment(
    'CAREERONESTOP_TOKEN',
    defaultValue: '',
  );

  // Base URLs
  static const String _collegeScoreCardBaseUrl =
      'https://api.data.gov/ed/collegescorecard/v1/';
  static const String _careerOneStopBaseUrl =
      'https://api.careeronestop.org/v1/';
  static const String _gdeltBaseUrl = 'https://api.gdeltproject.org/api/v2/';

  void initialize() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Validate required API keys
    _validateApiKeys();
  }

  void _validateApiKeys() {
    if (collegeScoreCardKey.isEmpty) {
      print(
          'Warning: COLLEGE_SCORECARD_KEY is not configured. College search features may not work.');
    }
    if (careerOneStopUserId.isEmpty || careerOneStopToken.isEmpty) {
      print(
          'Warning: CareerOneStop credentials are not configured. Scholarship search features may not work.');
    }
  }

  // College Scorecard API Integration
  Future<List<CollegeScoreCardModel>> searchColleges({
    String? schoolName,
    String? state,
    int? maxTuition,
    String? degree,
    int page = 0,
    int perPage = 20,
  }) async {
    try {
      if (collegeScoreCardKey.isEmpty) {
        throw Exception('College Scorecard API key not configured');
      }

      final Map<String, dynamic> queryParams = {
        'api_key': collegeScoreCardKey,
        '_page': page,
        '_per_page': perPage,
        '_fields':
            'id,school.name,school.state,school.city,latest.cost.tuition.in_state,latest.cost.tuition.out_of_state,latest.admissions.sat_scores.average.overall,latest.admissions.act_scores.midpoint.cumulative,latest.student.size,school.school_url',
      };

      if (schoolName != null && schoolName.isNotEmpty) {
        queryParams['school.name'] = schoolName;
      }
      if (state != null && state.isNotEmpty) {
        queryParams['school.state'] = state;
      }
      if (maxTuition != null) {
        queryParams['latest.cost.tuition.in_state__lte'] = maxTuition;
      }

      final response = await _dio.get(
        '${_collegeScoreCardBaseUrl}schools',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? [];
        return data
            .map((json) => CollegeScoreCardModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch college data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error searching colleges: ${e.message}');
    } catch (e) {
      throw Exception('Error searching colleges: $e');
    }
  }

  // CareerOneStop Scholarship API Integration
  Future<List<CareerOneStopScholarshipModel>> searchScholarships({
    String? keyword,
    String? state,
    int? amount,
    String? category,
    int startRecord = 1,
    int recordsPerPage = 50,
  }) async {
    try {
      if (careerOneStopUserId.isEmpty || careerOneStopToken.isEmpty) {
        throw Exception('CareerOneStop credentials not configured');
      }

      final Map<String, dynamic> queryParams = {
        'keyword': keyword ?? '',
        'scholarshipamount': amount ?? 0,
        'category': category ?? 'All',
        'sortcolumn': 'RELEVANCE',
        'sortdirection': 'DESC',
        'startrecord': startRecord,
        'recordsperpage': recordsPerPage,
      };

      final response = await _dio.get(
        '${_careerOneStopBaseUrl}scholarshipfinder/$careerOneStopUserId/$careerOneStopToken/US',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['ScholarshipList'] ?? [];
        return data
            .map((json) => CareerOneStopScholarshipModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch scholarship data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error searching scholarships: ${e.message}');
    } catch (e) {
      throw Exception('Error searching scholarships: $e');
    }
  }

  // GDELT News API Integration
  Future<List<GdeltNewsModel>> getEducationNews({
    String? schoolName,
    String? query,
    int maxRecords = 75,
  }) async {
    try {
      final String searchQuery = schoolName != null
          ? '$schoolName education college university'
          : query ?? 'education scholarship college university';

      final Map<String, dynamic> queryParams = {
        'query': searchQuery,
        'mode': 'artlist',
        'maxrecords': maxRecords,
        'format': 'json',
        'sort': 'hybridrel',
        'timespan': '7d', // Last 7 days
      };

      final response = await _dio.get(
        '${_gdeltBaseUrl}doc/doc',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> articles = responseData['articles'] ?? [];
        return articles.map((json) => GdeltNewsModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch news data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error fetching news: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // Combined search for comprehensive results
  Future<Map<String, dynamic>> getComprehensiveEducationData({
    required String schoolName,
    String? state,
  }) async {
    try {
      final results = <String, dynamic>{};

      // Fetch college data
      try {
        final colleges = await searchColleges(
          schoolName: schoolName,
          state: state,
          perPage: 10,
        );
        results['colleges'] = colleges;
      } catch (e) {
        results['colleges'] = <CollegeScoreCardModel>[];
        results['college_error'] = e.toString();
      }

      // Fetch scholarships
      try {
        final scholarships = await searchScholarships(
          keyword: schoolName,
          state: state,
          recordsPerPage: 25,
        );
        results['scholarships'] = scholarships;
      } catch (e) {
        results['scholarships'] = <CareerOneStopScholarshipModel>[];
        results['scholarship_error'] = e.toString();
      }

      // Fetch related news
      try {
        final news = await getEducationNews(
          schoolName: schoolName,
          maxRecords: 20,
        );
        results['news'] = news;
      } catch (e) {
        results['news'] = <GdeltNewsModel>[];
        results['news_error'] = e.toString();
      }

      return results;
    } catch (e) {
      throw Exception('Error fetching comprehensive data: $e');
    }
  }

  // Health check for APIs
  Future<Map<String, bool>> checkApiHealth() async {
    final health = <String, bool>{};

    // Check College Scorecard API
    try {
      await searchColleges(perPage: 1);
      health['college_scorecard'] = true;
    } catch (e) {
      health['college_scorecard'] = false;
    }

    // Check CareerOneStop API
    try {
      await searchScholarships(recordsPerPage: 1);
      health['careeronestop'] = true;
    } catch (e) {
      health['careeronestop'] = false;
    }

    // Check GDELT API
    try {
      await getEducationNews(maxRecords: 1);
      health['gdelt'] = true;
    } catch (e) {
      health['gdelt'] = false;
    }

    return health;
  }

  void dispose() {
    _dio.close();
  }
}

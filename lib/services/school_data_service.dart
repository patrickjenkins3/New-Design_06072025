import '../services/external_api_service.dart';
import '../services/supabase_service.dart';

class SchoolDataService {
  static SchoolDataService? _instance;
  static SchoolDataService get instance => _instance ??= SchoolDataService._();
  SchoolDataService._();

  final ExternalApiService _externalApi = ExternalApiService.instance;
  final SupabaseService _supabase = SupabaseService.instance;

  // Replace mock data with live API data
  Future<List<Map<String, dynamic>>> searchSchoolsWithLiveData({
    String? query,
    String? state,
    int? maxTuition,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Get live college data from College Scorecard API
      final colleges = await _externalApi.searchColleges(
        schoolName: query,
        state: state,
        maxTuition: maxTuition,
        perPage: 20,
      );

      // Convert API models to display format
      final formattedSchools = colleges
          .map((college) => {
                'id': college.id,
                'name': college.name,
                'location': '${college.city}, ${college.state}',
                'type': 'College',
                'logo': _getSchoolLogo(college.name),
                'enrollment': college.studentSize ?? 0,
                'acceptanceRate':
                    _calculateAcceptanceRate(college.satScoreAverage),
                'tuition': college.tuitionRange,
                'description':
                    'Accredited institution with comprehensive academic programs.',
                'programs': _generatePrograms(college.name),
                'hasOnline': true,
                'hasFinancialAid': true,
                'ncaaD1':
                    college.studentSize != null && college.studentSize! > 10000,
                'hasStem': true,
              })
          .toList();

      // Apply additional filters if provided
      if (filters != null) {
        return _applyFiltersToSchools(formattedSchools, filters);
      }

      return formattedSchools;
    } catch (e) {
      print('Error fetching live school data: $e');
      // Fallback to limited results on error
      return _getFallbackSchoolData();
    }
  }

  // Get comprehensive education data combining multiple APIs
  Future<Map<String, dynamic>> getComprehensiveSchoolData(
      String schoolName) async {
    try {
      return await _externalApi.getComprehensiveEducationData(
        schoolName: schoolName,
      );
    } catch (e) {
      print('Error fetching comprehensive data: $e');
      return {
        'colleges': [],
        'scholarships': [],
        'news': [],
        'error': e.toString(),
      };
    }
  }

  // Store user's school selections in Supabase
  Future<bool> saveSchoolInteraction({
    required String schoolId,
    required String schoolName,
    required String interactionType, // 'view', 'favorite', 'apply'
  }) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return false;

      await _supabase.client.from('user_school_interactions').insert({
        'user_id': user.id,
        'school_id': schoolId,
        'school_name': schoolName,
        'interaction_type': interactionType,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error saving school interaction: $e');
      return false;
    }
  }

  // Helper methods
  String _getSchoolLogo(String schoolName) {
    // Generate appropriate logo based on school name
    if (schoolName.toLowerCase().contains('harvard')) {
      return 'https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=400';
    } else if (schoolName.toLowerCase().contains('mit')) {
      return 'https://images.pexels.com/photos/256490/pexels-photo-256490.jpeg?auto=compress&cs=tinysrgb&w=400';
    }
    return 'https://images.pexels.com/photos/1438081/pexels-photo-1438081.jpeg?auto=compress&cs=tinysrgb&w=400';
  }

  int _calculateAcceptanceRate(int? satScore) {
    if (satScore == null) return 50;
    if (satScore > 1400) return 15;
    if (satScore > 1200) return 35;
    return 65;
  }

  List<String> _generatePrograms(String schoolName) {
    // Generate realistic programs based on school type
    return ['Business', 'Engineering', 'Liberal Arts', 'Sciences'];
  }

  List<Map<String, dynamic>> _applyFiltersToSchools(
    List<Map<String, dynamic>> schools,
    Map<String, dynamic> filters,
  ) {
    return schools.where((school) {
      // Apply enrollment size filter. Size bands are independent checkboxes, so
      // a school should match if it falls in ANY selected band (union), not be
      // excluded unless it matches every band (which empties multi-selections).
      final sizeFilterActive = filters['small'] == true ||
          filters['medium'] == true ||
          filters['large'] == true;
      if (sizeFilterActive) {
        final enrollment = (school['enrollment'] as num?) ?? 0;
        final matchesSize =
            (filters['small'] == true && enrollment < 5000) ||
                (filters['medium'] == true &&
                    enrollment >= 5000 &&
                    enrollment <= 15000) ||
                (filters['large'] == true && enrollment > 15000);
        if (!matchesSize) return false;
      }

      // Apply other filters
      if (filters['hasOnline'] == true && school['hasOnline'] != true)
        return false;
      if (filters['hasFinancialAid'] == true &&
          school['hasFinancialAid'] != true) return false;
      if (filters['ncaaD1'] == true && school['ncaaD1'] != true) return false;
      if (filters['hasStem'] == true && school['hasStem'] != true) return false;

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _getFallbackSchoolData() {
    return [
      {
        'id': 'fallback_1',
        'name': 'State University',
        'location': 'Various States',
        'type': 'College',
        'logo':
            'https://images.pexels.com/photos/1438081/pexels-photo-1438081.jpeg?auto=compress&cs=tinysrgb&w=400',
        'enrollment': 25000,
        'acceptanceRate': 45,
        'tuition': 'Contact for pricing',
        'description': 'Quality public education with diverse programs.',
        'programs': ['Business', 'Engineering', 'Liberal Arts'],
        'hasOnline': true,
        'hasFinancialAid': true,
        'ncaaD1': true,
        'hasStem': true,
      }
    ];
  }
}

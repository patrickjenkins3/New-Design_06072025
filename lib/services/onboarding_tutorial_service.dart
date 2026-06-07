import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class OnboardingTutorialService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get tutorial progress for current user
  static Future<List<Map<String, dynamic>>> getTutorialProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('onboarding_tutorial_progress')
          .select('*')
          .eq('user_id', userId)
          .order('created_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching tutorial progress: $e');
      return [];
    }
  }

  // Initialize tutorial for new user
  static Future<bool> initializeTutorial() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.rpc('initialize_user_tutorial', params: {
        'user_uuid': userId,
      });

      return true;
    } catch (e) {
      debugPrint('Error initializing tutorial: $e');
      return false;
    }
  }

  // Complete a tutorial stage
  static Future<bool> completeTutorialStage(
    String stageName,
    Map<String, dynamic>? stageData,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.rpc('complete_tutorial_stage', params: {
        'user_uuid': userId,
        'stage_name': stageName,
        'stage_data_json': stageData ?? {},
      });

      return true;
    } catch (e) {
      debugPrint('Error completing tutorial stage: $e');
      return false;
    }
  }

  // Skip a tutorial stage
  static Future<bool> skipTutorialStage(String stageName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('onboarding_tutorial_progress')
          .update({
            'status': 'skipped',
            'skipped_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('tutorial_stage', stageName);

      return true;
    } catch (e) {
      debugPrint('Error skipping tutorial stage: $e');
      return false;
    }
  }

  // Update user personalization
  static Future<bool> updatePersonalization({
    String? userType,
    int? graduationYear,
    List<String>? collegeInterests,
    List<String>? locationPreferences,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (userType != null) updates['user_type'] = userType;
      if (graduationYear != null) updates['graduation_year'] = graduationYear;
      if (collegeInterests != null)
        updates['college_interests'] = collegeInterests;
      if (locationPreferences != null)
        updates['location_preferences'] = locationPreferences;
      if (additionalData != null) updates['interests_data'] = additionalData;

      await _supabase
          .from('user_personalization')
          .upsert(updates..['user_id'] = userId);

      return true;
    } catch (e) {
      debugPrint('Error updating personalization: $e');
      return false;
    }
  }

  // Get user personalization
  static Future<Map<String, dynamic>?> getPersonalization() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('user_personalization')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching personalization: $e');
      return null;
    }
  }

  // Get tutorial achievements
  static Future<List<Map<String, dynamic>>> getTutorialAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('tutorial_achievements')
          .select('*')
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  // Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final personalization = await getPersonalization();
      return personalization?['onboarding_completed'] ?? false;
    } catch (e) {
      debugPrint('Error checking onboarding completion: $e');
      return false;
    }
  }

  // Update tutorial stage progress with interaction data
  static Future<bool> updateStageProgress(
    String stageName,
    String status,
    Map<String, dynamic>? stageData,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (stageData != null) {
        updates['stage_data'] = stageData;
      }

      if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('onboarding_tutorial_progress')
          .update(updates)
          .eq('user_id', userId)
          .eq('tutorial_stage', stageName);

      return true;
    } catch (e) {
      debugPrint('Error updating stage progress: $e');
      return false;
    }
  }
}
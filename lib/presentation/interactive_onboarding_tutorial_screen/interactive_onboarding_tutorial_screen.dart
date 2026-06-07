import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/onboarding_tutorial_service.dart';
import './widgets/personalization_dialog_widget.dart';
import './widgets/spotlight_overlay_widget.dart';
import './widgets/tutorial_progress_indicator.dart';
import './widgets/tutorial_stage_widget.dart';

class InteractiveOnboardingTutorialScreen extends StatefulWidget {
  const InteractiveOnboardingTutorialScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveOnboardingTutorialScreen> createState() =>
      _InteractiveOnboardingTutorialScreenState();
}

class _InteractiveOnboardingTutorialScreenState
    extends State<InteractiveOnboardingTutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStageIndex = 0;
  bool _isLoading = true;
  bool _showSpotlight = false;
  String? _userType;
  Map<String, dynamic>? _tutorialProgress;

  final List<Map<String, dynamic>> _tutorialStages = [
    {
      'id': 'dashboard_overview',
      'title': 'Welcome to CollabFuture!',
      'description':
          'Let\'s explore your personalized dashboard and key features',
      'icon': Icons.dashboard_outlined,
      'color': const Color(0xFF6C63FF),
      'interactions': ['tap_stats', 'view_activities', 'explore_quick_actions'],
    },
    {
      'id': 'school_search',
      'title': 'Discover Perfect Schools',
      'description':
          'Learn how to search and filter schools that match your goals',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF4ECDC4),
      'interactions': ['search_demo', 'apply_filters', 'save_school'],
    },
    {
      'id': 'scholarship_matching',
      'title': 'Find Scholarships',
      'description':
          'Discover scholarships tailored to your profile and interests',
      'icon': Icons.card_giftcard_outlined,
      'color': const Color(0xFF45B7D1),
      'interactions': [
        'browse_scholarships',
        'set_filters',
        'bookmark_scholarship'
      ],
    },
    {
      'id': 'calendar_integration',
      'title': 'Manage Deadlines',
      'description': 'Keep track of important dates and application deadlines',
      'icon': Icons.calendar_today_outlined,
      'color': const Color(0xFF96CEB4),
      'interactions': ['add_deadline', 'set_reminder', 'sync_calendar'],
    },
    {
      'id': 'family_collaboration',
      'title': 'Family Teamwork',
      'description': 'Collaborate with family members on your college journey',
      'icon': Icons.family_restroom_outlined,
      'color': const Color(0xFFFECEA8),
      'interactions': ['invite_parent', 'share_progress', 'family_chat'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTutorialData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadTutorialData() async {
    try {
      // Initialize tutorial if not already done
      await OnboardingTutorialService.initializeTutorial();

      // Get tutorial progress
      final progress = await OnboardingTutorialService.getTutorialProgress();
      final personalization =
          await OnboardingTutorialService.getPersonalization();

      if (mounted) {
        setState(() {
          _tutorialProgress = {
            for (var stage in progress) stage['tutorial_stage']: stage
          };
          _userType = personalization?['user_type'];
          _isLoading = false;
        });

        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading tutorial data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextStage() {
    if (_currentStageIndex < _tutorialStages.length - 1) {
      setState(() {
        _currentStageIndex++;
        _showSpotlight = false;
      });
      _animationController.reset();
      _animationController.forward();

      // Add haptic feedback
      HapticFeedback.lightImpact();
    } else {
      _completeTutorial();
    }
  }

  void _previousStage() {
    if (_currentStageIndex > 0) {
      setState(() {
        _currentStageIndex--;
        _showSpotlight = false;
      });
      _animationController.reset();
      _animationController.forward();

      HapticFeedback.lightImpact();
    }
  }

  Future<void> _completeStage() async {
    final currentStage = _tutorialStages[_currentStageIndex];

    // Update stage progress
    await OnboardingTutorialService.completeTutorialStage(
      currentStage['id'],
      {
        'completed_at': DateTime.now().toIso8601String(),
        'interactions_completed': currentStage['interactions'].length,
        'user_type': _userType,
      },
    );

    // Show success feedback
    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${currentStage['title']} completed! 🎉'),
          backgroundColor: currentStage['color'],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _nextStage();
  }

  Future<void> _skipStage() async {
    final currentStage = _tutorialStages[_currentStageIndex];

    await OnboardingTutorialService.skipTutorialStage(currentStage['id']);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stage skipped'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _nextStage();
  }

  Future<void> _completeTutorial() async {
    // Mark tutorial as completed
    await OnboardingTutorialService.updatePersonalization(
      additionalData: {
        'tutorial_completed_at': DateTime.now().toIso8601String()
      },
    );

    if (mounted) {
      // Show completion dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Color(0xFF6C63FF)),
              SizedBox(width: 12),
              Text('Congratulations!'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You\'ve completed the CollabFuture onboarding tutorial!'),
              SizedBox(height: 16),
              Text('🎁 Extended trial period unlocked'),
              Text('🏆 Onboarding Master badge earned'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.dashboardScreen,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      );
    }
  }

  void _showPersonalizationDialog() {
    showDialog(
      context: context,
      builder: (context) => PersonalizationDialogWidget(
        userType: _userType,
        onSave: (data) async {
          await OnboardingTutorialService.updatePersonalization(
            userType: data['userType'],
            graduationYear: data['graduationYear'],
            collegeInterests: data['collegeInterests'],
            locationPreferences: data['locationPreferences'],
          );

          if (mounted) {
            setState(() {
              _userType = data['userType'];
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Setting up your personalized tutorial...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStage = _tutorialStages[_currentStageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  currentStage['color'].withAlpha(26),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CollabFuture Tutorial',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TutorialProgressIndicator(
                        currentStage: _currentStageIndex,
                        totalStages: _tutorialStages.length,
                        stages: _tutorialStages,
                      ),
                    ],
                  ),
                ),

                // Tutorial content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TutorialStageWidget(
                          stage: currentStage,
                          userType: _userType,
                          onInteraction: (interaction) {
                            HapticFeedback.selectionClick();
                            // Handle specific interactions
                            setState(() {
                              _showSpotlight = true;
                            });
                          },
                          onPersonalize: _showPersonalizationDialog,
                        ),
                      ),
                    ),
                  ),
                ),

                // Control buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentStageIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStage,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back, size: 20),
                                SizedBox(width: 8),
                                Text('Previous'),
                              ],
                            ),
                          ),
                        ),
                      if (_currentStageIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _completeStage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentStage['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStageIndex == _tutorialStages.length - 1
                                    ? 'Complete Tutorial'
                                    : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentStageIndex == _tutorialStages.length - 1
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _skipStage,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Spotlight overlay
          if (_showSpotlight)
            SpotlightOverlayWidget(
              onDismiss: () => setState(() => _showSpotlight = false),
            ),
        ],
      ),
    );
  }
}
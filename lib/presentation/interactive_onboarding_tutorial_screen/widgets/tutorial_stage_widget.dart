import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorialStageWidget extends StatefulWidget {
  final Map<String, dynamic> stage;
  final String? userType;
  final Function(String) onInteraction;
  final VoidCallback onPersonalize;

  const TutorialStageWidget({
    Key? key,
    required this.stage,
    this.userType,
    required this.onInteraction,
    required this.onPersonalize,
  }) : super(key: key);

  @override
  State<TutorialStageWidget> createState() => _TutorialStageWidgetState();
}

class _TutorialStageWidgetState extends State<TutorialStageWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Set<String> _completedInteractions = {};

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _handleInteraction(String interactionId) {
    HapticFeedback.lightImpact();
    setState(() {
      _completedInteractions.add(interactionId);
    });
    widget.onInteraction(interactionId);
  }

  Widget _buildDashboardDemo() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: Column(
            children: [
              Text(
                '📊 Your Dashboard Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Interactive stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildInteractiveCard(
                      'Applications',
                      '12',
                      Icons.school,
                      const Color(0xFF6C63FF),
                      'tap_stats',
                      'Tap to explore your application progress',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInteractiveCard(
                      'Deadlines',
                      '5',
                      Icons.schedule,
                      const Color(0xFFFF6B6B),
                      'view_activities',
                      'View upcoming deadlines and tasks',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInteractiveCard(
                      'Scholarships',
                      '8',
                      Icons.star,
                      const Color(0xFF4ECDC4),
                      'explore_quick_actions',
                      'Discover scholarship opportunities',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInteractiveCard(
                      'Saved Schools',
                      '15',
                      Icons.bookmark,
                      const Color(0xFF45B7D1),
                      'tap_stats',
                      'Access your saved schools list',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Personalization suggestion
        if (widget.userType == null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              color: Colors.orange.withAlpha(26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange.withAlpha(77)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalize Your Experience',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Tell us about yourself for better recommendations',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onPersonalize,
                      child: const Text('Setup',
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSchoolSearchDemo() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: Column(
            children: [
              Text(
                '🔍 Discover Your Perfect School',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Search demo
              GestureDetector(
                onTap: () => _handleInteraction('search_demo'),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _completedInteractions.contains('search_demo')
                        ? 1.0
                        : _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _completedInteractions.contains('search_demo')
                            ? Colors.green.withAlpha(51)
                            : widget.stage['color'].withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _completedInteractions.contains('search_demo')
                              ? Colors.green
                              : widget.stage['color'],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _completedInteractions.contains('search_demo')
                                ? Icons.check_circle
                                : Icons.search,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Search Universities',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  'Try searching for "Stanford University"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filter demo
              GestureDetector(
                onTap: () => _handleInteraction('apply_filters'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _completedInteractions.contains('apply_filters')
                        ? Colors.green.withAlpha(51)
                        : Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _completedInteractions.contains('apply_filters')
                          ? Colors.green
                          : Colors.white.withAlpha(77),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _completedInteractions.contains('apply_filters')
                            ? Icons.check_circle
                            : Icons.filter_list,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apply Smart Filters',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Filter by location, major, or acceptance rate',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String interactionId,
    String tooltip,
  ) {
    final isCompleted = _completedInteractions.contains(interactionId);

    return GestureDetector(
      onTap: () => _handleInteraction(interactionId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withAlpha(51) : color.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.green : color.withAlpha(128),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Stage icon and title
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.stage['color'].withAlpha(51),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.stage['color'],
                width: 2,
              ),
            ),
            child: Icon(
              widget.stage['icon'],
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.stage['title'],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.stage['description'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Stage-specific content
          if (widget.stage['id'] == 'dashboard_overview')
            _buildDashboardDemo()
          else if (widget.stage['id'] == 'school_search')
            _buildSchoolSearchDemo()
          else
            _buildGenericStageDemo(),
        ],
      ),
    );
  }

  Widget _buildGenericStageDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(
            widget.stage['icon'],
            size: 64,
            color: widget.stage['color'],
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive ${widget.stage['title']} Demo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This feature will be demonstrated with hands-on interactions. '
            'Tap the continue button to explore this section of CollabFuture.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

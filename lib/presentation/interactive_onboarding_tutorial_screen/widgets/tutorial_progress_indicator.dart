import 'package:flutter/material.dart';

class TutorialProgressIndicator extends StatelessWidget {
  final int currentStage;
  final int totalStages;
  final List<Map<String, dynamic>> stages;

  const TutorialProgressIndicator({
    Key? key,
    required this.currentStage,
    required this.totalStages,
    required this.stages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withAlpha(51),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStage + 1) / totalStages,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                stages[currentStage]['color'],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Stage indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalStages, (index) {
            final isActive = index == currentStage;
            final isCompleted = index < currentStage;
            final stage = stages[index];

            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.green
                    : isActive
                        ? stage['color']
                        : Colors.white.withAlpha(77),
                border: Border.all(
                  color:
                      isActive ? stage['color'] : Colors.white.withAlpha(128),
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : stage['icon'],
                color: Colors.white,
                size: 20,
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Stage title
        Text(
          '${currentStage + 1} of $totalStages: ${stages[currentStage]['title']}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

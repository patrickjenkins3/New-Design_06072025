import 'package:flutter/material.dart';

class PersonalizationDialogWidget extends StatefulWidget {
  final String? userType;
  final Function(Map<String, dynamic>) onSave;

  const PersonalizationDialogWidget({
    Key? key,
    this.userType,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PersonalizationDialogWidget> createState() =>
      _PersonalizationDialogWidgetState();
}

class _PersonalizationDialogWidgetState
    extends State<PersonalizationDialogWidget> {
  String? _selectedUserType;
  int? _graduationYear;
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedLocations = {};

  final List<String> _collegeInterests = [
    'Computer Science',
    'Engineering',
    'Business',
    'Medicine',
    'Arts & Design',
    'Psychology',
    'Education',
    'Law',
    'Environmental Science',
    'Economics',
  ];

  final List<String> _locationPreferences = [
    'California',
    'New York',
    'Texas',
    'Florida',
    'Massachusetts',
    'Illinois',
    'Pennsylvania',
    'North Carolina',
    'Washington',
    'Georgia',
  ];

  @override
  void initState() {
    super.initState();
    _selectedUserType = widget.userType;
    _graduationYear = DateTime.now().year + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personalize Your Journey',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C63FF),
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User type selection
                    Text(
                      'I am a...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildUserTypeCard(
                            'Parent',
                            Icons.family_restroom,
                            'Supporting my teen\'s college journey',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUserTypeCard(
                            'Teen',
                            Icons.school,
                            'Planning my college application',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Graduation year
                    Text(
                      'Expected Graduation Year',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _graduationYear,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: List.generate(8, (index) {
                        final year = DateTime.now().year + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) =>
                          setState(() => _graduationYear = value),
                    ),

                    const SizedBox(height: 24),

                    // College interests
                    Text(
                      'Areas of Interest',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _collegeInterests.map((interest) {
                        final isSelected =
                            _selectedInterests.contains(interest);
                        return FilterChip(
                          label: Text(interest),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInterests.add(interest);
                              } else {
                                _selectedInterests.remove(interest);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF6C63FF).withAlpha(51),
                          checkmarkColor: const Color(0xFF6C63FF),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Location preferences
                    Text(
                      'Preferred Locations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _locationPreferences.map((location) {
                        final isSelected =
                            _selectedLocations.contains(location);
                        return FilterChip(
                          label: Text(location),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLocations.add(location);
                              } else {
                                _selectedLocations.remove(location);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF4ECDC4).withAlpha(51),
                          checkmarkColor: const Color(0xFF4ECDC4),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedUserType != null ? _savePersonalization : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String type, IconData icon, String description) {
    final isSelected = _selectedUserType == type.toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = type.toLowerCase()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withAlpha(26)
              : Colors.grey.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : Colors.grey.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _savePersonalization() {
    widget.onSave({
      'userType': _selectedUserType,
      'graduationYear': _graduationYear,
      'collegeInterests': _selectedInterests.toList(),
      'locationPreferences': _selectedLocations.toList(),
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Preferences saved! Your experience is now personalized.'),
        backgroundColor: Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cf_bottom_nav.dart';

class ScholarshipFeedScreen extends StatefulWidget {
  const ScholarshipFeedScreen({super.key});
  @override
  State<ScholarshipFeedScreen> createState() => _ScholarshipFeedScreenState();
}

class _ScholarshipFeedScreenState extends State<ScholarshipFeedScreen> {
  final _searchCtrl = TextEditingController();
  final List<_ScholarshipData> _all = const [
    _ScholarshipData(title: 'National Merit Scholarship', org: 'National Merit Scholarship Corporation',
      amount: 2500, deadline: 'March 31, 2026', tags: ['Merit', 'Community Service'], match: 95, applied: false, expired: false),
    _ScholarshipData(title: 'National Merit Scholarship', org: 'National Merit Scholarship Corporation',
      amount: 2500, deadline: 'March 31, 2026', tags: ['Leadership Experience', 'Community Service'], match: 95, applied: false, expired: true),
    _ScholarshipData(title: 'STEM Excellence Award', org: 'National STEM Foundation',
      amount: 5000, deadline: 'April 15, 2026', tags: ['STEM Field', 'Academic Merit'], match: 88, applied: true, expired: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryBlack : AppTheme.grey50,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            color: isDark ? AppTheme.surfaceBlack : AppTheme.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
                const SizedBox(width: 4),
                Text('Scholarships', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                Text('${_all.length} scholarships', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search scholarships...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.grey500),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: isDark ? AppTheme.cardBlack : AppTheme.grey100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showFilters(),
                  child: Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: isDark ? AppTheme.cardBlack : AppTheme.grey100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.tune, size: 20)),
                ),
              ]),
              const SizedBox(height: 10),
              // Deadline filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppTheme.teal),
                  const SizedBox(width: 6),
                  Text('Due: March 31, 2026 (130 days left)', style: const TextStyle(color: AppTheme.teal, fontSize: 12, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.close, size: 14, color: AppTheme.teal),
                ]),
              ),
            ]),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ScholarshipCard(data: _all[i]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: CFBottomNav(currentIndex: 2, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
        else if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.calendarScreen);
        else if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileSettingsScreen);
      }),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ScholarshipFiltersSheet(),
    );
  }
}

class _ScholarshipData {
  final String title, org;
  final int amount;
  final String deadline;
  final List<String> tags;
  final int match;
  final bool applied, expired;
  const _ScholarshipData({required this.title, required this.org, required this.amount, required this.deadline, required this.tags, required this.match, required this.applied, required this.expired});
}

class _ScholarshipCard extends StatelessWidget {
  final _ScholarshipData data;
  const _ScholarshipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBlack : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(data.title, style: Theme.of(context).textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data.expired ? AppTheme.grey100 : AppTheme.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: data.expired ? AppTheme.grey300 : AppTheme.teal.withValues(alpha: 0.3)),
            ),
            child: Text(data.expired ? 'Expired' : 'Profile Match',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: data.expired ? AppTheme.grey500 : AppTheme.teal)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(data.org, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
        const SizedBox(height: 10),
        // Description area
        Text(
          'Recognizes high school juniors for their leadership, as well as their nonacademic accomplishments.',
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 4, children: data.tags.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100, borderRadius: BorderRadius.circular(4)),
          child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        )).toList()),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('\$${data.amount.toString()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text('Award', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
          ]),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data.match.toString() + '%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.teal)),
            Text('Profile Match', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500)),
          ]),
          const Spacer(),
          if (!data.expired && !data.applied) ...[
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
              child: const Text('Apply Now', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
              child: const Text('Mark Applied', style: TextStyle(fontSize: 12)),
            ),
          ],
          if (data.applied)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('Applied ✓', style: TextStyle(color: AppTheme.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ]),
      ]),
    );
  }
}

class _ScholarshipFiltersSheet extends StatefulWidget {
  const _ScholarshipFiltersSheet();
  @override
  State<_ScholarshipFiltersSheet> createState() => _ScholarshipFiltersSheetState();
}

class _ScholarshipFiltersSheetState extends State<_ScholarshipFiltersSheet> {
  RangeValues _award = const RangeValues(0, 40000);
  String _schoolType = 'College';
  String _status = 'High School Senior';
  final List<String> _fields = [];
  final List<String> _docs = [];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.9, maxChildSize: 0.95,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const Divider(),
          Expanded(child: ListView(controller: ctrl, children: [
            _FilterSection(title: 'AWARD RANGE', child: Column(children: [
              RangeSlider(values: _award, min: 0, max: 40000, activeColor: AppTheme.teal,
                labels: RangeLabels('\$${(_award.start / 1000).round()}k', '\$${(_award.end / 1000).round()}k'),
                onChanged: (v) => setState(() => _award = v)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${(_award.start / 1000).round()}k', style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
                Text('\$${(_award.end / 1000).round()}k', style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
              ]),
            ])),
            _FilterSection(title: 'SCHOOL TYPE', child: Wrap(spacing: 8, children:
              ['College', 'Trade School', 'Military'].map((t) => ChoiceChip(
                label: Text(t), selected: _schoolType == t, onSelected: (_) => setState(() => _schoolType = t),
              )).toList())),
            _FilterSection(title: 'STUDENT STATUS', child: Wrap(spacing: 8, runSpacing: 6, children:
              ['High School Senior', 'College Freshman', 'College Sophomore', 'College Junior', 'College Senior', 'Graduate Student', 'Community College', 'Trade School', 'Military Family', 'First Generation', 'Minority Student']
              .map((s) => ChoiceChip(label: Text(s, style: const TextStyle(fontSize: 12)), selected: _status == s,
                onSelected: (_) => setState(() => _status = s))).toList())),
            _FilterSection(title: 'STUDENT FIELD', child: Wrap(spacing: 8, runSpacing: 6, children:
              ['STEM Field', 'Arts & Humanities', 'Business', 'Healthcare'].map((f) => FilterChip(
                label: Text(f, style: const TextStyle(fontSize: 12)), selected: _fields.contains(f),
                onSelected: (v) => setState(() => v ? _fields.add(f) : _fields.remove(f)),
              )).toList())),
            _FilterSection(title: 'REQUIRED DOCUMENTS', child: Wrap(spacing: 8, runSpacing: 6, children:
              ['Essay Required', 'Transcript Required', 'Letters of Recommendation', 'Portfolio Required', 'Interview Required']
              .map((d) => FilterChip(label: Text(d, style: const TextStyle(fontSize: 12)), selected: _docs.contains(d),
                onSelected: (v) => setState(() => v ? _docs.add(d) : _docs.remove(d)))).toList())),
            _FilterSection(title: 'CRITERIA', child: Wrap(spacing: 8, children:
              ['Community Service', 'Financial Need', 'Academic Merit', 'Leadership Experience', 'Extracurricular Activities']
              .map((c) => FilterChip(label: Text(c, style: const TextStyle(fontSize: 12)), selected: false, onSelected: (_) {})).toList())),
            const SizedBox(height: 80),
          ])),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Reset'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Apply'))),
          ]),
        ]),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title; final Widget child;
  const _FilterSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500, letterSpacing: 1)),
      const SizedBox(height: 10),
      child,
    ]),
  );
}

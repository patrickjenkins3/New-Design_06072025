import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cf_bottom_nav.dart';
import '../../services/external_api_service.dart';
import '../../models/college_scorecard_model.dart';

class SchoolSearchScreen extends StatefulWidget {
  const SchoolSearchScreen({super.key});
  @override
  State<SchoolSearchScreen> createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends State<SchoolSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focus = FocusNode();
  bool _searching = false;
  bool _showRecent = true;
  List<CollegeScoreCardModel> _results = [];
  List<String> _recentSearches = ['Link', 'Link', 'Link', 'Link'];
  String? _error;

  final List<String> _sortOptions = ['Relevance', 'Name', 'Acceptance Rate', 'Tuition'];
  String _sort = 'Relevance';

  @override
  void dispose() { _searchCtrl.dispose(); _focus.dispose(); super.dispose(); }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) { setState(() { _showRecent = true; _results = []; }); return; }
    setState(() { _searching = true; _showRecent = false; _error = null; });
    try {
      final res = await ExternalApiService.instance.searchColleges(schoolName: q.trim());
      if (mounted) setState(() { _results = res; _searching = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Unable to search. Check your connection.'; _searching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryBlack : AppTheme.white,
      body: SafeArea(
        child: Column(children: [
          // ── Search header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardBlack : AppTheme.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _focus,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search colleges, trade schools...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.grey500),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () { _searchCtrl.clear(); _search(''); })
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                    onChanged: (v) { setState(() {}); },
                    onSubmitted: (v) { _search(v); if (v.isNotEmpty) _recentSearches = [v, ..._recentSearches.take(3)]; },
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showFilters(),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardBlack : AppTheme.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune, size: 20),
                ),
              ),
            ]),
          ),

          // ── Results header ────────────────────────────────────
          if (!_showRecent && _results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                Text('${_results.length} schools found', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
                const Spacer(),
                Text('Sort by: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
                DropdownButton<String>(
                  value: _sort,
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(color: AppTheme.teal, fontSize: 13, fontWeight: FontWeight.w600),
                  items: _sortOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ]),
            ),

          const SizedBox(height: 12),

          Expanded(child: _showRecent ? _buildRecent() : _buildResults()),
        ]),
      ),
      bottomNavigationBar: CFBottomNav(currentIndex: 0, onTap: (i) {
        if (i == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboardScreen);
        else if (i == 1) Navigator.pushReplacementNamed(context, AppRoutes.calendarScreen);
        else if (i == 2) Navigator.pushReplacementNamed(context, AppRoutes.scholarshipFeedScreen);
        else if (i == 3) Navigator.pushReplacementNamed(context, AppRoutes.profileSettingsScreen);
      }),
    );
  }

  Widget _buildRecent() {
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
      Text('RECENT SEARCHES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.grey500, letterSpacing: 1)),
      const SizedBox(height: 8),
      ..._recentSearches.map((s) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.history, color: AppTheme.grey500, size: 18),
        title: Text(s, style: Theme.of(context).textTheme.bodyMedium),
        trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: AppTheme.grey500),
          onPressed: () => setState(() => _recentSearches.remove(s))),
        onTap: () { _searchCtrl.text = s; _search(s); },
      )),
    ]);
  }

  Widget _buildResults() {
    if (_searching) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: AppTheme.grey500)));
    if (_results.isEmpty) return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off, size: 48, color: AppTheme.grey300),
        const SizedBox(height: 12),
        Text('No schools found', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Try adjusting your search', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
      ]),
    );
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _SchoolResultCard(school: _results[i]),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _SchoolFiltersSheet(),
    );
  }
}

class _SchoolResultCard extends StatelessWidget {
  final CollegeScoreCardModel school;
  const _SchoolResultCard({required this.school});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.schoolDetailScreen, arguments: school),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardBlack : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.dividerBlack : AppTheme.grey100),
        ),
        child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AppTheme.primaryBlack,
            child: Text(school.name.isNotEmpty ? school.name[0] : '?',
              style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(school.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${school.city ?? ''}, ${school.state ?? ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grey500)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              _Tag('Private'),
              if (school.inStateTuition != null) _Tag('\$${_fmt(school.inStateTuition!)}'),
            ]),
          ])),
          const Icon(Icons.chevron_right, color: AppTheme.grey300),
        ]),
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}k' : '$n';
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: AppTheme.grey100, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.grey700)),
  );
}

class _SchoolFiltersSheet extends StatefulWidget {
  const _SchoolFiltersSheet();
  @override
  State<_SchoolFiltersSheet> createState() => _SchoolFiltersSheetState();
}

class _SchoolFiltersSheetState extends State<_SchoolFiltersSheet> {
  String _schoolType = 'College';
  String _location = 'Anywhere';
  String _enrollment = 'Any';
  RangeValues _tuition = const RangeValues(0, 80000);
  double _acceptance = 100;

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
            _FilterSection(title: 'SCHOOL TYPE', child: Wrap(spacing: 8, children:
              ['College', 'Trade School', 'Military'].map((t) => ChoiceChip(
                label: Text(t), selected: _schoolType == t,
                onSelected: (_) => setState(() => _schoolType = t),
              )).toList(),
            )),
            _FilterSection(title: 'LOCATION', child: Wrap(spacing: 8, children:
              ['Within 50 miles', 'Within 100 miles', 'Within 200 miles', 'Anywhere'].map((l) => ChoiceChip(
                label: Text(l), selected: _location == l,
                onSelected: (_) => setState(() => _location = l),
              )).toList(),
            )),
            _FilterSection(title: 'ENROLLMENT SIZE', child: Wrap(spacing: 8, children:
              ['Small (< 5,000)', 'Medium (5,000 - 15,000)', 'Large (> 15,000)'].map((e) => ChoiceChip(
                label: Text(e, style: const TextStyle(fontSize: 12)), selected: _enrollment == e,
                onSelected: (_) => setState(() => _enrollment = e),
              )).toList(),
            )),
            _FilterSection(title: 'TUITION RANGE', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RangeSlider(
                values: _tuition, min: 0, max: 80000,
                activeColor: AppTheme.teal,
                labels: RangeLabels('\$${(_tuition.start / 1000).round()}k', '\$${(_tuition.end / 1000).round()}k'),
                onChanged: (v) => setState(() => _tuition = v),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\$${(_tuition.start / 1000).round()}k', style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
                Text('\$${(_tuition.end / 1000).round()}k', style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
              ]),
            ])),
            _FilterSection(title: 'ACCEPTANCE RATE', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Slider(value: _acceptance, min: 0, max: 100, activeColor: AppTheme.teal,
                onChanged: (v) => setState(() => _acceptance = v)),
              Text('Up to ${_acceptance.round()}%', style: const TextStyle(fontSize: 12, color: AppTheme.grey500)),
            ])),
            _FilterSection(title: 'ADVANCED FILTERS', child: Wrap(spacing: 8, children: [
              FilterChip(label: const Text('Has Online Programs'), onSelected: (_) {}, selected: false),
              FilterChip(label: const Text('Offers Financial Aid'), onSelected: (_) {}, selected: false),
              FilterChip(label: const Text('NCAA Division I'), onSelected: (_) {}, selected: false),
              FilterChip(label: const Text('STEM Programs'), onSelected: (_) {}, selected: false),
            ])),
            const SizedBox(height: 80),
          ])),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() {
              _schoolType = 'College'; _location = 'Anywhere'; _tuition = const RangeValues(0, 80000); _acceptance = 100;
            }), child: const Text('Reset'))),
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

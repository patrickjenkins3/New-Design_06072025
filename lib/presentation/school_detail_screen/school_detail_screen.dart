import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_to_list_bottom_sheet.dart';
import './widgets/admissions_tab_widget.dart';
import './widgets/campus_life_tab_widget.dart';
import './widgets/costs_tab_widget.dart';
import './widgets/family_notes_widget.dart';
import './widgets/overview_tab_widget.dart';
import './widgets/programs_tab_widget.dart';
import './widgets/school_header_widget.dart';
import './widgets/school_tabs_widget.dart';
import './widgets/visit_tab_widget.dart';

class SchoolDetailScreen extends StatefulWidget {
  const SchoolDetailScreen({Key? key}) : super(key: key);

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  List<Map<String, dynamic>> _familyNotes = [];

  final List<String> _tabs = [
    "Overview",
    "Admissions",
    "Programs",
    "Campus Life",
    "Visit",
    "Costs"
  ];

  // Mock school data
  final Map<String, dynamic> _schoolData = {
    "id": "1",
    "name": "Stanford University",
    "city": "Stanford",
    "state": "California",
    "headerImage":
        "https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "logo":
        "https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=400",
    "description":
        """Stanford University is a private research university in Stanford, California. The campus occupies 8,180 acres, among the largest in the United States, and enrolls over 17,000 students. Stanford is ranked among the world's top universities.""",
    "statistics": {
      "acceptanceRate": 4,
      "enrollment": 17249,
      "studentFacultyRatio": 5,
      "graduationRate": 94,
    },
    "quickFacts": [
      {"icon": "calendar_today", "title": "Founded", "value": "1885"},
      {
        "icon": "school",
        "title": "Type",
        "value": "Private Research University"
      },
      {"icon": "location_city", "title": "Setting", "value": "Suburban"},
      {"icon": "groups", "title": "Student Body", "value": "Highly Diverse"}
    ],
    "admissions": {
      "applicationDeadline": "2025-01-05",
      "requirements": [
        {
          "title": "Common Application",
          "description": "Submit through Common App platform",
          "completed": true
        },
        {
          "title": "SAT/ACT Scores",
          "description": "Optional for 2024-2025 cycle",
          "completed": false
        },
        {
          "title": "Letters of Recommendation",
          "description": "2 teacher recommendations required",
          "completed": false
        },
        {
          "title": "Personal Essays",
          "description": "Stanford supplemental essays",
          "completed": false
        },
        {
          "title": "High School Transcript",
          "description": "Official transcript required",
          "completed": true
        }
      ],
      "testScores": {
        "SAT": {"percentile25": 1470, "percentile75": 1570, "average": 1520},
        "ACT": {"percentile25": 33, "percentile75": 35, "average": 34}
      },
      "importantDates": [
        {"title": "Early Action Deadline", "date": "2024-11-01"},
        {"title": "Regular Decision Deadline", "date": "2025-01-05"},
        {"title": "Financial Aid Deadline", "date": "2025-02-15"}
      ]
    },
    "programs": [
      {
        "name": "Computer Science",
        "category": "Engineering",
        "description":
            "World-renowned program combining theoretical foundations with practical applications in artificial intelligence, systems, and human-computer interaction.",
        "duration": "4 years",
        "degreeType": "Bachelor of Science",
        "careerPaths": [
          "Software Engineer",
          "Data Scientist",
          "Product Manager",
          "Research Scientist"
        ]
      },
      {
        "name": "Business Administration",
        "category": "Business",
        "description":
            "Comprehensive program covering finance, marketing, operations, and entrepreneurship with strong emphasis on innovation and leadership.",
        "duration": "4 years",
        "degreeType": "Bachelor of Arts",
        "careerPaths": [
          "Management Consultant",
          "Investment Banker",
          "Entrepreneur",
          "Marketing Manager"
        ]
      },
      {
        "name": "Biomedical Engineering",
        "category": "Engineering",
        "description":
            "Interdisciplinary program combining engineering principles with biological sciences to develop medical technologies and treatments.",
        "duration": "4 years",
        "degreeType": "Bachelor of Science",
        "careerPaths": [
          "Biomedical Engineer",
          "Medical Device Designer",
          "Research Scientist",
          "Healthcare Consultant"
        ]
      },
      {
        "name": "Psychology",
        "category": "Science",
        "description":
            "Comprehensive study of human behavior, cognition, and mental processes with opportunities for research and clinical experience.",
        "duration": "4 years",
        "degreeType": "Bachelor of Arts",
        "careerPaths": [
          "Clinical Psychologist",
          "Research Psychologist",
          "Counselor",
          "Human Resources Specialist"
        ]
      }
    ],
    "campusLife": {
      "photos": [
        {
          "url":
              "https://images.pexels.com/photos/1454360/pexels-photo-1454360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "caption": "Main Quad - Heart of campus life"
        },
        {
          "url":
              "https://images.pexels.com/photos/159775/library-la-trobe-study-students-159775.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "caption": "Green Library - 24/7 study spaces"
        },
        {
          "url":
              "https://images.pexels.com/photos/1205651/pexels-photo-1205651.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
          "caption": "Student Recreation Center"
        }
      ],
      "activities": [
        {"name": "Student Organizations", "count": 650, "icon": "groups"},
        {"name": "Intramural Sports", "count": 45, "icon": "sports_soccer"},
        {"name": "Greek Life", "count": 25, "icon": "celebration"},
        {"name": "Research Programs", "count": 120, "icon": "science"}
      ],
      "housing": [
        {
          "name": "Freshman Dorms",
          "type": "Traditional Residence Hall",
          "cost": "\$8,500/year",
          "description":
              "All first-year students live on campus in themed residential communities with faculty-in-residence.",
          "amenities": [
            "Dining Hall",
            "Study Rooms",
            "Laundry",
            "Common Areas",
            "24/7 Security"
          ]
        },
        {
          "name": "Upperclass Housing",
          "type": "Apartment Style",
          "cost": "\$9,200/year",
          "description":
              "Suite-style living with kitchen facilities and more independence for upperclass students.",
          "amenities": [
            "Kitchen",
            "Private Bathroom",
            "Study Spaces",
            "Fitness Room",
            "Parking"
          ]
        }
      ]
    },
    "costs": {
      "totalAnnualCost": 82162,
      "averageAfterAid": 23500,
      "breakdown": {
        "tuition": 56169,
        "room_board": 17255,
        "books_supplies": 1245,
        "personal_expenses": 2493,
        "transportation": 5000
      },
      "financialAid": {
        "percentageReceiving": 58,
        "averageGrant": 53000,
        "averageLoan": 8500
      },
      "paymentOptions": [
        {
          "title": "Monthly Payment Plan",
          "description":
              "Spread costs over 10 monthly payments with no interest",
          "icon": "payment"
        },
        {
          "title": "Merit Scholarships",
          "description": "Academic and talent-based scholarships available",
          "icon": "school"
        },
        {
          "title": "Work-Study Program",
          "description": "On-campus employment opportunities for students",
          "icon": "work"
        }
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _initializeFamilyNotes();
  }

  void _initializeFamilyNotes() {
    _familyNotes = [
      {
        "id": "1",
        "author": "Parent",
        "content":
            "The computer science program looks incredible! The research opportunities and Silicon Valley connections could be perfect for Sarah's career goals.",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "replies": [
          {
            "author": "Teen",
            "content":
                "I'm really excited about the AI research lab! Did you see they have partnerships with major tech companies?",
            "timestamp": DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          }
        ]
      },
      {
        "id": "2",
        "author": "Teen",
        "content":
            "The campus looks amazing in the photos. I love how it's not too urban but still close to everything. The housing options seem really good too.",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        "replies": []
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SchoolHeaderWidget(
              schoolData: _schoolData,
              isFavorite: _isFavorite,
              onFavoriteToggle: _toggleFavorite,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                SchoolTabsWidget(
                  tabController: _tabController,
                  tabs: _tabs,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            OverviewTabWidget(schoolData: _schoolData),
            AdmissionsTabWidget(schoolData: _schoolData),
            ProgramsTabWidget(schoolData: _schoolData),
            CampusLifeTabWidget(schoolData: _schoolData),
            VisitTabWidget(schoolData: _schoolData),
            CostsTabWidget(schoolData: _schoolData),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          onPressed: _showFamilyNotes,
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          icon: CustomIconWidget(
            iconName: 'family_restroom',
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            "Notes",
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        FloatingActionButton.extended(
          onPressed: _showActionMenu,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            "Actions",
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    Fluttertoast.showToast(
      msg: _isFavorite ? "Added to favorites" : "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            _buildActionTile(
              "Add to List",
              "Save to your school lists",
              "playlist_add",
              AppTheme.lightTheme.colorScheme.primary,
              _showAddToListSheet,
            ),
            _buildActionTile(
              "Share School",
              "Share with family and friends",
              "share",
              AppTheme.lightTheme.colorScheme.secondary,
              _shareSchool,
            ),
            _buildActionTile(
              "Schedule Visit",
              "Plan a campus visit",
              "event",
              AppTheme.lightTheme.colorScheme.tertiary,
              _scheduleVisit,
            ),
            _buildActionTile(
              "Compare Schools",
              "Add to comparison view",
              "compare",
              Colors.green,
              _addToComparison,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, String iconName,
      Color color, VoidCallback onTap) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
    );
  }

  void _showAddToListSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToListBottomSheet(
        schoolName: _schoolData["name"] as String,
        onAddToExistingList: (listName) {
          Fluttertoast.showToast(
            msg: "Added to $listName",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        onCreateNewList: (listName) {
          Fluttertoast.showToast(
            msg: "Created '$listName' and added school",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _shareSchool() {
    final schoolName = _schoolData["name"] as String;
    final location = "${_schoolData["city"]}, ${_schoolData["state"]}";
    final acceptanceRate = _schoolData["statistics"]["acceptanceRate"];

    Share.share(
      "Check out $schoolName in $location! 🎓\n\n"
      "• Acceptance Rate: $acceptanceRate%\n"
      "• Enrollment: ${_schoolData["statistics"]["enrollment"]} students\n"
      "• Student-Faculty Ratio: ${_schoolData["statistics"]["studentFacultyRatio"]}:1\n\n"
      "Shared from ScholarPath app",
      subject: "School Information: $schoolName",
    );
  }

  void _scheduleVisit() {
    Fluttertoast.showToast(
      msg: "Visit scheduling feature coming soon!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _addToComparison() {
    Fluttertoast.showToast(
      msg: "Added to comparison list",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showFamilyNotes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FamilyNotesWidget(
        notes: _familyNotes,
        onAddNote: _addFamilyNote,
      ),
    );
  }

  void _addFamilyNote(String content, String author) {
    setState(() {
      _familyNotes.insert(0, {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "author": author,
        "content": content,
        "timestamp": DateTime.now().toIso8601String(),
        "replies": [],
      });
    });

    Fluttertoast.showToast(
      msg: "Note added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tabBar;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

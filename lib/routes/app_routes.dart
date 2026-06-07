import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/school_search_screen/school_search_screen.dart';
import '../presentation/calendar_screen/calendar_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/scholarship_feed_screen/scholarship_feed_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../presentation/counselor_invitation_screen/counselor_invitation_screen.dart';
import '../presentation/school_detail_screen/school_detail_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/about_us_screen/about_us_screen.dart';
import '../presentation/ai_support_screen/ai_support_screen.dart';
import '../presentation/tasks_screen/tasks_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/free_trial_dashboard_screen/free_trial_dashboard_screen.dart';
import '../presentation/progressive_registration_screen/progressive_registration_screen.dart';
import '../presentation/interactive_onboarding_tutorial_screen/interactive_onboarding_tutorial_screen.dart';
import '../presentation/security_settings_screen/security_settings_screen.dart';
import '../presentation/app_lock_screen/app_lock_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route name constants
  static const String splashScreen                       = '/splash-screen';
  static const String dashboardScreen                    = '/dashboard-screen';
  static const String profileSettingsScreen              = '/profile-settings-screen';
  static const String schoolSearchScreen                 = '/school-search-screen';
  static const String calendarScreen                     = '/calendar-screen';
  static const String loginScreen                        = '/login-screen';
  static const String scholarshipFeedScreen              = '/scholarship-feed-screen';
  static const String subscriptionScreen                 = '/subscription-screen';
  static const String counselorInvitationScreen          = '/counselor-invitation-screen';
  static const String schoolDetailScreen                 = '/school-detail-screen';
  static const String paymentScreen                      = '/payment-screen';
  static const String aboutUsScreen                      = '/about-us-screen';
  static const String aiSupportScreen                    = '/ai-support-screen';
  static const String tasksScreen                        = '/tasks-screen';
  static const String settingsScreen                     = '/settings-screen';
  static const String freeTrialDashboardScreen           = '/free-trial-dashboard-screen';
  static const String progressiveRegistrationScreen      = '/progressive-registration-screen';
  static const String registrationScreen                 = '/progressive-registration-screen'; // alias
  static const String interactiveOnboardingTutorialScreen = '/interactive-onboarding-tutorial-screen';
  static const String securitySettingsScreen             = '/security-settings-screen';
  static const String appLockScreen                      = '/app-lock-screen';

  static final Map<String, WidgetBuilder> routes = {
    splashScreen:                        (c) => const SplashScreen(),
    dashboardScreen:                     (c) => const DashboardScreen(),
    profileSettingsScreen:               (c) => const ProfileSettingsScreen(),
    schoolSearchScreen:                  (c) => const SchoolSearchScreen(),
    calendarScreen:                      (c) => const CalendarScreen(),
    loginScreen:                         (c) => const LoginScreen(),
    scholarshipFeedScreen:               (c) => const ScholarshipFeedScreen(),
    subscriptionScreen:                  (c) => const SubscriptionScreen(),
    counselorInvitationScreen:           (c) => const CounselorInvitationScreen(),
    schoolDetailScreen:                  (c) => const SchoolDetailScreen(),
    paymentScreen:                       (c) => const PaymentScreen(),
    aboutUsScreen:                       (c) => const AboutUsScreen(),
    aiSupportScreen:                     (c) => const AISupportScreen(),
    tasksScreen:                         (c) => const TasksScreen(),
    settingsScreen:                      (c) => const SettingsScreen(),
    freeTrialDashboardScreen:            (c) => const FreeTrialDashboardScreen(),
    progressiveRegistrationScreen:       (c) => const ProgressiveRegistrationScreen(),
    interactiveOnboardingTutorialScreen: (c) => const InteractiveOnboardingTutorialScreen(),
    securitySettingsScreen:              (c) => const SecuritySettingsScreen(),
    appLockScreen:                       (c) => const AppLockScreen(),
  };
}

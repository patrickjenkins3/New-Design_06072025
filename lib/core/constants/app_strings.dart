
/// Centralized string constants for the CollabFuture application
/// All user-facing text should be defined here for easy maintenance and localization
class AppStrings {
  AppStrings._();

  // App Information
  static const String appName = 'CollabFuture';
  static const String appTagline =
      'Collaborative Educational Planning Platform';
  static const String appDescription =
      'Connect students, families, and counselors for academic success';

  // Common Actions
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String close = 'Close';
  static const String refresh = 'Refresh';
  static const String tryAgain = 'Try Again';

  // Navigation
  static const String home = 'Home';
  static const String dashboard = 'Dashboard';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String calendar = 'Calendar';
  static const String tasks = 'Tasks';
  static const String scholarships = 'Scholarships';
  static const String schools = 'Schools';
  static const String aiSupport = 'AI Support';
  static const String notifications = 'Notifications';
  static const String help = 'Help';
  static const String about = 'About';

  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String fullName = 'Full Name';

  // Enhanced Form Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 12 characters';
  static const String passwordComplexityRequired =
      'Password must include uppercase, lowercase, numbers, and special characters';
  static const String passwordTooWeak =
      'Password is too weak. Avoid common words and patterns';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String pinTooShort = 'PIN must be 4-8 digits';
  static const String pinTooWeak =
      'PIN is too weak. Avoid repeating or sequential numbers';
  static const String invalidInput = 'Please check your input and try again';

  // User-Friendly Error Messages
  static const String networkError =
      'Connection issue. Please check your internet and try again.';
  static const String serverError =
      'Service temporarily unavailable. Please try again later.';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String authenticationError = 'Please sign in to continue.';
  static const String permissionDenied =
      'You don\'t have permission to access this feature.';
  static const String notFound =
      'The content you\'re looking for isn\'t available.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String loadingDataError = 'Unable to load data. Please refresh.';
  static const String saveDataError =
      'Unable to save changes. Please try again.';
  static const String invalidCredentials =
      'Email or password is incorrect. Please try again.';
  static const String accountLocked =
      'Your account has been temporarily locked for security. Please try again in 30 minutes.';
  static const String tooManyAttempts =
      'Too many failed attempts. Please wait a moment and try again.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';

  // Enhanced Security Messages
  static const String securityFeatureUnavailable =
      'This security feature is currently unavailable. Please try again later.';
  static const String biometricNotAvailable =
      'Biometric authentication is not available on this device.';
  static const String pinSetupRequired =
      'Please set up a PIN to use this feature.';
  static const String dataEncryptionError =
      'Unable to secure your data. Please try again.';
  static const String securityVulnerabilityFixed =
      'Security vulnerabilities have been addressed. Your data is now more secure.';
  static const String strongPasswordRequired =
      'Strong password required for enhanced security';
  static const String secureEncryptionEnabled =
      'End-to-end encryption is now active for your data';

  // Success Messages
  static const String saveSuccess = 'Changes saved successfully!';
  static const String updateSuccess = 'Updated successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
  static const String emailSent = 'Email sent successfully!';
  static const String passwordUpdated = 'Password updated successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String securityUpdated =
      'Security settings updated successfully!';

  // Dashboard
  static const String welcomeBack = 'Welcome back!';
  static const String todaysTasks = 'Today\'s Tasks';
  static const String upcomingDeadlines = 'Upcoming Deadlines';
  static const String recentActivity = 'Recent Activity';
  static const String quickActions = 'Quick Actions';
  static const String progressOverview = 'Progress Overview';

  // Tasks & Calendar
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String taskTitle = 'Task Title';
  static const String taskDescription = 'Description';
  static const String taskDueDate = 'Due Date';
  static const String taskPriority = 'Priority';
  static const String taskComplete = 'Mark Complete';
  static const String taskIncomplete = 'Mark Incomplete';
  static const String noTasksToday = 'No tasks for today';
  static const String upcomingTasks = 'Upcoming Tasks';
  static const String completedTasks = 'Completed Tasks';

  // Schools & Search
  static const String searchSchools = 'Search Schools';
  static const String schoolDetails = 'School Details';
  static const String addToList = 'Add to My List';
  static const String removeFromList = 'Remove from List';
  static const String viewDetails = 'View Details';
  static const String compareSchools = 'Compare Schools';
  static const String favoriteSchools = 'My Favorite Schools';
  static const String appliedSchools = 'Applied Schools';

  // AI Support
  static const String askAI = 'Ask AI';
  static const String aiChat = 'AI Chat';
  static const String typeMessage = 'Type your message...';
  static const String aiThinking = 'AI is thinking...';
  static const String aiHelp = 'How can I help you today?';
  static const String clearChat = 'Clear Chat';

  // Profile & Settings
  static const String editProfile = 'Edit Profile';
  static const String changePassword = 'Change Password';
  static const String accountSettings = 'Account Settings';
  static const String privacySettings = 'Privacy Settings';
  static const String notificationSettings = 'Notification Settings';
  static const String themeSettings = 'Theme Settings';
  static const String language = 'Language';
  static const String timeZone = 'Time Zone';
  static const String deleteAccount = 'Delete Account';
  static const String lightTheme = 'Light Theme';
  static const String darkTheme = 'Dark Theme';
  static const String systemTheme = 'System Theme';

  // Subscriptions & Payments
  static const String subscription = 'Subscription';
  static const String upgrade = 'Upgrade';
  static const String billing = 'Billing';
  static const String paymentHistory = 'Payment History';
  static const String manageSubscription = 'Manage Subscription';
  static const String freePlan = 'Free Plan';
  static const String premiumPlan = 'Premium Plan';
  static const String familyPlan = 'Family Plan';
  static const String monthlyBilling = 'Monthly';
  static const String annualBilling = 'Annual';
  static const String paymentProcessing = 'Processing payment...';
  static const String paymentFailed = 'Payment failed. Please try again.';
  static const String paymentSuccess = 'Payment successful!';

  // Family & Sharing
  static const String familyMembers = 'Family Members';
  static const String inviteFamily = 'Invite Family Member';
  static const String familyCode = 'Family Code';
  static const String shareProgress = 'Share Progress';
  static const String familySettings = 'Family Settings';

  // Educational Content
  static const String collegePrep = 'College Prep';
  static const String scholarshipSearch = 'Scholarship Search';
  static const String careerExploration = 'Career Exploration';
  static const String academicPlanning = 'Academic Planning';
  static const String testPrep = 'Test Preparation';
  static const String applicationDeadlines = 'Application Deadlines';

  // Time & Dates
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String yesterday = 'Yesterday';
  static const String thisWeek = 'This Week';
  static const String nextWeek = 'Next Week';
  static const String thisMonth = 'This Month';
  static const String nextMonth = 'Next Month';
  static const String dueToday = 'Due Today';
  static const String overdue = 'Overdue';

  // Progress & Statistics
  static const String completionRate = 'Completion Rate';
  static const String tasksCompleted = 'Tasks Completed';
  static const String deadlinesMet = 'Deadlines Met';
  static const String hoursStudied = 'Hours Studied';
  static const String goalsAchieved = 'Goals Achieved';
  static const String weeklyProgress = 'Weekly Progress';
  static const String monthlyProgress = 'Monthly Progress';

  // Help & Support
  static const String contactSupport = 'Contact Support';
  static const String faq = 'Frequently Asked Questions';
  static const String userGuide = 'User Guide';
  static const String reportIssue = 'Report an Issue';
  static const String featureRequest = 'Feature Request';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';

  // Demo & Testing - Now using environment variables
  static const String demoMode = 'Demo Mode';
  static const String demoCredentials =
      'Use demo credentials to explore the app';
  static String get demoEmail => const String.fromEnvironment('DEMO_EMAIL',
      defaultValue: 'demo@collabfuture.com');
  static String get demoPassword =>
      const String.fromEnvironment('DEMO_PASSWORD',
          defaultValue: 'SecureDemo2024!');
  static const String useDemo = 'Try Demo';

  // Screen size optimization messages
  static const String layoutOptimized = 'Layout optimized for your device';
  static const String responseDesign = 'Responsive design active';
}

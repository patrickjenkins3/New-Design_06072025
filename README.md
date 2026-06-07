# CollabFuture — New Design (06/07/2025)

> **Your Family's Future Planned Together**

A collaborative educational planning platform for students, families, and counselors — redesigned with a clean black, white & teal design system.

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary Black | `#0A0A0A` |
| Teal (accent) | `#00BFA5` |
| Surface White | `#FFFFFF` |
| Grey 500 | `#757575` |
| Error Red | `#E53935` |

Typography: **Inter** via Google Fonts  
Icons: Material Icons  
Responsive layout: `sizer` package

---

## 📱 Screens

| Screen | Description |
|---|---|
| Splash | Logo animation with auth routing |
| Login | Parent/Teen toggle, social login, forgot password |
| Sign Up | 3-step progressive registration |
| OTP | Email verification code entry |
| Tutorial | 5-step interactive onboarding |
| Dashboard | Stats, deadlines, scholarships, school comparison |
| School Search | Live search, sort, filter bottom sheet |
| School Detail | Overview / Admissions / Programs / Campus / Visit / Costs / Notes tabs |
| Scholarship Feed | Filter by award, deadline, field, documents, criteria |
| Calendar | Monthly view with events and deadlines |
| AI Support | Chat with quick-action chips |
| Profile Settings | Educational profile, notifications, security, sign out |
| Security | Password change, biometrics, active sessions |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.6.0
- Dart SDK ≥ 3.6.0
- Android Studio / Xcode

### Setup

```bash
git clone https://github.com/patrickjenkins3/New-Design_06072025.git
cd New-Design_06072025
flutter pub get
```

### Environment Variables

Copy `env.json.example` to `env.json` and fill in your keys:

```bash
cp env.json.example env.json
```

Then run with dart-define:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=OPENAI_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key
```

### Run

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 🏗 Architecture

```
lib/
├── core/
│   ├── constants/      # App strings
│   ├── theme/          # Theme notifier
│   └── utils/          # Validators, formatters
├── models/             # Data models
├── presentation/       # Screens (feature-first)
│   ├── screen_name/
│   │   ├── screen_name.dart
│   │   └── widgets/
├── routes/             # AppRoutes
├── services/           # Auth, AI, Calendar, etc.
├── theme/              # AppTheme (light + dark)
└── widgets/            # Shared widgets (CFBottomNav, etc.)
```

---

## 🔒 Security Notes

- All API keys loaded via `--dart-define` (never hardcoded)
- `env.json` is in `.gitignore`
- PIN stored as SHA-256 hash with user-specific salt
- Progressive lockout: 3 attempts → 5 min, 5 → 30 min, 7+ → 2 hrs
- Error messages sanitized before logging

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Auth + database |
| `flutter_stripe` | Payments |
| `dio` | HTTP client |
| `google_fonts` | Inter typography |
| `sizer` | Responsive layout |
| `table_calendar` | Calendar widget |
| `fl_chart` | Charts |
| `flutter_secure_storage` | Encrypted local storage |

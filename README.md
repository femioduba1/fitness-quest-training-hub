# Fitness Quest — Training Challenge Hub

**CSC 4360 — Mobile Application Development**  
**Georgia State University**  
**Project 1**

---

## About the App

Fitness Quest is a mobile fitness application built specifically for college students who want to build consistent workout habits while managing a busy academic schedule. The app is fully offline — no cloud, no subscriptions, no ads. Everything runs locally on the device using SQLite and SharedPreferences.

The app guides users through an onboarding flow on first launch to collect their fitness goal, experience level, height, weight and workout frequency. From there, it personalizes everything — quest suggestions, AI trainer recommendations, BMI tracking and workout split advice — all based on the user's individual profile.

---

## Features

### Core Features
- **Onboarding Flow** — 3-page first launch setup collecting name, fitness goal, experience level, height, weight and workout frequency with a live BMI calculator
- **Home Dashboard** — Active quests with swipe-to-delete and tap-to-edit, streak counter, weekly stats and pull-to-refresh
- **Exercise Library** — 60+ exercises across 6 muscle groups with color-coded muscle group filters, difficulty filters and search
- **Create Quest** — AI-personalized quest suggestions based on onboarding profile, Bro Split and Push Pull Legs templates, custom quest builder with exercise selection and sets/reps counters
- **Log Workouts** — Log sets, reps, weight and notes from the exercise library with automatic personal record detection
- **Progress Screen** — Streak, total workouts, weekly activity grid, BMI card with animated progress bar, weight trend chart, biweekly split suggestions, personal records, workout history
- **Progress Photos** — Camera and gallery support with chronological monthly timeline, full-screen pinch-to-zoom viewer
- **AI Trainer** — Rule-based recommendations for muscle recovery, overwork warnings, rest days and weekly goal nudges
- **Charts & ML Analysis** — Animated bar charts, line charts, consistency ring, muscle balance pie chart and linear regression volume trends
- **BMI Tracking** — Log weight weekly, live BMI calculation, goal-based target ranges, animated trend direction (Improving / On Track / Off Track)
- **Settings** — Username, animated dark/light theme toggle, weight unit, notification preferences, reset onboarding

### Bonus Features Implemented
- Dark/Light animated theme switching **(+3 pts)**
- Advanced search with muscle group and difficulty filters **(+3 pts)**
- Data visualization with fl_chart animated charts **(+4 pts)**

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| SQLite (sqflite) | Local database — 6 tables |
| SharedPreferences | Lightweight key-value storage |
| fl_chart | Animated charts and data visualization |
| flutter_local_notifications | Daily motivational quotes + Sunday weight reminders |
| image_picker | Camera and gallery access for progress photos |
| timezone | Scheduled notification timezone support |
| path | File path utilities for SQLite |

---

## Database Schema

The app uses 6 SQLite tables:
```
quests              — workout challenges (name, duration, weekly goal, active status)
exercises           — exercise library (name, muscle group, equipment, difficulty)
workout_logs        — completed sessions (sets, reps, weight, notes, timestamp)
personal_records    — best performance per exercise (value, type, timestamp)
progress_photos     — photo file paths and captions (path, caption, timestamp)
body_measurements   — weekly weight and BMI logs (weight_kg, height_cm, bmi, notes)
```

---

## Architecture
```
lib/
├── main.dart                        # App entry, navigation, theme, onboarding check
├── database/
│   ├── schema.dart                  # All table CREATE statements
│   ├── database_helper.dart         # SQLite singleton, versioning, exercise seeding
│   └── crud/
│       ├── quest_crud.dart          # Quest CRUD operations
│       ├── exercise_crud.dart       # Exercise CRUD + search + filter
│       ├── workout_log_crud.dart    # Log CRUD + weekly stats + history
│       ├── personal_record_crud.dart # PR CRUD + best record lookup
│       ├── progress_photo_crud.dart # Photo CRUD + monthly grouping
│       └── body_measurement_crud.dart # Measurement CRUD + monthly trend
├── screens/
│   ├── home_screen.dart             # Dashboard with active quests
│   ├── exercise_library_screen.dart # 60+ exercises with filters
│   ├── create_quest_screen.dart     # AI suggestions + templates + custom
│   ├── progress_screen.dart         # Stats, BMI, chart, history, photos
│   ├── progress_photos_screen.dart  # Camera/gallery photo timeline
│   ├── log_workout_sheet.dart       # Bottom sheet workout logger
│   ├── log_weight_screen.dart       # Weight slider with live BMI
│   ├── edit_quest_screen.dart       # Pre-filled quest editor
│   ├── ai_trainer_screen.dart       # Rule-based recommendations
│   ├── charts_screen.dart           # Tabbed charts and ML analysis
│   ├── settings_screen.dart         # App preferences
│   └── onboarding_screen.dart       # First launch 3-page setup
├── services/
│   ├── preferences_service.dart     # SharedPreferences wrapper
│   ├── streak_service.dart          # Daily streak calculation
│   ├── ai_trainer_service.dart      # Rule-based AI recommendations
│   ├── quest_suggestion_service.dart # Personalized quest suggestions
│   ├── bmi_service.dart             # BMI calculation + goal tracking
│   ├── ml_analysis_service.dart     # Linear regression + trend analysis
│   └── notification_service.dart   # Scheduled local notifications
├── theme/
│   └── app_theme.dart               # Dark/light theme, colors, typography
└── widgets/
    ├── slide_menu.dart              # Full-screen burger menu with animations
    ├── theme_toggle.dart            # Animated sun/moon theme switcher
    └── app_bar_burger.dart          # Reusable burger button
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK 3.x or later ([install guide](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter plugin
- Android device or emulator (Android 5.0+ / API 21+)
- iOS device or simulator (iOS 12+)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/femioduba1/fitness-quest-training-hub
cd fitness-quest-training-hub
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Run the app**
```bash
flutter run
```

The SQLite database is created automatically on first launch and seeded with 60 exercises across 6 muscle groups. The onboarding flow runs automatically on first launch.

**4. Build a release APK (optional)**
```bash
flutter build apk --release
```
APK is saved to `build/app/outputs/flutter-apk/app-release.apk`

---

## User Guide

### First Launch — Onboarding
When you open the app for the first time you will see a 3-page onboarding flow. Page 1 asks for your name. Page 2 asks for your fitness goal (Build Muscle, Lose Weight, Get Fit, Endurance, Stay Active, Get Stronger) and experience level (Beginner, Intermediate, Advanced). Page 3 asks for your height, weight and preferred workout frequency. As you adjust height and weight sliders, your BMI is calculated live with a color-coded scale. Tap Get Started to enter the app.

### Navigating the App
Tap the hamburger menu icon (≡) on any screen to open the full-screen slide menu. The menu contains 7 destinations: Home, Library, Create Quest, Progress, AI Trainer, Settings and Progress Photos.

### Creating a Quest
Open the burger menu and tap Create Quest. At the top you will see AI Quest Suggestions — these are personalized based on your onboarding answers. Tap USE on any suggestion to auto-fill the entire form. Alternatively scroll down to choose a template (Bro Split or Push Pull Legs) or build a custom quest from scratch. Set your quest name, description, duration and weekly goal. Tap ADD under Exercises to pick exercises from the library and set sets and reps for each. Tap CREATE QUEST to save.

### Logging a Workout
Go to Library from the burger menu. Use the muscle group chips and difficulty chips to filter exercises, or search by name. Tap any exercise card to open the log sheet. Enter your sets, reps, optional weight and notes. Tap Log Workout. If you hit a personal record the app will detect it automatically.

### Editing or Deleting a Quest
On the Home screen, tap any quest card to open the Edit Quest screen. Swipe left on a quest card to reveal the red delete button. A confirmation dialog will appear before deleting.

### Tracking BMI and Weight
On the Progress screen, the BMI card shows your current BMI, category and whether you are moving toward or away from your goal. Tap LOG TODAY'S WEIGHT or go to Log Weight via the progress screen to record a new measurement. The weight trend chart below shows your last 30 days of measurements. Every Sunday at 9am you will receive a notification reminding you to log your weight.

### Viewing Charts and ML Analysis
Tap the orange CHARTS & ML ANALYSIS banner on the Progress screen or tap the analytics icon in the app bar. The Charts screen has 3 tabs — Today (consistency ring, muscle balance pie), Weekly (bar chart, volume trend) and Monthly (line chart with gradient, monthly summary).

### Using the AI Trainer
Open the burger menu and tap AI Trainer. The screen shows your daily motivational quote, a toggle for workout reminders and a list of personalized recommendations. Recommendations are generated by 4 rules: muscle recovery timing, overwork detection, rest day suggestion and weekly goal progress. Toggle Daily Motivation on to receive 4 quotes per day at 8am, 12pm, 5pm and 8pm.

### Adding Progress Photos
Open the burger menu and tap Progress Photos. Tap the camera icon or the floating button to add a photo. Choose Take Photo for the camera or Choose from Gallery to pick an existing photo. Add an optional caption and tap Save. Photos are grouped by month in a chronological timeline. Tap any photo to view it full screen with pinch-to-zoom. Tap the trash icon to delete.

### Changing Theme
Open Settings from the burger menu. Under Appearance, toggle the sun/moon switch. The theme changes after the animation completes. Your preference is saved automatically.

---

## AI Components

### AI Trainer (Rule-Based)

The AI Trainer uses rule-based logic — no external API, no internet required:

| Rule | Logic |
|---|---|
| Muscle Recovery | Recommends the least-recently-trained muscle group based on per-muscle recovery day thresholds |
| Overwork Detection | Warns if any muscle group has been trained 3+ times in the last 2 days |
| Rest Day | Recommends full rest after a 6-day streak, active recovery after a 4-day streak |
| Weekly Goal Nudge | Alerts if user is behind pace to hit their quest's weekly workout target |

### AI Quest Suggestions

Quest suggestions are generated from the user's onboarding profile. The service combines goal-based suggestions, experience-level suggestions, frequency-based suggestions and two college-specific suggestions (Dorm Room Warrior and Finals Week Survival) and returns up to 6 personalized options. Each suggestion includes an explanation of why it was recommended.

### ML Analysis

The Charts screen uses linear regression computed entirely on-device to detect volume and strength trends over time. It also calculates a consistency score and muscle balance distribution from logged workout data.

### BMI Progress Tracking

The BMI service compares the user's current BMI against a goal-based target range (e.g. 22–27 for muscle building, 18.5–24.9 for weight loss). It analyzes the trend over the past 30 days and classifies progress as Improving, On Track, Moving Away or Neutral. Every 2 weeks it generates a workout split adjustment suggestion based on the BMI trend.

---

## Notifications

| Notification | Schedule |
|---|---|
| Motivational Quote | Daily at 8am, 12pm, 5pm and 8pm |
| Weekly Weigh-In Reminder | Every Sunday at 9am |

Notifications require permission on Android 13+ and iOS. Permission is requested on first launch.

---

## Known Limitations

- Progress photos are stored as file paths — if the device moves or deletes the original file the photo will show a broken image placeholder
- Landscape mode has not been formally tested — some screens may show overflow on certain devices
- The AI recommendations are rule-based and do not adapt using machine learning — they use fixed thresholds based on workout history
- No data export functionality in current version

---

## Version History

| Version | Commit | Description |
|---|---|---|
| 1.0 | `0ec02dd` | Initial exercise library screen with comments for presentation |
| 1.1 | `9582831` | Home screen with comments for presentation clarity |
| 1.2 | `dc18ced` | Progress screen with comments for demo explanation |
| 1.3 | `a151862` | Main navigation and app structure comments for demo |
| 1.4 | `6fe01ae` | SQLite schema, database helper and full CRUD operations |
| 1.5 | `d04bb0f` | Merged main into feature/sqlite-database branch |
| 1.6 | `b5e2e11` | SharedPreferences service and daily streak tracking logic |
| 1.7 | `24809dc` | Connected all screens to SQLite database and services |
| 1.8 | `d82e510` | Log workout feature, workout history and progress screen updates |
| 1.9 | `456c12b` | Premium UI redesign across all screens, animated theme toggle, readability fixes |
| 2.0 | `fae91a2` | AI Trainer with rule-based recommendations and motivational notifications |
| 2.1 | `737e7d9` | Fixed refresh animation, notifications, burger menu and pull-to-refresh on all screens |
| 2.2 | `d439a01` | Code comments across all files and initial README |
| 2.3 | `5d32cd4` | Merged PR #3 — feature/sqlite-database into main |
| 2.4 | `2a25ffe` | 60 exercises across 6 muscle groups, muscle group filters, Bro Split and PPL templates, edit quest, swipe to delete, progress photos screen |
| 2.5 | `02f5457` | AI quest suggestions personalized from onboarding profile |
| 3.0 | `604bda5` | BMI tracking, onboarding height and weight measurements, weight trend chart, biweekly split suggestions |

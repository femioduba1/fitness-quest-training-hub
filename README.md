<div align="center">

<img src="https://img.shields.io/badge/⚡-FITNESS_QUEST-FF6000?style=for-the-badge&labelColor=0D0D0D&color=FF6000" height="60"/>

# FITNESS QUEST
### Training Challenge Hub

**A fully offline, AI-personalized fitness app built for college students**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-6_Tables-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://www.sqlite.org)
[![Platform](https://img.shields.io/badge/Platform-Android_|_iOS-FF6000?style=for-the-badge&logo=android&logoColor=white)](https://github.com/femioduba1/fitness-quest-training-hub)
[![License](https://img.shields.io/badge/License-Academic-1C1C1C?style=for-the-badge)](https://github.com/femioduba1/fitness-quest-training-hub)

<br/>

[![Version](https://img.shields.io/badge/Version-4.0-FF6000?style=flat-square&labelColor=1C1C1C)](https://github.com/femioduba1/fitness-quest-training-hub/releases)
[![Commits](https://img.shields.io/badge/Commits-26+-4CAF50?style=flat-square&labelColor=1C1C1C)](https://github.com/femioduba1/fitness-quest-training-hub/commits)
[![Screens](https://img.shields.io/badge/Screens-8-2196F3?style=flat-square&labelColor=1C1C1C)](https://github.com/femioduba1/fitness-quest-training-hub)
[![Exercises](https://img.shields.io/badge/Exercises-60+-9C27B0?style=flat-square&labelColor=1C1C1C)](https://github.com/femioduba1/fitness-quest-training-hub)
[![Bonus](https://img.shields.io/badge/Bonus_Points-+10-FFC107?style=flat-square&labelColor=1C1C1C)](https://github.com/femioduba1/fitness-quest-training-hub)

</div>

---

<div align="center">

```
CSC 4360 — Mobile Application Development  |  Georgia State University  |  Spring 2026
Olufemi Oduba ·  Adrit Ganeriwala
```

</div>

---

## ⚡ About

Fitness Quest is a cross-platform mobile fitness application built with Flutter for Android and iOS. Designed specifically for college students who want to build consistent workout habits while managing a busy academic schedule.

> **100% offline.** No internet. No cloud. No subscriptions. Everything runs locally on the device using SQLite and SharedPreferences.

The app guides users through a personalized 3-page onboarding flow collecting their fitness goal, experience level, height, weight and preferred workout frequency. Every feature — quest suggestions, AI trainer recommendations, BMI tracking and biweekly split advice — is driven by this profile.

---

## 🚀 Features

<table>
<tr>
<td width="50%">

**📱 Core Experience**
- 👋 **3-Page Onboarding** — name, goal, level, height/weight with live BMI calculator
- 🏠 **Home Dashboard** — streak counter, weekly stats, active quests
- 💪 **Exercise Library** — 60+ exercises, muscle group + difficulty filters
- ⚡ **Create Quest** — AI suggestions, Bro Split & PPL templates
- 📊 **Progress Screen** — BMI card, weight trend chart, personal records

</td>
<td width="50%">

**🤖 Intelligence & Analytics**
- 🤖 **AI Trainer** — 4 rule-based recommendations, zero API calls
- 📈 **Charts & ML** — linear regression, muscle balance, consistency ring
- ⚖️ **BMI Tracking** — weekly weight logs, goal-based trend direction
- 📸 **Progress Photos** — camera/gallery, monthly timeline
- 🔔 **Notifications** — daily quotes + Sunday weight reminders

</td>
</tr>
</table>

### 🏆 Bonus Features
| Feature | Points | Status |
|---|---|---|
| Dark / Light animated theme toggle | +3 | ✅ Implemented |
| Advanced search with muscle group + difficulty filters | +3 | ✅ Implemented |
| Data visualization with fl_chart animated charts | +4 | ✅ Implemented |
| **Total Bonus** | **+10** | |

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | 3.x stable | Cross-platform UI framework |
| **Dart** | 3.x | Programming language |
| **sqflite** | ^2.3.0 | SQLite local database |
| **shared_preferences** | ^2.2.2 | Key-value settings storage |
| **fl_chart** | ^0.68.0 | Animated charts & data visualization |
| **flutter_local_notifications** | ^17.0.0 | Scheduled push notifications |
| **image_picker** | ^1.0.7 | Camera and gallery access |
| **timezone** | ^0.9.2 | Timezone-aware notification scheduling |
| **path** | ^1.8.3 | File path utilities |

---

## 🗄️ Database Schema

6 SQLite tables with full CRUD operations across all screens.

```
┌─────────────────────────────────────────────────────────────────┐
│                    FITNESS QUEST DATABASE                        │
│                        version 3                                 │
├──────────────────┬──────────────────┬──────────────────────────┤
│     quests       │    exercises     │      workout_logs         │
│  ─────────────  │  ─────────────  │  ──────────────────────  │
│  id (PK)         │  id (PK)         │  id (PK)                  │
│  name            │  name            │  quest_id (FK)            │
│  description     │  muscle_group    │  exercise_id (FK)         │
│  duration_weeks  │  equipment       │  sets, reps, weight       │
│  weekly_goal     │  difficulty      │  logged_at, notes         │
│  start_date      │  description     │                           │
│  is_active       │                  │                           │
├──────────────────┼──────────────────┼──────────────────────────┤
│ personal_records │ progress_photos  │   body_measurements       │
│  ─────────────  │  ─────────────  │  ──────────────────────  │
│  id (PK)         │  id (PK)         │  id (PK)                  │
│  exercise_id (FK)│  photo_path      │  weight_kg                │
│  record_value    │  caption         │  height_cm                │
│  record_type     │  taken_at        │  bmi                      │
│  achieved_at     │                  │  logged_at, notes         │
└──────────────────┴──────────────────┴──────────────────────────┘
```

> Database uses version 3 with `onUpgrade` handler — existing users get new tables without losing workout data.

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry, navigation, theme, onboarding gate
│
├── database/
│   ├── schema.dart                  # All CREATE TABLE statements
│   ├── database_helper.dart         # SQLite singleton + seeding + versioning
│   └── crud/
│       ├── quest_crud.dart          # Quest CRUD operations
│       ├── exercise_crud.dart       # Exercise CRUD + search + filter
│       ├── workout_log_crud.dart    # Log CRUD + weekly stats + history
│       ├── personal_record_crud.dart# PR CRUD + best record lookup
│       ├── progress_photo_crud.dart # Photo CRUD + monthly grouping
│       └── body_measurement_crud.dart # Measurement CRUD + trend data
│
├── screens/
│   ├── onboarding_screen.dart       # 3-page first launch setup
│   ├── home_screen.dart             # Dashboard with active quests
│   ├── exercise_library_screen.dart # 60+ exercises with filters
│   ├── create_quest_screen.dart     # AI suggestions + templates + form
│   ├── progress_screen.dart         # Stats, BMI, charts, history
│   ├── progress_photos_screen.dart  # Camera/gallery photo timeline
│   ├── log_workout_sheet.dart       # Bottom sheet workout logger
│   ├── log_weight_screen.dart       # Weight slider with live BMI
│   ├── edit_quest_screen.dart       # Pre-filled quest editor
│   ├── ai_trainer_screen.dart       # Rule-based recommendations
│   ├── charts_screen.dart           # Tabbed charts and ML analysis
│   └── settings_screen.dart         # App preferences + theme toggle
│
├── services/
│   ├── preferences_service.dart     # SharedPreferences wrapper (10 keys)
│   ├── streak_service.dart          # Daily streak calculation
│   ├── ai_trainer_service.dart      # 4 rule-based AI recommendations
│   ├── quest_suggestion_service.dart# Personalized quest suggestions
│   ├── bmi_service.dart             # BMI calc + goal tracking + split suggestions
│   ├── ml_analysis_service.dart     # Linear regression + trend analysis
│   └── notification_service.dart   # Scheduled local notifications
│
├── theme/
│   └── app_theme.dart               # Dark/light theme, color system, typography
│
└── widgets/
    ├── slide_menu.dart              # Full-screen burger menu with animations
    ├── theme_toggle.dart            # Animated sun/moon theme switcher
    └── app_bar_burger.dart          # Reusable burger button
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK 3.x or later → [Install Guide](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter plugin
- Android device/emulator (API 21+ / Android 5.0+) or iOS device/simulator (iOS 12+)

### Run from Source

```bash
# 1. Clone the repository
git clone https://github.com/femioduba1/fitness-quest-training-hub
cd fitness-quest-training-hub

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> The SQLite database is created automatically on first launch and seeded with 60 exercises. The onboarding flow runs on first launch only.

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📖 User Guide

<details>
<summary><b>👋 First Launch — Onboarding</b></summary>

When you open the app for the first time a 3-page onboarding flow runs automatically.

- **Page 1** — Enter your name. The Continue button stays disabled until a name is typed.
- **Page 2** — Select your fitness goal from 6 options and your experience level from 3 options.
- **Page 3** — Set your height and weight using sliders. Your BMI is calculated live as you move the sliders. Set your preferred workout frequency (1-7 days/week).

Tap **GET STARTED** to enter the app. All data is saved to SharedPreferences and your first BMI measurement is logged to SQLite.

To test onboarding again: go to **Settings → Reset Onboarding** then restart the app.

</details>

<details>
<summary><b>🏠 Navigating the App</b></summary>

Tap the **≡ burger menu icon** on any screen to open the full-screen slide menu. The menu has 7 destinations: Home, Library, Create Quest, Progress, AI Trainer, Settings and Progress Photos. Swipe or tap outside to close.

</details>

<details>
<summary><b>⚡ Creating a Quest</b></summary>

1. Open the burger menu → **Create Quest**
2. At the top, **AI Quest Suggestions** are personalized to your onboarding profile — tap **USE** to auto-fill the entire form
3. Or pick a template: **Bro Split** (5x/week, one muscle group per day) or **Push Pull Legs** (6x/week)
4. Set quest name, description, duration and weekly goal
5. Tap **ADD** under Exercises to pick from the library and set sets/reps per exercise
6. Tap **CREATE QUEST**

</details>

<details>
<summary><b>💪 Logging a Workout</b></summary>

1. Go to **Library** from the burger menu
2. Filter by muscle group or difficulty, or search by name
3. Tap any exercise card to open the log sheet
4. Enter sets, reps, optional weight and notes
5. Tap **Log Workout**

Personal records are detected automatically. If you beat a previous best weight, a 🏆 trophy notification appears.

</details>

<details>
<summary><b>📊 Tracking Progress & BMI</b></summary>

The Progress screen shows:
- **BMI card** — current BMI, category and whether you're moving toward or away from your goal
- **Log Weight button** — tap to record a new weight measurement
- **Weight trend chart** — last 30 days of measurements
- **Biweekly split suggestion** — AI-generated program adjustment based on your BMI trend
- **Personal records**, **workout history** and **weekly activity grid**

Every Sunday at 9am you'll receive a notification reminding you to log your weight.

</details>

<details>
<summary><b>🤖 AI Trainer</b></summary>

The AI Trainer uses 4 rule-based checks — no external API:

| Rule | Logic |
|---|---|
| Muscle Recovery | Recommends least-recently-trained recovered muscle group |
| Overwork Detection | Warns if any muscle trained 3+ times in 2 days |
| Rest Day | Full rest after 6-day streak, active recovery after 4-day streak |
| Weekly Goal Nudge | Alerts if behind pace on quest's weekly target |

Toggle **Daily Motivation** on for 4 motivational quotes per day (8am, 12pm, 5pm, 8pm).

</details>

---

## 🤖 AI & Intelligence

All AI features are rule-based and run completely on-device. Zero external API calls.

### AI Trainer — 4 Rules

```
Rule 1: Muscle Recovery
  → Track last training date per muscle group
  → Recovery thresholds: Core/Arms=1d, Chest/Back/Shoulders=2d, Legs=3d
  → Suggest least-recently-trained recovered muscle

Rule 2: Overwork Detection  
  → Count training sessions per muscle in last 2 days
  → 3+ sessions = Priority 5 warning (highest urgency)

Rule 3: Rest Day
  → Streak ≥ 6 days → Full rest recommended
  → Streak ≥ 4 days → Active recovery suggested

Rule 4: Weekly Goal Nudge
  → Compare logged workouts vs quest.weekly_goal
  → Behind pace = warning | Goal met = celebration
```

### BMI Progress Tracking

```
bmi = weight_kg / (height_m × height_m)

Goal-based target ranges:
  build_muscle  →  22.0 – 27.0
  lose_weight   →  18.5 – 24.9
  strength      →  23.0 – 28.0
  endurance     →  18.5 – 23.0
  get_fit       →  18.5 – 24.9

Direction: compare first vs latest measurement distance from target range
  closer = Improving 📈 | in range = On Track 🎯 | further = Off Track ⚠️
```

### ML Analysis

Linear regression computed on-device using the standard slope formula across workout volume data points. No external ML framework required.

---

## 🔔 Notifications

| Notification | Schedule |
|---|---|
| 💬 Motivational Quote | Daily at 8am, 12pm, 5pm and 8pm |
| ⚖️ Weekly Weigh-In Reminder | Every Sunday at 9am |

Requires permission on Android 13+ and iOS. Permission requested on first launch.

---

## 📋 Version History

| Version | Commit | Description |
|---|---|---|
| 1.0 | `0ec02dd` | Initial screens with comments for presentation |
| 1.3 | `a151862` | Main navigation and app structure |
| 1.4 | `6fe01ae` | SQLite schema, database helper, full CRUD |
| 1.6 | `b5e2e11` | SharedPreferences + daily streak tracking |
| 1.7 | `24809dc` | All screens connected to SQLite |
| 1.8 | `d82e510` | Workout logging, history, progress updates |
| 1.9 | `456c12b` | Premium UI redesign, animated theme toggle |
| 2.0 | `fae91a2` | AI Trainer + motivational notifications |
| 2.1 | `737e7d9` | Fixed refresh animation + pull-to-refresh |
| 2.2 | `d439a01` | Code comments + initial README |
| 2.3 | `5d32cd4` | **Merged PR #3** — feature branch → main |
| 2.4 | `2a25ffe` | 60 exercises, filters, templates, edit quest, photos |
| 2.5 | `02f5457` | AI quest suggestions from onboarding profile |
| 4.0 | `604bda5` | BMI tracking, weight trend, split suggestions, APK |

---

## 👥 Team

<table>
<tr>
<td align="center" width="50%">

### Olufemi Oduba
**UI Design & Frontend**

- All screen layouts and wireframes
- Navigation structure and burger menu
- Orangetheory dark/light theme design
- Custom widget implementations
- App visual consistency and polish

</td>
<td align="center" width="50%">

### Adrit Ganeriwala
**Database, Backend & AI**


- SQLite schema (6 tables) and CRUD layer
- All 6 service classes
- AI Trainer rule engine
- BMI tracking and goal progress system
- Charts, ML analysis and notifications

</td>
</tr>
</table>

---

## 📄 Submission Documents

| Document | Description |
|---|---|
| `README.md` | This file — full project documentation |
| `AI_Usage_Log.md` | 10 logged AI-assisted development sessions |
| `Selected_Presentation_Questions_Form.md` | 15 selected Q&A questions with evidence |
| `FitnessQuest_Technical_Reference.docx` | Comprehensive technical deep-dive document |

---

<div align="center">

**CSC 4360 — Mobile Application Development**
**Georgia State University — Spring 2026**

[![GitHub](https://img.shields.io/badge/GitHub-fitness--quest--training--hub-FF6000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/femioduba1/fitness-quest-training-hub)

*Built offline. Built smart. Built for college students.* 💪

</div>

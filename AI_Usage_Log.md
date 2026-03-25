# AI Usage Log — Fitness Quest

**Course:** CSC 4360 — Mobile Application Development  
**Team:** Olufemi Oduba & Adrit Ganeriwala  
**Project:** Fitness Quest — Training Challenge Hub  

> AI tools were used as an assistant for brainstorming, debugging and learning.
> All implementation decisions, architecture choices and code understanding
> remain the responsibility of the team members.

---

## Log Entries

---

### Entry 1
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help designing a SQLite database schema for a fitness tracking app with quests, exercises, workout logs, personal records, progress photos and body measurements.
- **Output Used:** The 6-table schema structure (`quests`, `exercises`, `workout_logs`, `personal_records`, `progress_photos`, `body_measurements`) was used as a starting point. We reviewed each table, adjusted column names and data types to match our specific feature requirements, and added the `is_active` flag to quests and the `created_at` timestamps ourselves.
- **Learning Reflection:** This helped us understand how to structure relational data in SQLite with foreign keys. We learned about the importance of separating the exercise library (static data) from workout logs (user-generated data) into different tables rather than storing exercise names as strings in logs.

---

### Entry 2
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help debugging a Flutter merge conflict in `main.dart` and `pubspec.lock` after attempting to merge `feature/sqlite-database` into `main`.
- **Output Used:** The `git rebase` and `git checkout --theirs` commands to resolve conflicts. We chose which version to keep (the feature branch) based on our own understanding of which code was more complete.
- **Learning Reflection:** We learned the difference between `git merge` and `git rebase` and when to use each. We also learned that `pubspec.lock` conflicts are usually safe to resolve by keeping the feature branch version since it has the most up-to-date dependency resolution.

---

### Entry 3
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help understanding why the RefreshIndicator animation was glitching on the Home screen when pull-to-refresh was triggered.
- **Output Used:** The insight that `setState()` should only be called at the END of the async data fetch, not at the beginning. We applied this fix ourselves across all 7 screens by reviewing each `_load` method and moving the `setState()` call to after the `Future.wait()` resolved.
- **Learning Reflection:** We deepened our understanding of how Flutter's widget rebuild cycle interacts with async operations. Calling setState too early causes the widget to rebuild with empty/stale data while the fetch is still in progress, which interrupts animations like RefreshIndicator.

---

### Entry 4
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help understanding how to implement an animated theme toggle where the animation plays on the OLD theme before switching to the new one.
- **Output Used:** The pattern of using `await _controller.forward()` before calling `FitnessQuestApp.appKey.currentState?.updateTheme()`. We implemented this in `lib/widgets/theme_toggle.dart` and verified the animation behavior ourselves on the physical device.
- **Learning Reflection:** We learned how Flutter's AnimationController interacts with the widget tree rebuild cycle. Because `forward()` is awaitable, we can delay global state changes until an animation completes. This taught us that UI polish often requires careful sequencing of async operations.

---

### Entry 5
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help structuring a rule-based AI trainer that analyzes workout history without external APIs.
- **Output Used:** The 4-rule structure (muscle recovery, overwork detection, rest day, weekly goal nudge) was used as a framework. We wrote the actual rule logic ourselves in `lib/services/ai_trainer_service.dart`, tuning the thresholds (e.g. 3+ sessions in 2 days = overwork, 6-day streak = rest day) based on our own research into exercise science principles.
- **Learning Reflection:** We learned how to implement explainable AI features using simple rule-based logic without relying on external ML models or APIs. This approach keeps all recommendations fully on-device and transparent to the user, which is important for trust in a health app.

---

### Entry 6
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help implementing BMI calculation, goal-based target ranges and a progress direction indicator that shows whether the user is moving toward or away from their fitness goal.
- **Output Used:** The BMI formula (`weight / (height_m * height_m)`) and the concept of goal-based target ranges (e.g. 22–27 for muscle building, 18.5–24.9 for weight loss). We implemented the full `BMIService` class ourselves in `lib/services/bmi_service.dart`, including the distance-from-range comparison logic and the `ProgressDirection` enum.
- **Learning Reflection:** We learned how to translate fitness science concepts (healthy BMI ranges vary by goal) into code logic. We also learned how to use Flutter's `TweenAnimationBuilder` to animate a progress bar smoothly from 0 to the target value when the Progress screen loads.

---

### Entry 7
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help understanding how `flutter_local_notifications` schedules recurring notifications using timezone-aware scheduling.
- **Output Used:** The pattern for scheduling a weekly Sunday notification using `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`. We implemented the Sunday weight reminder ourselves in `lib/services/notification_service.dart` and tested it on the physical device.
- **Learning Reflection:** We learned about the difference between absolute and relative notification scheduling in Flutter. The `timezone` package is required for accurate scheduling across daylight saving time changes. We also learned about the Android 13+ `POST_NOTIFICATIONS` permission requirement and how to request it at runtime.

---

### Entry 8
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help designing the onboarding flow — specifically how to show a live BMI calculator that updates as the user moves height and weight sliders.
- **Output Used:** The `StatefulWidget` pattern with `setState()` on slider `onChanged` to trigger real-time BMI recalculation. We designed the 3-page onboarding structure ourselves and wrote the BMI scale bar visualization in `lib/screens/onboarding_screen.dart` independently.
- **Learning Reflection:** We learned how to create engaging, interactive onboarding experiences in Flutter. The key insight was that real-time feedback (showing BMI change as the slider moves) makes the data collection feel like a feature rather than a form to fill out.

---

### Entry 9
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for debugging help when encountering a Dart generic type syntax error in `progress_screen.dart` involving `TweenAnimationBuilder<double>` and `AlwaysStoppedAnimation<Color>`.
- **Output Used:** The fix of changing `TweenAnimationBuilder<double>(...)` to `TweenAnimationBuilder(tween: Tween<double>(...), builder: (context, double value, child) {...})`. We applied the fix and verified it compiled and ran correctly.
- **Learning Reflection:** We learned about Dart's type inference rules and when explicit generic type parameters are required vs inferred. The builder pattern for `TweenAnimationBuilder` requires the type to be declared on the `Tween` object, not on the widget itself.

---

### Entry 10
- **Date:** March 2026
- **Tool:** Claude (Anthropic)
- **Prompt Summary:** Asked for help preparing Q&A answers, the Selected Presentation Questions Form and the demo video script for the project presentation.
- **Output Used:** The Q&A answer drafts were used as a starting point. Both team members reviewed every answer, verified each claim against our actual codebase, corrected any inaccuracies and added specific file names, commit hashes and implementation details that only we could know from working on the project.
- **Learning Reflection:** Preparing for the Q&A helped us reflect on our own implementation decisions more deeply. Articulating WHY we made certain choices (setState vs Provider, burger menu vs bottom nav, rule-based AI vs external API) solidified our understanding of the trade-offs involved in each decision.

---

## Summary

| # | Date | Tool | Purpose | Output Used |
|---|---|---|---|---|
| 1 | March 2026 | Claude | Database schema design | 6-table structure as starting point |
| 2 | March 2026 | Claude | Git merge conflict debugging | Rebase commands to resolve conflicts |
| 3 | March 2026 | Claude | RefreshIndicator animation bug | setState timing fix pattern |
| 4 | March 2026 | Claude | Animated theme toggle sequencing | Await animation before state change pattern |
| 5 | March 2026 | Claude | Rule-based AI trainer structure | 4-rule framework as starting point |
| 6 | March 2026 | Claude | BMI calculation and goal tracking | Formula and target range concept |
| 7 | March 2026 | Claude | Local notifications scheduling | Weekly Sunday reminder pattern |
| 8 | March 2026 | Claude | Onboarding live BMI calculator | Real-time slider setState pattern |
| 9 | March 2026 | Claude | Dart generic type syntax error | TweenAnimationBuilder type fix |
| 10 | March 2026 | Claude | Presentation preparation | Q&A drafts reviewed and verified |

---

## Declaration

All code in this repository was written, reviewed and understood by the team members listed above. AI tools were used strictly as learning and debugging assistants. No AI-generated code was submitted without being fully reviewed, tested, modified and understood by the responsible team member. We are prepared to explain any part of the codebase during the live Q&A session.

**Olufemi Oduba** 
**Adrit Ganeriwala 

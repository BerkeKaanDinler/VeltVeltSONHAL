# VELT — Flutter Developer Handoff

## What this is
A complete UI design system for **VELT**, a premium offline-first fitness tracker. The HTML files in this bundle are **high-fidelity React design references** — your task is to recreate these screens in **Flutter** using the design tokens, widgets, and patterns documented below.

Aesthetic: Apple Fitness+ × premium gym. Dark only. Amber accent. No social feed, no fluff, no motivational quotes. Built for serious lifters.

---

## Screens covered (10 total)

| # | Screen | File |
|---|---|---|
| 1 | Onboarding (4 swipeable pages) | `velt/onboarding.jsx` |
| 2 | Home (greeting + today + stats + 7-day + last session + PRs) | `velt/home.jsx` |
| 3 | Train (routines + programs + program detail) | `velt/train.jsx` |
| 4 | Active Workout (timer + rest ring + exercise list + add sheet) | `velt/workout.jsx` |
| 5 | Workout Complete (animated check + stats + new PRs) | `velt/complete.jsx` |
| 6 | Nutrition (calorie ring + macros + log + week chart + add sheet) | `velt/nutrition.jsx` |
| 7 | Progress (KPI strip + volume chart + bodyweight + PRs + Pro lock) | `velt/progress.jsx` |
| 8 | Settings / Profile (training + goals + data + app + theme picker) | `velt/settings.jsx` |
| 9 | Detail screens: Workout Detail / Exercise Detail / PR Detail | `velt/details.jsx` |
| 10 | Theme picker (2 free + 2 pro themes) | `velt/theme-sheet.jsx` |

Open `VELT Fitness App.html` in a browser to see the live, interactive prototype.

---

## Suggested Flutter project structure

```
lib/
├── theme/
│   ├── app_colors.dart       ← 4 ThemeData + AppColors extension
│   ├── app_spacing.dart      ← spacing + radius constants
│   ├── app_typography.dart   ← TextStyle factory methods
│   └── app_theme.dart        ← ThemeData builders
├── widgets/
│   ├── primary_button.dart
│   ├── ghost_button.dart
│   ├── pill.dart
│   ├── filter_chip.dart
│   ├── section_header.dart
│   ├── stat_box.dart
│   ├── bottom_sheet_shell.dart
│   ├── icon_set.dart         ← all custom SVG paths
│   └── set_row.dart
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── welcome_page.dart
│   │   ├── goal_page.dart
│   │   ├── level_page.dart
│   │   └── unit_page.dart
│   ├── home_screen.dart
│   ├── train_screen.dart
│   ├── program_detail_screen.dart
│   ├── active_workout_screen.dart
│   ├── workout_complete_screen.dart
│   ├── nutrition_screen.dart
│   ├── progress_screen.dart
│   ├── settings_screen.dart
│   └── details/
│       ├── workout_detail_screen.dart
│       ├── exercise_detail_screen.dart
│       └── pr_detail_screen.dart
├── sheets/
│   ├── add_exercise_sheet.dart
│   ├── add_food_sheet.dart
│   ├── edit_goals_sheet.dart
│   ├── theme_sheet.dart
│   ├── rest_timer_sheet.dart
│   ├── level_sheet.dart
│   └── goal_sheet.dart
├── state/
│   ├── theme_controller.dart
│   ├── workout_session.dart
│   └── user_profile.dart
└── main.dart
```

---

## Design Tokens

### Colors (Iron Dark — default)
```dart
const surface         = Color(0xFF0F0F0F);  // primary bg
const surfaceElevated = Color(0xFF1A1A1A);  // cards, sheets
const surfaceHigh     = Color(0xFF242424);  // pressed states, secondary surfaces
const divider         = Color(0xFF2A2A2A);

const textPrimary     = Color(0xFFFFFFFF);
const textSecondary   = Color(0xFFA0A0A0);
const textTertiary    = Color(0xFF555555);

const accentIron      = Color(0xFFD97706);  // CTAs, highlights, PRs
const accentIronSoft  = Color(0xFF92400E);
// accent tint: alpha 0.08 of accentIron
// accent border: alpha 0.30 of accentIron

const successLime     = Color(0xFF22C55E);
const errorRose       = Color(0xFFEF4444);
const warningAmber    = Color(0xFFF59E0B);

// Macro chart colors (constant across themes)
const protein         = Color(0xFFD97706);
const carbs           = Color(0xFF38BDF8);
const fat             = Color(0xFF22C55E);
```

### 4 Themes (2 free + 2 pro)

**Iron Dark** (free, default) — Above

**Slate Mono** (free)
```dart
surface:         #0A0E1A   surfaceElevated: #141927
surfaceHigh:     #1E2434   divider:         #252B3D
textPrimary:     #F1F5F9   textSecondary:   #94A3B8
textTertiary:    #475569
accentIron:      #94A3B8   accentIronSoft:  #475569
```

**Rose Gold** (Pro)
```dart
surface:         #100A0E   surfaceElevated: #1B131A
surfaceHigh:     #241B22   divider:         #2D2128
textPrimary:     #FBEEF2   textSecondary:   #B89BA8
textTertiary:    #6B5662
accentIron:      #F472B6   accentIronSoft:  #9D174D
```

**Emerald Premium** (Pro)
```dart
surface:         #0A1410   surfaceElevated: #0F1F18
surfaceHigh:     #162B22   divider:         #1F352A
textPrimary:     #E8F5EE   textSecondary:   #7BAB94
textTertiary:    #3F5D4F
accentIron:      #10B981   accentIronSoft:  #065F46
```

### Spacing (4pt grid)
```dart
xxs: 4   xs: 8   sm: 12   md: 16
lg: 20   xl: 24  xxl: 32  xxxl: 48
screenH: 16            // horizontal screen margin
sectionGap: 22         // gap between major sections
bottomNavPad: 100      // bottom padding above tab bar
```

### Border Radius
```dart
rxs: 4    // small chips
rsm: 8    // buttons, fields
rmd: 12   // cards, list rows ← standard
rlg: 16   // bottom sheets, paywall cards
rxl: 20   // sheet handles
rfull: 999 // pills
```

### Typography
Use **Inter** for everything except numerics, **JetBrains Mono** (or any tabular monospace) for set weight × reps and timers.

```dart
// Display
displayXL: 56pt / 700 / -0.05em    // PR hero number
displayL:  34pt / 700 / -0.04em    // Screen titles
displayM:  28pt / 700 / -0.035em   // Detail titles
displayS:  22pt / 700 / -0.025em   // Stat numbers

// Title
titleL:    18pt / 700 / -0.02em    // Card titles in active workout
titleM:    16pt / 700 / -0.01em    // Routine names
titleS:    15pt / 700 / -0.01em    // Buttons (size=lg)

// Body
bodyL:     14pt / 500 / -0.005em
bodyM:     13pt / 500
bodyS:     12pt / 400              // captions, metadata
bodyXS:    11pt / 500              // tertiary metadata, dates

// Mono
mono:      JetBrains Mono / 500 / tabular  // weight × reps, set numbers

// Caption (uppercase tracking)
sectionHeader: 11pt / 600 / 0.08em letter-spacing / uppercase / textSecondary
proLabel:      10pt / 700 / 0.10em / uppercase / accentIron
```

**CRITICAL:** All numeric Text widgets MUST use `fontFeatures: [FontFeature.tabularFigures()]`.

### Touch Targets
Minimum 44pt always. Specific sizes:
- Primary CTA button: 52pt
- Bottom nav item: 64pt (with label)
- Set row checkmark: 36pt (in a 44pt hit area)
- Filter chip: 32pt
- Stepper +/- buttons: 32×32 (in a 44pt parent)

---

## Components

### PrimaryButton
```dart
height: 52pt
borderRadius: rsm (8pt)
background: accentIron (or surfaceHigh when disabled)
text: white, 14pt, 700 weight
pressed: opacity 0.88 + scale 0.98
disabled: textTertiary text, no shadow
haptic: HapticFeedback.mediumImpact()
```

### GhostButton
```dart
height: 38pt (size=md), 32pt (sm), 44pt (lg)
borderRadius: rsm
border: 1px divider (or errorRose if danger)
background: transparent → surfaceHigh on press
text: textSecondary, 12pt 600
```

### SetRow (most important component — 20-60 per workout)
```
Layout: 5-column grid
[32px set#] [flex prev] [80px weight stepper] [80px reps stepper] [44px check]

States:
- pending  → no background, divider on bottom
- active   → 0.04 successLime tint hint
- done     → opacity 0.85, weight text successLime green
- W (warmup) → orange "W" pill in set# slot
```

### RestTimerBanner
```
height: 64pt
background: alpha(accentIron, 0.12)
border: 1px alpha(accentIron, 0.3) bottom
slides down from top of workout screen
Contains:
  - Circular progress ring (44px), countdown
  - "Rest" / "Until your next set" labels
  - "+15s" chip
  - "Skip" text button
auto-dismisses at 0
```

### BottomNav
```dart
height: 64pt
background: surface
borderTop: 0.5px divider
5 tabs: Home / Train / Food / Progress / Profile
each: icon (24px) + label (9pt, 700 if active)
active color: accentIron
inactive color: textTertiary
```

### BottomSheet
```dart
background: surfaceElevated
borderRadius: 20pt top-only
slides up 280ms cubic-bezier(0.2, 0, 0, 1)
backdrop: black 0.55 alpha, fade 200ms
handle: 36×4 pill, surfaceHigh
title: 16pt 700 + close × button
content: scrollable
maxHeight: 88% (or 92% for 'full' variant)
```

---

## Screen Specs

### 1. Onboarding (4 pages)
- **Page indicator**: 3pt amber progress bar at top (animates width on page change)
- **Back chevron** on pages 1-3 only (top-left, 13pt text + arrow)
- **Page transition**: horizontal slide, 380ms cubic-bezier(0.2,0,0,1)
- **Swipe gesture**: pan to switch pages, threshold 60px, resistance on edges
- **Page dots** (1-3): centered, 6px circles, active dot expands to 22px

Page 1 — Welcome: VELT wordmark 72pt accentIron + hero 28pt "Built for people who are serious about training." + "Get Started" CTA
Page 2 — Goal: 2×2 grid of 4 goal cards (Build Muscle / Lose Fat / Strength / Endurance), each with icon + label + description, selected = colored border + tinted bg
Page 3 — Level: 3 stacked cards with experience range + rest default (75s/90s/120s)
Page 4 — Units: 2 large side-by-side kg/lbs cards

### 2. Home
- **Greeting** (hour-based): "Good morning." 30pt + motivation line 13pt tertiary
- **Goal chip** top-right: tinted pill with arrow icon + goal name
- **Today's Plan card**: amber gradient top edge (3pt height, gradient transparent→amber→transparent), exercise count + duration pill top-right, 24pt routine name, preview "Bench · Incline · OHP +3 more", full-width "▶ Start Push A" CTA, "or start an empty workout →" link below
- **Stats row**: 3 equal StatBox (Streak / Weekly Volume / Monthly Count), icon 14pt + value 22pt + label 10pt
- **Last 7 Days**: 7 squares (1:1 aspect), done = amber filled with check, today (not done) = dashed amber border, future = empty surfaceElevated
- **Last Session card**: tappable → opens Workout Detail. Icon block + name + preview + 3 mini stats + date pill + chevron
- **Recent PRs**: horizontal scroll, 138px PR mini-cards (trophy + value 22pt + exercise name)

### 3. Train
- **My Routines**: cards with 3px colored left border, muscle chips in routine color tint, meta line "6 ex · ~45m · Done 2d ago", trailing "..." + colored "▶ Start" button
- **Quick Start bar**: amber bolt in tinted square, "Empty Workout" title, chevron
- **Divider**: ── EXPLORE PROGRAMS ── (lines + uppercase text)
- **Recommendation banner**: amber tint + bulb icon + "Based on your goal X and Y level, try **Program**"
- **Filter chips**: All / Beginner / Intermediate / Advanced (active = filled amber)
- **Program cards**: name + tagline + level pill top-right + days/week pill + goal pill. Goal-match programs have 1.5px amber border + "★ Your goal" inline. Non-match show "View details →"
- **Program Detail** (inline, replaces train content): back arrow + program name + pills row + description + "BEST FOR" amber-left-border callout + weekly schedule table + sample exercises bullet list + sticky bottom "Add Program to My Routines" CTA

### 4. Active Workout
- **Top bar**: routine name (tap to rename inline) + amber monospace timer 14pt + "Finish" amber text + 2pt amber progress line below showing % sets complete
- **Rest Timer** (slides down after completing a set): 44px circular ring + countdown + Skip ghost + +15s chip
- **Exercise sections**: header card (name + muscle/equipment pills + note icon + drag handle) → 5-col column headers → SetRow list → "+ Add Set" dashed ghost
- **Sticky bottom**: "+ Add Exercise" full-width ghost button
- **Add Exercise sheet**: search field + 8 category filter chips + exercise list (multi-select with check toggle) + sticky "Add N exercises" amber CTA

### 5. Workout Complete (full-screen)
- **Animated check ring**: 120pt diameter circle, accentIron stroke draws 0→full over 700ms, white check draws 500ms after (total ~1.2s)
- **Title** "Workout Complete" 26pt + routine name 14pt secondary
- **4-stat strip**: Duration / Volume / Sets / PRs (PRs has 1px accentIron border if > 0)
- **New PRs** (if any): cards with trophy + exercise + "prev → NEW value" arrow + "NEW PR!" amber pill
- **Exercises** summary list (collapsible): name + sets summary "3 × 8, 1 × 6" + muscle pill
- **Bottom**: Share ghost (flex:1) + Done amber (flex:2)
- **Confetti**: 20 pieces burst from center on Done tap (800ms, varied colors, rotates 720deg)

### 6. Nutrition
- **Header**: title + "Goals" ghost button
- **Calorie Ring Card**: 100×100 ring (amber stroke 9pt) + center: consumed kcal 22pt. Right column: Goal / Consumed / Remaining (color-coded green/red)
- **Goal chip** centered: "Targets for: Build Muscle"
- **Macro bars Card**: 3-column (Protein / Carbs / Fat) — each: label 10pt uppercase + value 17pt + 5pt progress bar + "of Xg" caption
- **Today's Log**: section header + "+ Add Food" amber link + food cards (name + macros + kcal amber + × delete) OR empty state
- **This Week chart**: 7 bars, today = full amber, past = amber 35% opacity, future = surfaceHigh stub, dashed amber goal line at calorie target
- **Add Food sheet**: search mode (search field + food list with kcal/macros) → tap food → Portion Detail (4 stat boxes + × multiplier stepper). "Enter manually →" link goes to Manual Entry (name field + 2×2 macro grid + portion multiplier)
- **Edit Goals sheet**: 4 preset chips (Build Muscle / Lose Fat / Strength / Endurance) + 4 input fields + Save

### 7. Progress
- **Header**: title + Week/Month/Year segmented control (rounded pill, active=filled amber)
- **KPI strip**: 3 cards (Volume / Workouts / Streak) — values 22pt, unit 10pt, label 10pt uppercase, Streak card has 1px accentIron border
- **Volume Chart**: 8-bar chart with Y-axis labels (0/5k/10k), current week = amber, others = surfaceHigh, x-axis week labels (W1-W8)
- **Bodyweight card**: latest 34pt + unit + change indicator green/red + "+ Log today" amber link + mini line chart (gradient fill, dots at data points, larger dot on latest). Empty state: scale icon + italic "Tap to log..."
- **PR list**: amber trophy circle + exercise + date 11pt tertiary + value 16pt amber. Tappable → PR Detail
- **Volume by Muscle (Pro gated)**: clean locked card, NOT fake data. Lock circle icon + "Advanced Analytics" 16pt + subtitle + "Upgrade" ghost button. Abstract amber radial gradient bg.

### 8. Settings
- **Header**: "VELT" wordmark 28pt accentIron + "Tracking since [date] · X workouts total" 12pt tertiary
- **Sections** (uppercase labels): Appearance, Training, Goals, Data, App
- **Setting row**: label 14pt + optional sub 11pt tertiary + value/control on right + chevron if navigable
- **Theme row**: shows current theme name + small accent color swatch circle + chevron → opens Theme sheet
- **Weight Unit row**: inline kg/lbs segmented toggle (no chevron, immediate switch)
- **Goal row**: tinted amber pill showing current goal + chevron
- **Pro card** (in App section): amber left bar accent + lock icon + "VELT Pro" + "Advanced Analytics & more coming soon" + "STAY TUNED" amber pill
- **Sheets**: Rest Timer (slider 30-300s + 4 preset chips), Level Picker (3 cards), Goal Picker (2×2 grid), Delete Confirm (warning + Cancel ghost + Delete red), Theme Picker (see below)

### 9. Workout Detail
- **Sticky header**: back arrow + "Share" ghost + COMPLETED WORKOUT eyebrow + workout name 26pt + date subtitle
- **Stats grid 2×2**: Duration / Volume / Sets / PRs (PRs accent border if > 0)
- **Avg rest pill** centered with timer icon
- **PRs callout** (if any): amber tinted cards listing each PR with trophy + exercise + value
- **Session note** (if any): italic quoted text card
- **Exercises list**: each in own card with header (name + muscle pill) + set rows showing type badge + weight × reps in mono + trophy icon if PR or green check if done

### 10. Exercise Detail
- **Header**: back + eyebrow "CHEST · BARBELL" + exercise name 26pt
- **Top set hero card**: "BEST SET (CURRENT)" amber eyebrow + huge value 28pt + "↑ +5kg vs 30 days ago" green + trophy circle right
- **3-up mini stats**: Volume / Sessions / PRs (accent on PRs)
- **Top Set Progression chart**: 8-point line chart with date labels below, current point larger amber dot
- **Recent Sessions list**: date + sets summary in mono + PR pill if applicable, last 5 sessions
- **Form Notes**: section header with "Edit" amber link + paragraph card

### 11. PR Detail
- **Header**: back + "Share" ghost + "1RM PERSONAL RECORD" amber eyebrow + exercise name 26pt + achieved date
- **Hero PR card**: amber gradient bg + trophy circle 56pt + huge value 56pt amber + "× 5 reps" caption
- **All-Time Progression chart**: 8-point line chart with grid lines + footer row showing Started / Gained (green) / Current (amber)
- **PR Attempts timeline**: vertical timeline with dots, current = larger amber dot + glow, "CURRENT" pill + "PR" pill on previous PRs
- **PR Note**: italic quoted text + Edit link

### 12. Theme Picker Sheet
- 4 cards in 2 sections (FREE / VELT PRO with UPGRADE pill if !isPro)
- Each card: 64×64 mini preview swatch (showing surface + elevated + accent dots + bar) + name 14pt + description 11pt + trailing check (active) or PRO pill (locked)
- Active theme: amber border + amber check circle on right
- Locked theme tap → inline upgrade prompt (back button + locked preview card + body text + "Upgrade to VELT Pro" CTA)

---

## Motion

| Action | Duration | Easing |
|---|---|---|
| Page transition (onboarding) | 380ms | cubic-bezier(0.2,0,0,1) |
| Sheet slide up | 280ms | cubic-bezier(0.2,0,0,1) |
| Set complete | 200ms | ease-out |
| Rest timer slide down | 240ms | cubic-bezier(0.2,0,0,1) |
| Button press | 120ms | linear |
| Check ring draw | 700ms | cubic-bezier(0.2,0,0,1) |
| Check mark draw | 400ms (delay 500ms) | cubic-bezier(0.2,0,0,1) |
| Confetti burst | 800ms | cubic-bezier(0.2,0.6,0.3,1) |
| Theme switch | instant | n/a |

## Haptics

| Action | Type |
|---|---|
| Set complete | HapticFeedback.lightImpact() |
| Button press primary | HapticFeedback.mediumImpact() |
| Rest timer done | HapticFeedback.notificationWarning() |
| PR achieved | HapticFeedback.notificationSuccess() |
| Destructive confirm | HapticFeedback.heavyImpact() |

---

## Anti-Patterns — Never Ship

- No gradient backgrounds (except subtle PR hero card)
- No motivational quotes or "you're amazing!" popups
- No social feed, likes, follows, comments
- No emoji in primary UI (streak flame SVG OK)
- No neon gym aesthetic
- No fake data behind Pro locks
- No purple accents (Hevy owns purple)
- No hardcoded hex values inside widgets — only use AppColors
- No magic spacing numbers — only AppSpacing constants

---

## Implementation Order

1. **Theme system first**: AppColors extension + 4 themes + ThemeData builders. Verify theme switching works end-to-end before building screens.
2. **Shared widgets**: PrimaryButton, GhostButton, Pill, FilterChip, SectionHeader, StatBox, BottomSheet shell.
3. **Tab shell + BottomNav** with 5 tabs.
4. **Home screen** (most-viewed, exercises layout patterns).
5. **Active Workout** (most-used, validates SetRow + rest timer + sheet).
6. **Onboarding** (validates page swipe + animation).
7. Remaining screens in order: Train → Workout Complete → Nutrition → Progress → Settings → Detail screens.

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  shared_preferences: ^2.3.0     # theme + user prefs persistence
  provider: ^6.1.2               # OR riverpod
```

## Files in this bundle

- `VELT Fitness App.html` — Main interactive prototype (open in browser)
- `velt/` — All React component source files (visual references)
- `ios-frame.jsx` — iOS device chrome (just for the prototype; ignore for Flutter)

When in doubt, **open the prototype and inspect the screen** rather than guessing from the spec.

# VELT — Flutter Design Handoff

## Overview
VELT is a premium, offline-first iOS fitness tracker with a "precision instrument" feel. The design brief is: **Fast · Heavy · Quiet · Private** — no decoration, no animation for animation's sake, no motivational popups. Think high-end sports watch UI, not fitness influencer app.

## About the Design Files
The files in this repository are **HTML/React design prototypes** — high-fidelity mockups showing intended look and behavior. They are not production code to copy directly. Your task is to **recreate these designs in Flutter** using established Flutter patterns, Material 3, and the Dart token files included here.

**Fidelity level: HIGH-FIDELITY.** Recreate pixel-accurately using the exact color tokens, spacing values, typography styles, border radii, and interaction patterns documented here.

---

## Project Structure (Flutter target)

```
lib/
├── theme/
│   ├── app_colors.dart      ← All color tokens (9 themes)
│   ├── app_spacing.dart     ← Spacing + radius + touch target constants
│   ├── app_typography.dart  ← TextStyle factory methods
│   └── app_theme.dart       ← ThemeData builders for each theme
├── widgets/
│   ├── set_row.dart         ← SetRow component (most critical)
│   ├── primary_button.dart  ← PrimaryButton (56pt, accentIron)
│   ├── routine_card.dart    ← RoutineCard with left color bar
│   └── rest_timer_banner.dart
├── screens/
│   ├── home_screen.dart
│   ├── train_screen.dart
│   ├── active_workout_screen.dart
│   ├── workout_summary_screen.dart
│   ├── progress_screen.dart
│   ├── nutrition_screen.dart
│   └── profile_screen.dart
└── main.dart
```

---

## Design Tokens

### Colors
All tokens live in `AppColors`. **Never hardcode hex values in widgets.** Access via `Theme.of(context).extension<AppColors>()!`.

| Token | Iron Dark | Role |
|-------|-----------|------|
| `ink` | `#0B0F17` | Deepest bg — modal scrims |
| `surface` | `#0B0F17` | Primary screen background |
| `surfaceElevated` | `#1A2030` | Cards, list rows, sheets |
| `surfaceHigh` | `#252D3D` | Pressed/hovered surfaces |
| `divider` | `#2A3142` | Hairline separators |
| `textPrimary` | `#F1F5F9` | All body text and headings |
| `textSecondary` | `#94A3B8` | Captions, metadata, labels |
| `textTertiary` | `#64748B` | Disabled, placeholder |
| `accentIron` | `#D97706` | PRIMARY — CTAs, highlights, PRs |
| `accentIronSoft` | `#92400E` | Accent background — badges, rest timer bg |
| `successLime` | `#84CC16` | PR celebrations, completed sets |
| `warningAmber` | `#F59E0B` | Cautions, almost-done rest timer |
| `errorRose` | `#E11D48` | Destructive actions, errors |

### Available Themes (9 total)
- **Iron Dark** (default) — `#D97706` accent
- **Warm Paper** (Pro) — Light/warm bg, `#B45309` accent
- **Midnight Steel** — `#6366F1` indigo accent
- **Forest Iron** — `#22C55E` green accent
- **Blood Orange** — `#EA580C` deep orange accent
- **Espresso** — `#C2692A` warm brown accent
- **Arctic** — `#38BDF8` ice blue accent
- **Obsidian** — `#A78BFA` soft purple accent
- **Military** — `#84CC16` lime green accent

### Spacing (4pt base grid)
```dart
AppSpacing.xxs  =  4   // Icon-to-label gap
AppSpacing.xs   =  8   // Tight stacking
AppSpacing.sm   = 12   // Card internal padding (small)
AppSpacing.md   = 16   // Default card padding
AppSpacing.lg   = 24   // Between cards
AppSpacing.xl   = 32   // Major section breaks
AppSpacing.xxl  = 48   // Above primary CTAs
AppSpacing.xxxl = 64   // Empty state centering
AppSpacing.screenH = 20  // Horizontal screen margin
```

### Border Radius
```dart
AppRadius.xs   =  6   // Pills, tags
AppRadius.sm   = 10   // Input fields
AppRadius.md   = 16   // Standard cards ← most used
AppRadius.lg   = 20   // Bottom sheets, modals
AppRadius.xl   = 28   // Paywall hero, onboarding
AppRadius.full = 999  // Circular buttons, FAB
```

### Typography
```dart
// Display (Inter Tight Bold 700)
AppTypography.displayXL(color)   // 48pt — PR celebrations only
AppTypography.displayL(color)    // 34pt — Screen titles
AppTypography.displayM(color)    // 28pt — Section headers

// Title (Inter 600)
AppTypography.titleL(color)  // 22pt — Card titles
AppTypography.titleM(color)  // 17pt — List row titles
AppTypography.titleS(color)  // 15pt — Buttons, labels

// Body (Inter 400)
AppTypography.bodyL(color)   // 16pt
AppTypography.bodyM(color)   // 14pt
AppTypography.bodyS(color)   // 12pt — Metadata

// Special
AppTypography.mono(color)          // 16pt, tabular figures — weight × reps
AppTypography.caption(color)       // 11pt — Pills, tags
AppTypography.sectionHeader(color) // 11pt / 600 / uppercase / letter-spacing 0.08em
```

**CRITICAL:** All numeric Text widgets (weight, reps, sets, times) MUST use `fontFeatures: [FontFeature.tabularFigures()]`. Use `AppTypography.mono()` for set data.

---

## Screens

### 1. Home Screen (`/`)
**Layout (top → bottom):**
- Safe area top
- Header: Day label (11pt uppercase) + `VELT` wordmark (34pt Inter Tight, all `accentIron`)
- Streak banner: flame SVG + "N-day streak" + 7 progress dots (filled=accentIron)
- **Today's Plan card** (`surfaceElevated`, 16pt radius):
  - Left 4px `accentIron` bar (position absolute, full height)
  - Label: "TODAY'S PLAN" (section header style)
  - Routine name (17pt, Inter Tight Bold)
  - Exercise count + duration chip (`surfaceHigh` bg)
  - Exercise preview line: "Bench Press · Incline Press · OHP +3 more" (11pt, textTertiary)
  - `PrimaryButton` "Start Workout" (56pt, full width)
- Quick Start card (dashed border, same structure)
- Last Workout section: name + date + duration | volume (with 1px vertical divider)
- Recent PRs: horizontal scroll of PRCards (each with ↑ trend arrow in `successLime`)

### 2. Train Screen
**Layout:**
- Header: "Train" (34pt) + "+ Routine" ghost button
- MY ROUTINES: `RoutineCard` list
  - Each card: 72pt height, `surfaceElevated` bg, left 4px color bar (routine.color)
  - Name (15pt Inter Tight Bold) + exercise count + last performed (12pt textSecondary)
- METHODS & PROGRAMS:
  - Filter chips: All / Bodybuilding / Powerlifting / Strength
    - Active: `accentIron` bg + white text, 6px border-radius pill
    - Inactive: `surfaceElevated` bg + textSecondary text
  - Category dot colors: BB=`#D97706`, PL=`#6366F1`, Strength=`#22C55E`

### 3. Active Workout Screen (full-screen modal, covers tab bar)
**Layout:**
- Top bar: routine name (15pt, truncated) + elapsed time (16pt Inter Tight, textSecondary) + ⋯ menu
- Rest Timer banner (slides down on set completion):
  - bg: `#1A0F00`, border: `1px solid accentIron`
  - Timer: 32pt Inter Tight Bold, `accentIron` color
  - Skip: textTertiary / +15s: `#1A2030` chip
- Progress bar: 3pt, `accentIron` fill, animates on set completion
- **Current Exercise card** (`surfaceElevated`, left 3px `accentIron` bar):
  - Exercise name (18pt Inter Tight Bold)
  - Muscle + equipment (11pt textSecondary)
  - "Last: 8 × 100 kg" pill (textTertiary bg)
  - Column headers: Set | Prev | Weight | Reps | ✓ (9pt uppercase textTertiary)
  - **SetRow** list (see `set_row.dart`)
  - "+ Add Set" dashed ghost button
- Exercise navigation chips (horizontal scroll):
  - Active: `accentIron` bg + white text, 20px radius
  - Passive: `surfaceHigh` bg + textSecondary text, 20px radius
  - Completed: `successLime` tinted bg
- Up Next collapsed cards (1-2 upcoming exercises)
- Sticky bottom: "Finish Workout" `PrimaryButton`

### 4. Workout Summary Screen
- "WORKOUT COMPLETE" label (12pt, `successLime`)
- Routine name (34pt Inter Tight Bold)
- Stats row: 3 `StatCard`s (duration / volume / sets)
- PR badge (animated spring on appear): gold gradient bg, 🏆, exercise + value
  - Animation: scale 0→1 spring 600ms + haptic `notificationSuccess`
  - Only appears if a PR was set this session
- Exercise breakdown list

### 5. Progress Screen
**KPI strip:** 3 cards side-by-side (no scroll):
- Volume: 48,200 kg
- Workouts: 12
- Streak: 7 (accent color)
- Numbers: 28pt Inter Tight Bold, label: 10pt uppercase textTertiary

**Volume by Muscle** (Pro-gated):
- Horizontal bar chart
- Pro lock overlay: blur 8px, large lock SVG icon, "Upgrade" ghost button

**Top Exercises:** Each row:
- Exercise name + last weight (12pt accentIron, tabular) + change indicator ("+2.5 kg" successLime)
- Mini sparkline SVG (64×28pt, 2pt stroke, accentIron)

**Personal Records:** Badge colors:
- `1RM` → `accentIron` bg, white text
- `Volume` → `#6366F1` bg, white text

### 6. Nutrition Screen
**Calorie Ring:** SVG circle, r=62, stroke=11, accentIron progress, 30px number center

**Macro bars** (3 equal-width cards):
- Protein: `#D97706`
- Carbs: `#38BDF8`
- Fat: `#84CC16`
- Each: 4px progress bar at bottom

**Remaining kcal color logic:**
- >200 remaining → `successLime`
- <200 remaining → `warningAmber`
- Exceeded → `errorRose`

**Meals section:** 4 rows with 1px `divider` separators, each with `+ Add` ghost chip

**Weekly bars:** Today = `accentIron`, past = `surfaceHigh`, kcal value above each bar (9pt textTertiary)

### 7. Profile Screen
**Pro Banner:** `surfaceElevated` bg, left 4px `accentIron` bar, "FREE PLAN" uppercase chip

**Theme Selector:** 5×2 grid (horizontal scroll):
- Each card: 88×68px, bg color preview + mini card overlay + 2 color dots (bg tone + accent)
- Selected: 2px solid accent-color border + name label in accent color
- Deselected: name label in textTertiary

**Danger Zone:** "Delete All Data" — `errorRose` text, confirm dialog before action

---

## Components

### PrimaryButton
```dart
height: 56pt
borderRadius: AppRadius.md (16pt)
background: c.accentIron
text: white, titleS (15pt 600)
boxShadow: 0 0 20px rgba(217,119,6,0.25)  // subtle glow
pressed: 0.92 opacity + scale(0.99)
disabled: 0.33 opacity
haptic: HapticFeedback.mediumImpact()
```

### RoutineCard
```dart
height: 72pt
background: c.surfaceElevated
borderRadius: AppRadius.md
Left color bar: 4px wide, full height, routine.color
Name: 15pt Inter Tight 700
Metadata: 12pt bodyS textSecondary
Trailing: chevron textTertiary
Pressed: c.surfaceHigh background
```

### SetRow (see set_row.dart)
States: pending / active / completed
- Active: `surfaceElevated` bg + left 3px `accentIron` bar
- Completed: opacity 0.55, weight/reps in `successLime`
- Warmup badge: "W" `accentIron` text, `#1A0F00` bg, 8px radius

---

## Motion & Haptics

| Action | Duration | Easing | Haptic |
|--------|----------|--------|--------|
| Set complete | 200ms | ease-out | `lightImpact` |
| Sheet slide | 300ms | cubic(0.2,0,0,1.0) | — |
| Button press | 120ms | linear | `mediumImpact` |
| PR badge appear | 600ms | spring(mass:1, stiff:100) | `notificationSuccess` |
| Rest timer complete | — | — | `notificationWarning` |
| Destructive confirm | — | — | `heavyImpact` |

**What NOT to animate:**
- Number changes in set rows → snap instantly
- Tab switches → instant
- List scroll → native physics only

---

## Elevation Rules (dark UI)
Dark UIs use **surface color shifts + subtle borders**, NOT box shadows.

| Level | Treatment | Used on |
|-------|-----------|---------|
| 0 | Flat — `surface` bg | Main screen areas |
| 1 | `surfaceElevated` bg | Cards, exercise rows |
| 2 | `surfaceElevated` + 0.5px `divider` | List rows inside elevated cards |
| 3 | `surfaceHigh` + soft shadow (blur 24, y+8, 25% opacity) | Bottom sheets, paywall |

Never stack two shadows. One elevation-3 surface on screen at a time.

---

## Accessibility

- All interactive elements: `Semantics` labels
- Color contrast WCAG AA: 4.5:1 body, 3:1 large text
- `MediaQuery.disableAnimations` → kill all animations instantly
- VoiceOver: numbers announced as "100 kilograms, 8 reps"
- Minimum touch target: 44pt (enforced via `AppTouchTarget.minimum`)
- Success never relies on green alone → always paired with check icon
- Error never relies on red alone → always paired with X or text

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1      # Inter + Inter Tight
  shared_preferences: ^2.3.0 # Theme persistence
  provider: ^6.1.2           # OR riverpod — state management

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Anti-patterns — NEVER appear in VELT

| Anti-pattern | Why banned |
|---|---|
| Neon gym gradients | Generic; not our user |
| 'You're amazing!' popups | Patronizing to serious lifters |
| Gradient backgrounds | Clashes with editorial feel |
| Purple accents | Hevy owns purple; we are iron orange |
| Confetti / fireworks (except PRs) | Reserve celebration for real achievement |
| Emoji in primary UI | Streak flame OK; never in headings/CTAs |
| Social patterns (likes, follow) | Wrong product category |
| Motivational quotes | Lifters set their own motivation |
| Hardcoded hex values in widgets | Use AppColors tokens only |
| Magic spacing numbers | Use AppSpacing constants only |

---

## Design Reference Files
The following HTML prototype files are included in this handoff bundle. Open them in a browser to see the interactive designs:

- `VELT Fitness App.html` — Main prototype (all screens, navigation, theme switcher)

Open the prototype and navigate all 5 tabs (Home, Train, Nutrition, Progress, Profile), tap "Start Workout" for the workout flow, and use the Profile tab to preview all 9 themes.

---

*Design system by VELT. Brief version 1.0. Build with care.*

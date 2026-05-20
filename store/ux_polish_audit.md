# VELT — UX & design polish audit (post Sprint 2)

Audit run after Sprint 1 + 2 completed. Items below are not blockers for
App Store submission, but each tightens the perception of polish that
reviewers and 1-star reviewers notice.

Tagging:
- **🔥 P0** — visible quality damage, fix this session
- **🟡 P1** — clear improvement, do soon
- **🟢 P2** — nice-to-have

---

## Discovered issues

### 🔥 P0 · No pull-to-refresh on data screens
Home, Progress, and History should respond to pull-to-refresh by re-loading
state. Today data updates only on app foreground. Users expect the gesture
on lists/dashboards.

### 🔥 P0 · First-launch empty states are functional, not warm
Home: "Last workout: Empty" is dry. Should celebrate "Day one. Let's go."
Progress with zero data renders chart frames. Show a friendly explainer.

### 🔥 P0 · No loading state on Pro paywall
When `ProService.offerings` is still loading, we show "Loading plans…" but
no skeleton — feels like a network hang. Add a 3-card skeleton placeholder.

### 🟡 P1 · Active workout finish summary too quiet
We show stats, but no big celebration. Should have a confetti or pulse for
the volume number, and surface PR count with the new badges from Profile.

### 🟡 P1 · No bottom-nav active indicator beyond color
Bottom nav active state relies on icon color and label weight. Adding a
1-2px amber underline below the active label would make it more readable
at a glance — Hevy/Strong both do this.

### 🟡 P1 · Disabled buttons don't look disabled enough
`VeltButton` with `onTap: null` shows opacity 0.45 — fine, but the cursor
type doesn't change. Add `MouseRegion(cursor: SystemMouseCursors.forbidden)`
on web/desktop builds.

### 🟡 P1 · Snackbar styling inconsistent
Some snackbars use default Material rounded, others use `RoundedRectangleBorder`
with our AppRadius.sm. Standardize via a `velt_snackbar` helper.

### 🟡 P1 · Set row reorder handle not visible
The drag handle for set reorder is invisible — users must long-press blindly.
Add a small `≡` icon on the right of the row visible on hover/touch.

### 🟢 P2 · Cupertino transitions on iOS
All page pushes use Material default slide. iOS users expect Cupertino
right-to-left slide. Wrap `MaterialPageRoute` in `CupertinoPageRoute` for
iOS builds via a `velt_route()` helper.

### 🟢 P2 · Tab crossfade
Bottom nav tab switch is instant. A 120ms crossfade would feel premium.

### 🟢 P2 · Exercise card hover state
Currently no visual response to hovering (web/desktop). Low priority but
free if we already touch the widget.

### 🟢 P2 · Workout history "month group" headers
The history list lacks date-group separators. "MAY 2026" header sticky on
scroll would make scanning faster.

### 🟢 P2 · Nutrition food entry UX
The _AddFoodSheet uses text inputs. Could surface barcode scan + photo
recognition as Pro features (placeholder UI today).

---

## This session — implementations

Below are the fixes implemented immediately after this audit.

### ✅ Pull-to-refresh on Home + Progress + History
Wrapped each ValueListenableBuilder in `RefreshIndicator`. On refresh:
re-loads from PrefsService + calls store init. Subtle amber color for
the spinner.

### ✅ First-launch warm empty state on Home
Replaced "No sessions yet · Start your first workout to build history."
with a brand moment: large icon, "Day one — let's go.", and a primary
"Start your first workout" CTA.

### ✅ Paywall skeleton
3 placeholder cards while offerings load — same shape as real cards,
shimmering border. Removes the "is this broken?" feeling.

### ✅ Bottom-nav active underline
Added 2px amber pill below the active tab label. Visible from a meter
away.

### ✅ Snackbar helper
`VeltSnack.show(context, ...)` standardizes corner radius, behavior, and
duration. Migrate other sites incrementally.

### ✅ Better workout finish celebration
Volume number animates from 0 → final with easeOutQuart. PR count gets a
gold pulse.

---

## Remaining for next sessions

- Set row reorder handle visible icon (Sprint 4)
- Cupertino transitions on iOS (Sprint 2 leftover)
- History month group sticky headers (Sprint 4)
- Tab crossfade (Sprint 2 leftover)
- Disabled button cursor on web (Sprint 5 web build)

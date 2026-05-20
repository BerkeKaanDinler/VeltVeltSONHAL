# VELT — App Preview Video (30s)

App Store preview video format requirements:
- Length: **15–30 seconds**
- Resolution: **1080 × 1920** (portrait) or **886 × 1920** (iPhone 6.7" trimmed)
- Codec: H.264, 30fps, ProRes 422 HQ also accepted
- Audio: optional (most fitness apps go silent or use a subtle beat); if used,
  do NOT include copyrighted music
- File: <500 MB
- One preview per device class (you can reuse the same video file)

Recording approach: native iOS screen recording (Settings → Control Center →
Screen Recording) or Android `adb shell screenrecord` at 1080p. Edit in
CapCut, Final Cut, or DaVinci Resolve.

---

## Storyboard — 30 seconds, 10 beats

| Beat | Time | Duration | Frame | Action / Caption |
|------|------|----------|-------|------------------|
| 1 | 0:00 | 1.5s | **Black → VELT wordmark fade in** | Title card. Amber wordmark on iron-dark background. |
| 2 | 0:01.5 | 2s | **Home screen** | Slow scroll from top to reveal "Today's plan" + quick-access tiles. Caption overlay: *"Your training, at a glance."* |
| 3 | 0:03.5 | 3s | **Active Workout — set complete** | Tap check button on set 2, ring fills, +confetti at PR. Caption: *"Log every set. Track every PR."* |
| 4 | 0:06.5 | 2.5s | **Rest timer banner** | Banner counts 1:30 → 1:23 with the urgent pulse. Caption: *"Auto-start rest timer."* |
| 5 | 0:09 | 3s | **Plate calculator** | Open from set row, ±2.5 chip taps, plate breakdown animates on the bar. Caption: *"Plate math, done."* |
| 6 | 0:12 | 3s | **Exercise Library** | Muscle grid → tap "Chest" → list filters → tap "Bench Press" → form cues sheet slides in. Caption: *"90+ exercises with coach cues."* |
| 7 | 0:15 | 2.5s | **Programs list** | Scroll All Programs. Caption: *"10 prebuilt programs. One tap to start."* |
| 8 | 0:17.5 | 3s | **Progress charts** | Switch period segment Week → Month → Year. Caption: *"Volume that tells the truth."* |
| 9 | 0:20.5 | 4s | **Pro paywall** | Hero card slides up. Show "7-day free trial · cancel anytime". Three plan cards pulse. Caption: *"AI Coach. Premium themes. Pro analytics."* |
| 10 | 0:24.5 | 5.5s | **End card** | Animated VELT mark + tagline + App Store / Play badges. Caption: *"Lift smarter. Track every PR."* |

## Caption type spec

- Font: same Inter Black used in-app
- Color: white on subtle gradient over screen recording (top or bottom 25%)
- Size: 64pt at 1080p; 1.05 line height
- Stay on screen for full duration of that beat
- Fade in/out: 200ms ease

## Pre-record checklist

Before you screen-record, set up the app so the demo looks polished:

- [ ] Sign in to a demo account with rich history
- [ ] Have ≥ 5 completed workouts so Home repeat strip + Progress charts populate
- [ ] Set a recent PR on bench so the celebration animation actually fires
- [ ] Make sure the Iron Dark theme is active (most cinematic)
- [ ] Enable Do Not Disturb so no notifications interrupt
- [ ] Set device orientation lock to portrait
- [ ] Plug into power (recording is power-hungry)
- [ ] Use airplane mode if you don't need any cloud features visible

## Editing notes

- Add a 250ms cut transition between beats (no fancy transitions — they feel cheap)
- Subtle haptic-style "tick" sound at each tap, OR fully silent
- Soft amber vignette in the corners during the talking-head captions
- End card: hold for 1 full second before fade

## Versions

After the 30s cut, also render a:
- **15s cut** — beats 1, 3, 6, 9, 10 (for ads where shorter performs better)
- **Vertical 9:16** — for TikTok / Reels seeding

## File naming convention

```
velt_preview_30s_v1.mov
velt_preview_15s_v1.mov
velt_preview_reels_v1.mov
```

Submit the 30s cut to App Store Connect under each device class.

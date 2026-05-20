# Store screenshots — Capture & Frame guide

This folder contains everything you need to ship App Store / Play Store
screenshots.

## Files

- `capture.ps1` — PowerShell helper that runs `adb screencap` and saves the
  raw screen as a PNG. Use this on a running Android emulator/device.
- `frame_generator.html` — opens in any browser. Wraps each raw capture in
  the on-brand VELT frame (gradient background, eyebrow, caption, device
  bezel). Exports as PNG ready for App Store upload.
- `android/` — raw 1080×2400 captures land here.
- `framed/` — final 1290×2796 ready-to-upload images (created by export).

## Capture procedure

1. Make sure your emulator is running and VELT is installed.
   - `flutter run -d emulator-5554` then leave running

2. Open VELT to each target screen (see list below). For each:
   ```pwsh
   cd store/screenshots
   pwsh capture.ps1 01_home
   ```

3. The 10 target screens are:

   | # | Slot name | Screen to navigate to |
   |---|-----------|-----------------------|
   | 01 | `01_home` | Home tab — make sure a recent workout is visible |
   | 02 | `02_active_workout` | Start any workout, complete 2-3 sets so the screen is rich |
   | 03 | `03_exercise_library` | Train tab → Library → showing muscle grid |
   | 04 | `04_programs` | Train tab → All programs section |
   | 05 | `05_rest_timer` | Active workout with rest timer banner visible |
   | 06 | `06_plate_calc` | Active workout → plate calc icon → plate calculator open |
   | 07 | `07_progress` | Progress tab — week view with volume chart |
   | 08 | `08_nutrition` | Nutrition tab — water tracker + macros visible |
   | 09 | `09_pro_paywall` | Profile → VELT Pro → Paywall screen |
   | 10 | `10_profile` | Profile tab — hero card + achievements visible |

## Frame & export

1. Make sure `android/01_home.png` through `android/10_profile.png` exist.
2. Open `frame_generator.html` in Chrome (or Edge).
3. Edit the captions in the `SHOTS` array at the bottom if you want to
   rewrite copy. The order matches the table above.
4. Click **Export all (PNG)**. Chrome will download 10 PNGs named
   `framed_01_home.png` … `framed_10_profile.png`.
5. Move them to `framed/` and upload to App Store Connect / Play Console.

## App Store sizing notes

- iPhone 6.7" (Pro Max class): 1290 × 2796 — primary
- iPhone 6.1": 1179 × 2556 — auto-derived by App Store from 6.7"
- iPhone 5.5" (legacy): 1242 × 2208 — required for older apps; you can
  re-export at this aspect ratio using the same frame.
- iPad 13": 2064 × 2752 — optional unless targeting iPad.

The frame_generator outputs at 6.7" by default. To make 5.5", change the
`.frame { aspect-ratio: 1290 / 2796 }` rule to `1242 / 2208` and re-export.

## Quick troubleshooting

- "adb not found" → install Android SDK Platform Tools and add to PATH.
- "device unauthorized" → in the emulator settings, accept the USB debug
  prompt.
- Captures look blank / black → make sure VELT was visible in the foreground
  when you ran the capture command.

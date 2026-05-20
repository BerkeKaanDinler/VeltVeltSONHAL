const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const root = __dirname;
const htmlPath = path.join(root, "velt_screens_themed.html");
const outDir = path.join(root, "exports");
fs.mkdirSync(outDir, { recursive: true });

const chromeCandidates = [
  process.env.CHROME_PATH,
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
  "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
].filter(Boolean);

const chrome = chromeCandidates.find((candidate) => fs.existsSync(candidate));
if (!chrome) {
  console.error("Chrome or Edge executable was not found.");
  process.exit(1);
}

const fileUrl = `file:///${htmlPath.replace(/\\/g, "/")}`;
const themes = ["iron", "slate", "rose", "warm", "emerald"];
const screens = [
  "00-onboarding",
  "03-program-detail",
  "04-routine-editor",
  "05-active-workout",
  "06-workout-summary",
  "07-nutrition",
  "08-progress",
  "09-workout-history",
  "10-workout-detail",
  "11-exercise-detail",
  "12-pr-detail",
  "13-profile",
  "14-pro",
];

function run(args) {
  const result = spawnSync(chrome, args, { stdio: "inherit" });
  if (result.status !== 0) process.exit(result.status || 1);
}

for (const screen of screens) {
  for (const theme of themes) {
    const out = path.join(outDir, `${screen}-${theme}.png`);
    run([
      "--headless=new",
      "--disable-gpu",
      "--hide-scrollbars",
      "--no-first-run",
      "--no-default-browser-check",
      "--force-device-scale-factor=1",
      "--window-size=390,844",
      `--screenshot=${out}`,
      `${fileUrl}?screen=${encodeURIComponent(screen)}&theme=${encodeURIComponent(theme)}`,
    ]);
  }

  const board = path.join(outDir, `${screen}-all-themes.png`);
  run([
    "--headless=new",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-default-browser-check",
    "--force-device-scale-factor=1",
    "--window-size=2074,900",
    `--screenshot=${board}`,
    `${fileUrl}?screen=${encodeURIComponent(screen)}`,
  ]);
}

console.log(`Exported ${screens.length} screens in ${themes.length} themes to ${outDir}`);

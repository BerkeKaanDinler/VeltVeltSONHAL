const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const root = __dirname;
const htmlPath = path.join(root, "velt_redesign.html");
const outDir = path.join(root, "exports");

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

fs.mkdirSync(outDir, { recursive: true });

const screens = [
  ["01", "onboarding"],
  ["02", "home"],
  ["03", "train"],
  ["03", "train-v2"],
  ["04", "program-detail"],
  ["05", "routine-editor"],
  ["06", "active-workout"],
  ["07", "workout-summary"],
  ["08", "nutrition"],
  ["09", "progress"],
  ["10", "workout-history"],
  ["11", "workout-detail"],
  ["12", "exercise-detail"],
  ["13", "pr-detail"],
  ["14", "profile"],
  ["15", "pro"],
];

const fileUrl = `file:///${htmlPath.replace(/\\/g, "/")}`;

for (const [index, screen] of screens) {
  const out = path.join(outDir, `${index}-${screen}.png`);
  const url = `${fileUrl}?screen=${encodeURIComponent(screen)}`;
  const result = spawnSync(chrome, [
    "--headless=new",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-default-browser-check",
    "--force-device-scale-factor=1",
    "--window-size=390,844",
    `--screenshot=${out}`,
    url,
  ], { stdio: "inherit" });

  if (result.status !== 0) {
    console.error(`Export failed for ${screen}.`);
    process.exit(result.status || 1);
  }
}

console.log(`Exported ${screens.length} screens to ${outDir}`);

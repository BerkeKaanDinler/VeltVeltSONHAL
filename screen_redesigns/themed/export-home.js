const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const root = __dirname;
const htmlPath = path.join(root, "home_themed.html");
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

for (const theme of themes) {
  const out = path.join(outDir, `01-home-${theme}.png`);
  const result = spawnSync(chrome, [
    "--headless=new",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-default-browser-check",
    "--force-device-scale-factor=1",
    "--window-size=390,844",
    `--screenshot=${out}`,
    `${fileUrl}?theme=${encodeURIComponent(theme)}`,
  ], { stdio: "inherit" });

  if (result.status !== 0) process.exit(result.status || 1);
}

const board = path.join(outDir, "01-home-all-themes.png");
const boardResult = spawnSync(chrome, [
  "--headless=new",
  "--disable-gpu",
  "--hide-scrollbars",
  "--no-first-run",
  "--no-default-browser-check",
  "--force-device-scale-factor=1",
  "--window-size=2074,900",
  `--screenshot=${board}`,
  fileUrl,
], { stdio: "inherit" });

if (boardResult.status !== 0) process.exit(boardResult.status || 1);
console.log(`Exported themed Home screens to ${outDir}`);

const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const root = __dirname;
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

const html = process.argv[2] || "01-home.html";
const output = process.argv[3] || "01-home.png";
const htmlPath = path.join(root, html);
const outPath = path.join(outDir, output);
const fileUrl = `file:///${htmlPath.replace(/\\/g, "/")}`;

const result = spawnSync(chrome, [
  "--headless=new",
  "--disable-gpu",
  "--hide-scrollbars",
  "--no-first-run",
  "--no-default-browser-check",
  "--force-device-scale-factor=1",
  "--window-size=390,844",
  `--screenshot=${outPath}`,
  fileUrl,
], { stdio: "inherit" });

if (result.status !== 0) process.exit(result.status || 1);
console.log(outPath);

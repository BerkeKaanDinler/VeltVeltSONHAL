// Generates a 1024x1024 VELT app icon PNG using pure Node.js (no deps)
const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

const SIZE = 1024;
// Colors
const BG   = [11, 15, 23];       // #0B0F17 iron dark
const ACC  = [217, 119, 6];       // #D97706 amber accent
const WHT  = [255, 255, 255];

// Create RGBA pixel buffer
const pixels = new Uint8Array(SIZE * SIZE * 4);

function setPixel(x, y, r, g, b, a = 255) {
  if (x < 0 || x >= SIZE || y < 0 || y >= SIZE) return;
  const i = (y * SIZE + x) * 4;
  // Simple alpha blend over existing
  const alpha = a / 255;
  pixels[i + 0] = Math.round(pixels[i + 0] * (1 - alpha) + r * alpha);
  pixels[i + 1] = Math.round(pixels[i + 1] * (1 - alpha) + g * alpha);
  pixels[i + 2] = Math.round(pixels[i + 2] * (1 - alpha) + b * alpha);
  pixels[i + 3] = 255;
}

// Fill background
for (let y = 0; y < SIZE; y++) {
  for (let x = 0; x < SIZE; x++) {
    setPixel(x, y, ...BG);
  }
}

// Draw a thick anti-aliased line using Wu's algorithm
function drawLine(x0, y0, x1, y1, r, g, b, thickness) {
  const dx = x1 - x0, dy = y1 - y0;
  const len = Math.hypot(dx, dy);
  const nx = -dy / len, ny = dx / len; // normal
  const half = thickness / 2;
  for (let t = 0; t <= 1; t += 0.5 / len) {
    const cx = Math.round(x0 + dx * t);
    const cy = Math.round(y0 + dy * t);
    for (let d = -half - 1; d <= half + 1; d++) {
      const px = Math.round(cx + nx * d);
      const py = Math.round(cy + ny * d);
      const dist = Math.abs(d);
      const alpha = dist < half
        ? 255
        : Math.max(0, Math.round(255 * (half + 1 - dist)));
      setPixel(px, py, r, g, b, alpha);
    }
  }
}

// Draw rounded rectangle
function drawRoundRect(x, y, w, h, radius, r, g, b) {
  for (let py = y; py < y + h; py++) {
    for (let px = x; px < x + w; px++) {
      const dx = Math.max(x + radius - px, 0, px - (x + w - radius - 1));
      const dy = Math.max(y + radius - py, 0, py - (y + h - radius - 1));
      const dist = Math.hypot(dx, dy);
      if (dist <= radius) {
        const alpha = dist > radius - 1 ? Math.round(255 * (radius - dist)) : 255;
        setPixel(px, py, r, g, b, alpha);
      }
    }
  }
}

// Draw bold "V" letter
// V: two diagonal strokes meeting at bottom center
const cx = SIZE / 2;
const cy = SIZE / 2;
const thick = 100;

// Left stroke of V: top-left to bottom-center
drawLine(cx - 200, cy - 200, cx, cy + 220, ...ACC, thick);
// Right stroke of V: top-right to bottom-center
drawLine(cx + 200, cy - 200, cx, cy + 220, ...ACC, thick);

// Accent line at bottom (underline/bar)
drawRoundRect(Math.round(cx - 240), Math.round(cy + 270), 480, 28, 14, ...WHT);

// ── PNG encoding ──────────────────────────────────────────────

function crc32(buf) {
  const table = crc32.table || (crc32.table = (() => {
    const t = new Uint32Array(256);
    for (let i = 0; i < 256; i++) {
      let c = i;
      for (let j = 0; j < 8; j++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      t[i] = c;
    }
    return t;
  })());
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = table[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const typeBytes = Buffer.from(type, 'ascii');
  const dataBytes = Buffer.isBuffer(data) ? data : Buffer.from(data);
  const lenBuf = Buffer.alloc(4); lenBuf.writeUInt32BE(dataBytes.length);
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBytes, dataBytes])));
  return Buffer.concat([lenBuf, typeBytes, dataBytes, crcBuf]);
}

// IHDR
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(SIZE, 0); ihdr.writeUInt32BE(SIZE, 4);
ihdr[8] = 8;   // bit depth
ihdr[9] = 2;   // color type: RGB (no alpha in PNG, embed alpha into RGB)
ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

// For simplicity use RGBA color type = 6
ihdr[9] = 6; // RGBA

// Build raw scanline data
const scanlines = Buffer.alloc(SIZE * (1 + SIZE * 4));
for (let y = 0; y < SIZE; y++) {
  scanlines[y * (SIZE * 4 + 1)] = 0; // filter byte = None
  for (let x = 0; x < SIZE; x++) {
    const pi = (y * SIZE + x) * 4;
    const si = y * (SIZE * 4 + 1) + 1 + x * 4;
    scanlines[si]     = pixels[pi];
    scanlines[si + 1] = pixels[pi + 1];
    scanlines[si + 2] = pixels[pi + 2];
    scanlines[si + 3] = pixels[pi + 3];
  }
}

const compressed = zlib.deflateSync(scanlines, { level: 6 });
const pngSignature = Buffer.from([137,80,78,71,13,10,26,10]);
const pngData = Buffer.concat([
  pngSignature,
  chunk('IHDR', ihdr),
  chunk('IDAT', compressed),
  chunk('IEND', Buffer.alloc(0)),
]);

const outPath = path.join(__dirname, '..', 'assets', 'icon.png');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, pngData);
console.log(`Icon written to ${outPath} (${Math.round(pngData.length / 1024)} KB)`);

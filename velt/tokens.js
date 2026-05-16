// VELT Design Tokens v3 — T.rmd updated to 16px, 9 total themes

const T = {
  ink:              '#0B0F17',
  surface:          '#0B0F17',
  surfaceElevated:  '#1A2030',
  surfaceHigh:      '#252D3D',
  divider:          '#2A3142',
  textPrimary:      '#F1F5F9',
  textSecondary:    '#94A3B8',
  textTertiary:     '#64748B',
  accentIron:       '#D97706',
  accentIronSoft:   '#92400E',
  successLime:      '#84CC16',
  warningAmber:     '#F59E0B',
  errorRose:        '#E11D48',

  xxs: 4,  xs: 8,  sm: 12, md: 16,
  lg:  24, xl: 32, xxl:48, xxxl:64,

  rxs:   6,
  rsm:   10,
  rmd:   16,   // ← updated from 14 to 16
  rlg:   20,
  rxl:   28,
  rfull: 999,

  fontDisplay: "'Inter Tight', sans-serif",
  fontBody:    "'Inter', sans-serif",
};

// ─── All themes (9 total) ──────────────────────────────────
window.THEMES = {
  iron: {
    ink:'#0B0F17', surface:'#0B0F17', surfaceElevated:'#1A2030',
    surfaceHigh:'#252D3D', divider:'#2A3142',
    textPrimary:'#F1F5F9', textSecondary:'#94A3B8', textTertiary:'#64748B',
    accentIron:'#D97706', accentIronSoft:'#92400E',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  warmPaper: {
    ink:'#F5F0E8', surface:'#FAF7F2', surfaceElevated:'#FFFFFF',
    surfaceHigh:'#F0EBE3', divider:'#DDD5C8',
    textPrimary:'#1A1410', textSecondary:'#6B5B4E', textTertiary:'#9C8878',
    accentIron:'#B45309', accentIronSoft:'#FEF3C7',
    successLime:'#65A30D', warningAmber:'#D97706', errorRose:'#DC2626',
  },
  midnightSteel: {
    ink:'#050508', surface:'#0A0A0F', surfaceElevated:'#141420',
    surfaceHigh:'#1C1C2E', divider:'#252540',
    textPrimary:'#E2E4F0', textSecondary:'#8B8FAF', textTertiary:'#5A5E7A',
    accentIron:'#6366F1', accentIronSoft:'#3730A3',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  forestIron: {
    ink:'#050F07', surface:'#0D1A0F', surfaceElevated:'#162018',
    surfaceHigh:'#1E2B20', divider:'#253228',
    textPrimary:'#E4EFE6', textSecondary:'#7FA882', textTertiary:'#4E6B51',
    accentIron:'#22C55E', accentIronSoft:'#14532D',
    successLime:'#86EFAC', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  bloodOrange: {
    ink:'#0A0500', surface:'#150A00', surfaceElevated:'#1E1000',
    surfaceHigh:'#291500', divider:'#362000',
    textPrimary:'#FFF1E6', textSecondary:'#C4956B', textTertiary:'#7A5434',
    accentIron:'#EA580C', accentIronSoft:'#7C2D12',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  espresso: {
    ink:'#0F0805', surface:'#1A0F0A', surfaceElevated:'#261710',
    surfaceHigh:'#322010', divider:'#3D2A18',
    textPrimary:'#F5EEE8', textSecondary:'#B08060', textTertiary:'#7A5A3A',
    accentIron:'#C2692A', accentIronSoft:'#7C3B10',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  arctic: {
    ink:'#050A12', surface:'#0A0F18', surfaceElevated:'#111827',
    surfaceHigh:'#1A2438', divider:'#243044',
    textPrimary:'#E8F4FE', textSecondary:'#8BAFC8', textTertiary:'#4A6E8A',
    accentIron:'#38BDF8', accentIronSoft:'#0C4A6E',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  obsidian: {
    ink:'#080808', surface:'#0C0C0E', surfaceElevated:'#161618',
    surfaceHigh:'#1E1E22', divider:'#28282E',
    textPrimary:'#EEE8FF', textSecondary:'#8B82B0', textTertiary:'#5A5272',
    accentIron:'#A78BFA', accentIronSoft:'#4C1D95',
    successLime:'#84CC16', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
  military: {
    ink:'#080C05', surface:'#0F150A', surfaceElevated:'#161F0D',
    surfaceHigh:'#1E2B14', divider:'#283818',
    textPrimary:'#E8F0E0', textSecondary:'#8AA870', textTertiary:'#5A7040',
    accentIron:'#84CC16', accentIronSoft:'#3A5A0A',
    successLime:'#A3E635', warningAmber:'#F59E0B', errorRose:'#E11D48',
  },
};

window.THEME_PREVIEWS = [
  { key:'iron',          name:'Iron Dark',      bg:'#0B0F17', card:'#1A2030', accent:'#D97706' },
  { key:'warmPaper',     name:'Warm Paper',     bg:'#FAF7F2', card:'#FFFFFF', accent:'#B45309' },
  { key:'midnightSteel', name:'Midnight',       bg:'#0A0A0F', card:'#141420', accent:'#6366F1' },
  { key:'forestIron',    name:'Forest',         bg:'#0D1A0F', card:'#162018', accent:'#22C55E' },
  { key:'bloodOrange',   name:'Blood Orange',   bg:'#150A00', card:'#1E1000', accent:'#EA580C' },
  { key:'espresso',      name:'Espresso',       bg:'#1A0F0A', card:'#261710', accent:'#C2692A' },
  { key:'arctic',        name:'Arctic',         bg:'#0A0F18', card:'#111827', accent:'#38BDF8' },
  { key:'obsidian',      name:'Obsidian',       bg:'#0C0C0E', card:'#161618', accent:'#A78BFA' },
  { key:'military',      name:'Military',       bg:'#0F150A', card:'#161F0D', accent:'#84CC16' },
];

window.T = T;
const px = n => typeof n === 'number' ? `${n}px` : n;
const ROUTINE_COLORS = ['#D97706','#3B82F6','#10B981','#8B5CF6','#EC4899','#EF4444','#F59E0B','#6366F1'];
window.px = px;
window.ROUTINE_COLORS = ROUTINE_COLORS;

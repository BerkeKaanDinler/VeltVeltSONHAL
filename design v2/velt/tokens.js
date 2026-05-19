// VELT Design Tokens v5
// Mutable T object — theme switcher rewrites these in place

const T = {
  surface:          '#0F0F0F',
  surfaceElevated:  '#1A1A1A',
  surfaceHigh:      '#242424',
  divider:          '#2A2A2A',

  textPrimary:      '#FFFFFF',
  textSecondary:    '#A0A0A0',
  textTertiary:     '#555555',

  accentIron:       '#D97706',
  accentIronSoft:   '#92400E',
  accentIronTint:   'rgba(217,119,6,0.08)',
  accentIronBorder: 'rgba(217,119,6,0.3)',

  successLime:      '#22C55E',
  errorRose:        '#EF4444',
  warningAmber:     '#F59E0B',

  // chart colors (constant — don't theme)
  protein:          '#D97706',
  carbs:            '#38BDF8',
  fat:              '#22C55E',

  xxs: 4,  xs: 8,  sm: 12, md: 16,
  lg:  20, xl: 24, xxl: 32, xxxl: 48,

  screenH: 16,
  sectionGap: 22,
  bottomNavPad: 100,

  rxs:   4,  rsm: 8,  rmd: 12,
  rlg:   16, rxl: 20, rfull: 999,

  fontDisplay: "'Inter', sans-serif",
  fontBody:    "'Inter', sans-serif",
  fontMono:    "'JetBrains Mono', 'SF Mono', monospace",
};

/* ════════════════════════════════════════════════════════════
   THEMES — 2 free + 2 pro
══════════════════════════════════════════════════════════════ */
window.THEMES = {
  // ─── FREE ─────────────────────────────────────────────
  iron: {
    name: 'Iron Dark',
    tier: 'free',
    description: 'The signature VELT look. Deep black + amber heat.',
    surface:'#0F0F0F', surfaceElevated:'#1A1A1A', surfaceHigh:'#242424',
    divider:'#2A2A2A',
    textPrimary:'#FFFFFF', textSecondary:'#A0A0A0', textTertiary:'#555555',
    accentIron:'#D97706', accentIronSoft:'#92400E',
    successLime:'#22C55E', errorRose:'#EF4444', warningAmber:'#F59E0B',
  },
  slate: {
    name: 'Slate Mono',
    tier: 'free',
    description: 'Cool industrial grayscale. Minimal, focused.',
    surface:'#0A0E1A', surfaceElevated:'#141927', surfaceHigh:'#1E2434',
    divider:'#252B3D',
    textPrimary:'#F1F5F9', textSecondary:'#94A3B8', textTertiary:'#475569',
    accentIron:'#94A3B8', accentIronSoft:'#475569',
    successLime:'#22C55E', errorRose:'#EF4444', warningAmber:'#F59E0B',
  },

  // ─── PRO ──────────────────────────────────────────────
  roseGold: {
    name: 'Rose Gold',
    tier: 'pro',
    description: 'Warm noir with rose gold accents.',
    surface:'#100A0E', surfaceElevated:'#1B131A', surfaceHigh:'#241B22',
    divider:'#2D2128',
    textPrimary:'#FBEEF2', textSecondary:'#B89BA8', textTertiary:'#6B5662',
    accentIron:'#F472B6', accentIronSoft:'#9D174D',
    successLime:'#22C55E', errorRose:'#EF4444', warningAmber:'#F59E0B',
  },
  emerald: {
    name: 'Emerald Premium',
    tier: 'pro',
    description: 'Deep forest with emerald highlights.',
    surface:'#0A1410', surfaceElevated:'#0F1F18', surfaceHigh:'#162B22',
    divider:'#1F352A',
    textPrimary:'#E8F5EE', textSecondary:'#7BAB94', textTertiary:'#3F5D4F',
    accentIron:'#10B981', accentIronSoft:'#065F46',
    successLime:'#84CC16', errorRose:'#EF4444', warningAmber:'#F59E0B',
  },
};

window.THEME_KEYS = ['iron','slate','roseGold','emerald'];

/* ════════════════════════════════════════════════════════════
   ROUTINE / GOAL / LEVEL COLORS
══════════════════════════════════════════════════════════════ */
const ROUTINE_COLORS = {
  amber:  '#D97706', blue:'#3B82F6', green:'#22C55E', purple:'#A855F7',
  pink:   '#EC4899', cyan:'#06B6D4', rose: '#F43F5E', indigo:'#6366F1',
};
const GOAL_COLORS = {
  muscle:'#D97706', fat:'#22C55E',
  strength:'#6366F1', endurance:'#06B6D4',
};
const LEVEL_COLORS = {
  Beginner:     { fg:'#22C55E', bg:'rgba(34,197,94,0.12)' },
  Intermediate: { fg:'#D97706', bg:'rgba(217,119,6,0.12)' },
  Advanced:     { fg:'#EF4444', bg:'rgba(239,68,68,0.12)' },
};

window.T = T;
window.ROUTINE_COLORS = ROUTINE_COLORS;
window.GOAL_COLORS = GOAL_COLORS;
window.LEVEL_COLORS = LEVEL_COLORS;

window.alpha = (hex, a) => {
  if (!hex || hex[0] !== '#') return hex;
  const h = hex.replace('#','');
  const r = parseInt(h.slice(0,2),16);
  const g = parseInt(h.slice(2,4),16);
  const b = parseInt(h.slice(4,6),16);
  return `rgba(${r},${g},${b},${a})`;
};

window.px = n => typeof n === 'number' ? `${n}px` : n;

// Theme application — mutates window.T so all components re-render with new colors
window.applyTheme = (key) => {
  const theme = window.THEMES[key];
  if (!theme) return;
  Object.assign(window.T, {
    surface: theme.surface,
    surfaceElevated: theme.surfaceElevated,
    surfaceHigh: theme.surfaceHigh,
    divider: theme.divider,
    textPrimary: theme.textPrimary,
    textSecondary: theme.textSecondary,
    textTertiary: theme.textTertiary,
    accentIron: theme.accentIron,
    accentIronSoft: theme.accentIronSoft,
    accentIronTint: window.alpha(theme.accentIron, 0.08),
    accentIronBorder: window.alpha(theme.accentIron, 0.3),
    successLime: theme.successLime,
    errorRose: theme.errorRose,
    warningAmber: theme.warningAmber,
  });
};

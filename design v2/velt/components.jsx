// VELT Shared Components v3 — Premium Dark Android Design System

const { useState, useEffect, useRef } = React;

/* ════════════════════════════════════════════════════════════
   BUTTONS
══════════════════════════════════════════════════════════════ */
function PrimaryButton({ label, onPress, disabled, loading, icon, size='lg', style }) {
  const [pressed, setPressed] = useState(false);
  const h = size === 'sm' ? 38 : size === 'md' ? 44 : 52;
  const fs = size === 'sm' ? 12 : size === 'md' ? 13 : 14;
  return (
    <button
      onPointerDown={() => !disabled && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={!disabled && !loading ? onPress : undefined}
      style={{
        height: h, width: '100%', borderRadius: T.rsm,
        background: disabled ? T.surfaceHigh : T.accentIron,
        border: 'none',
        color: disabled ? T.textTertiary : '#FFF',
        fontFamily: T.fontBody, fontSize: fs, fontWeight: 700,
        letterSpacing: '0.01em', cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: pressed ? 0.88 : 1,
        transform: pressed ? 'scale(0.98)' : 'scale(1)',
        transition:'opacity 120ms, transform 120ms',
        display:'flex', alignItems:'center', justifyContent:'center',
        gap: 6, ...style
      }}
    >
      {loading
        ? <Spinner color="#fff" />
        : <>{icon}{label}</>}
    </button>
  );
}

function GhostButton({ label, onPress, icon, size='md', style, danger }) {
  const [pressed, setPressed] = useState(false);
  const h = size === 'sm' ? 32 : size === 'md' ? 38 : 44;
  return (
    <button
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={onPress}
      style={{
        height: h, borderRadius: T.rsm,
        border: `1px solid ${danger ? T.errorRose : T.divider}`,
        background: pressed ? T.surfaceHigh : 'transparent',
        color: danger ? T.errorRose : T.textSecondary,
        fontFamily: T.fontBody, fontSize: 12, fontWeight: 600,
        cursor:'pointer', display:'flex', alignItems:'center',
        justifyContent:'center', gap: 6, padding: '0 14px',
        transition:'background 120ms', ...style
      }}
    >
      {icon}{label}
    </button>
  );
}

function AmberLink({ label, onPress, style }) {
  return (
    <button onClick={onPress} style={{
      background:'none', border:'none', color: T.accentIron,
      fontFamily: T.fontBody, fontSize: 12, fontWeight: 600,
      cursor:'pointer', padding: 0, ...style,
    }}>{label}</button>
  );
}

function Spinner({ color='#fff', size=16 }) {
  return <span style={{
    width: size, height: size,
    border: `2px solid ${color}33`,
    borderTopColor: color,
    borderRadius:'50%',
    animation:'spin 0.7s linear infinite',
    display:'inline-block',
  }} />;
}

/* ════════════════════════════════════════════════════════════
   SECTION HEADER
══════════════════════════════════════════════════════════════ */
function SectionLabel({ children, style }) {
  return (
    <div style={{
      fontFamily: T.fontBody, fontSize: 10, fontWeight: 600,
      color: T.textTertiary, letterSpacing: '0.12em',
      textTransform: 'uppercase', ...style
    }}>{children}</div>
  );
}

function SectionHeader({ label, action, onAction, style }) {
  return (
    <div style={{
      display:'flex', justifyContent:'space-between', alignItems:'center',
      marginBottom: 10, ...style,
    }}>
      <SectionLabel>{label}</SectionLabel>
      {action && (
        <button onClick={onAction} style={{
          background:'none', border:'none', fontSize: 11,
          color: T.accentIron, fontFamily: T.fontBody,
          fontWeight: 600, cursor:'pointer', padding: 0,
          letterSpacing: '0.02em',
        }}>{action}</button>
      )}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   CARD
══════════════════════════════════════════════════════════════ */
function Card({ children, style, active, onPress, padding=16 }) {
  const [pressed, setPressed] = useState(false);
  const interactive = !!onPress;
  return (
    <div
      onPointerDown={() => interactive && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={onPress}
      style={{
        background: pressed ? T.surfaceHigh : T.surfaceElevated,
        border: active
          ? `1px solid ${T.accentIron}`
          : `0.5px solid ${T.divider}`,
        borderRadius: T.rmd,
        padding: padding,
        cursor: interactive ? 'pointer' : 'default',
        transition:'background 120ms, border-color 200ms',
        ...style,
      }}
    >{children}</div>
  );
}

/* ════════════════════════════════════════════════════════════
   PILLS / CHIPS
══════════════════════════════════════════════════════════════ */
function Pill({ children, color, bg, style }) {
  return (
    <span style={{
      fontFamily: T.fontBody, fontSize: 10, fontWeight: 600,
      color: color || T.textSecondary,
      background: bg || T.surfaceHigh,
      padding: '3px 8px',
      borderRadius: T.rfull,
      letterSpacing: '0.03em',
      whiteSpace:'nowrap',
      ...style
    }}>{children}</span>
  );
}

function FilterChip({ label, active, onPress, style }) {
  return (
    <button onClick={onPress} style={{
      padding: '7px 14px',
      borderRadius: T.rfull,
      border: active ? 'none' : `1px solid ${T.divider}`,
      background: active ? T.accentIron : 'transparent',
      color: active ? '#FFF' : T.textSecondary,
      fontFamily: T.fontBody, fontSize: 12,
      fontWeight: active ? 700 : 600,
      cursor:'pointer', whiteSpace:'nowrap', flexShrink: 0,
      transition:'background 150ms, color 150ms',
      ...style
    }}>{label}</button>
  );
}

/* ════════════════════════════════════════════════════════════
   TOGGLE
══════════════════════════════════════════════════════════════ */
function Toggle({ value, onChange }) {
  return (
    <div onClick={() => onChange(!value)} style={{
      width: 40, height: 22, borderRadius: T.rfull,
      background: value ? T.accentIron : T.surfaceHigh,
      position:'relative', cursor:'pointer', flexShrink: 0,
      transition:'background 200ms',
    }}>
      <div style={{
        position:'absolute', top: 3,
        left: value ? 21 : 3,
        width: 16, height: 16, borderRadius:'50%',
        background: '#FFF',
        transition:'left 200ms cubic-bezier(0.2,0,0.2,1)',
        boxShadow:'0 1px 2px rgba(0,0,0,0.4)',
      }} />
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   ICONS (24×24)
══════════════════════════════════════════════════════════════ */
const Icon = {
  Home:    ({ c, fill }) => fill
    ? <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M3 10L12 3L21 10V20C21 20.55 20.55 21 20 21H15V14H9V21H4C3.45 21 3 20.55 3 20V10Z" fill={c}/></svg>
    : <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><path d="M3 10L12 3L21 10V20C21 20.55 20.55 21 20 21H15V14H9V21H4C3.45 21 3 20.55 3 20V10Z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/></svg>,
  Dumbbell: ({ c, fill }) => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <line x1="9" y1="12" x2="15" y2="12" stroke={c} strokeWidth="2.4" strokeLinecap="round"/>
      <rect x="5.5" y="9" width="3.5" height="6" rx="1" stroke={c} strokeWidth="1.6" fill={fill ? c+'33' : 'none'}/>
      <rect x="15" y="9" width="3.5" height="6" rx="1" stroke={c} strokeWidth="1.6" fill={fill ? c+'33' : 'none'}/>
      <rect x="2" y="7.5" width="3" height="9" rx="1.2" stroke={c} strokeWidth="1.6" fill={fill ? c : 'none'}/>
      <rect x="19" y="7.5" width="3" height="9" rx="1.2" stroke={c} strokeWidth="1.6" fill={fill ? c : 'none'}/>
    </svg>
  ),
  Fork: ({ c, fill }) => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M7 3v6 M5 3v3 M9 3v3 M5 6c0 1.5 1 2.5 2 2.5s2-1 2-2.5 M7 9v12" stroke={c} strokeWidth={fill?2.2:1.7} strokeLinecap="round" fill="none"/>
      <path d="M16 3c0 0 2 2.5 2 5.5s-1.5 4-2 4v9" stroke={c} strokeWidth={fill?2.2:1.7} strokeLinecap="round" strokeLinejoin="round" fill="none"/>
    </svg>
  ),
  Chart: ({ c, fill }) => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <polyline points="3 17 8 11 12 14 17 7 21 4" stroke={c} strokeWidth={fill?2.2:1.7} strokeLinecap="round" strokeLinejoin="round"/>
      {fill && <circle cx="21" cy="4" r="2" fill={c}/>}
    </svg>
  ),
  Person: ({ c, fill }) => fill
    ? <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" fill={c}/><path d="M4 20c0-4 3.58-7 8-7s8 3 8 7" fill={c}/></svg>
    : <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="8" r="4" stroke={c} strokeWidth="1.6"/><path d="M4 20c0-4 3.58-7 8-7s8 3 8 7" stroke={c} strokeWidth="1.6" strokeLinecap="round"/></svg>,
  Flame: ({ c='#D97706' }) => (
    <svg width="14" height="16" viewBox="0 0 14 16" fill="none">
      <path d="M7 1C7 1 10.5 4.5 10.5 8C10.5 9.38 9.88 10.5 9 11C9.5 9.5 8.5 8.5 7.5 8C7.5 9 7 10 6 10.5C6 8.5 4.5 7 4.5 5C4.5 5 2 7 2 9.5C2 12.54 4.24 15 7 15C9.76 15 12 12.54 12 9.5C12 5.5 7 1 7 1Z" fill={c}/>
    </svg>
  ),
  Trophy: ({ c, size=14 }) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M7 4h10v4a5 5 0 01-10 0V4z" stroke={c} strokeWidth="1.6"/>
      <path d="M7 6H4v2a3 3 0 003 3M17 6h3v2a3 3 0 01-3 3" stroke={c} strokeWidth="1.6"/>
      <path d="M9 19h6M12 13v6" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  Check: ({ c='#fff', size=14, sw=2.2 }) => (
    <svg width={size} height={size*0.78} viewBox="0 0 14 11" fill="none">
      <path d="M1 5.5L5 9.5L13 1.5" stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  Chevron: ({ c, size=14 }) => (
    <svg width={size/2} height={size} viewBox="0 0 7 14" fill="none">
      <path d="M1 1L6 7L1 13" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
    </svg>
  ),
  ArrowLeft: ({ c, size=20 }) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <path d="M15 18L9 12L15 6" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  Play: ({ c='#fff', size=12 }) => (
    <svg width={size} height={size} viewBox="0 0 12 12" fill={c}>
      <path d="M3 2L10 6L3 10V2Z"/>
    </svg>
  ),
  Plus: ({ c, size=14 }) => (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none">
      <path d="M7 1V13M1 7H13" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  Lock: ({ c, size=20 }) => (
    <svg width={size} height={size*1.1} viewBox="0 0 20 22" fill="none">
      <rect x="2" y="9" width="16" height="13" rx="2" stroke={c} strokeWidth="1.8"/>
      <path d="M6 9V6a4 4 0 0 1 8 0v3" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
      <circle cx="10" cy="15" r="1.5" fill={c}/>
    </svg>
  ),
  Bolt: ({ c, size=16 }) => (
    <svg width={size} height={size} viewBox="0 0 16 16" fill={c}>
      <path d="M9 1L3 9H7L6 15L13 7H9L9 1Z"/>
    </svg>
  ),
  Bulb: ({ c, size=16 }) => (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none">
      <path d="M5 13h6M6 15h4M8 1a5 5 0 015 5c0 2.5-2 3.5-2 5H5c0-1.5-2-2.5-2-5a5 5 0 015-5z" stroke={c} strokeWidth="1.4" strokeLinecap="round"/>
    </svg>
  ),
  Star: ({ c, size=12 }) => (
    <svg width={size} height={size} viewBox="0 0 12 12" fill={c}>
      <path d="M6 1L7.5 4.5L11 5L8.5 7.5L9 11L6 9.5L3 11L3.5 7.5L1 5L4.5 4.5L6 1Z"/>
    </svg>
  ),
  Timer: ({ c, size=14 }) => (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none">
      <circle cx="7" cy="8" r="5" stroke={c} strokeWidth="1.4"/>
      <path d="M7 5.5V8L9 9.5M5 1H9" stroke={c} strokeWidth="1.4" strokeLinecap="round"/>
    </svg>
  ),
  Scale: ({ c, size=22 }) => (
    <svg width={size} height={size} viewBox="0 0 22 22" fill="none">
      <rect x="2" y="6" width="18" height="12" rx="2" stroke={c} strokeWidth="1.6"/>
      <path d="M7 12 L9 14 L15 8" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
      <line x1="11" y1="6" x2="11" y2="4" stroke={c} strokeWidth="1.6"/>
    </svg>
  ),
  Settings: ({ c, fill, size=22 }) => fill
    ? <svg width={size} height={size} viewBox="0 0 24 24" fill={c}><circle cx="12" cy="12" r="3"/><path d="M12 1l1.5 3.5L17 3l-.5 3.8L20 8l-1.8 3.3L22 14l-3.5 1.5L20 19l-3.8-.5L15 22l-3.3-1.8L8 24l-1.5-3.5L3 22l.5-3.8L0 17l1.8-3.3L-2 11l3.5-1.5L0 6l3.8.5L5 3l3.3 1.8z"/></svg>
    : <svg width={size} height={size} viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="3" stroke={c} strokeWidth="1.6"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09A1.65 1.65 0 004.6 9 1.65 1.65 0 004.27 7.18l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  Drag: ({ c }) => (
    <svg width="16" height="16" viewBox="0 0 16 16" fill={c}>
      <circle cx="6" cy="4" r="1"/><circle cx="10" cy="4" r="1"/>
      <circle cx="6" cy="8" r="1"/><circle cx="10" cy="8" r="1"/>
      <circle cx="6" cy="12" r="1"/><circle cx="10" cy="12" r="1"/>
    </svg>
  ),
  Note: ({ c, size=14 }) => (
    <svg width={size} height={size} viewBox="0 0 14 14" fill="none">
      <rect x="2" y="2" width="10" height="10" rx="1.5" stroke={c} strokeWidth="1.3"/>
      <path d="M4.5 5.5h5M4.5 8h3" stroke={c} strokeWidth="1.3" strokeLinecap="round"/>
    </svg>
  ),
  Trend: ({ c, up, size=12 }) => (
    <svg width={size} height={size} viewBox="0 0 12 12" fill="none">
      <path d={up ? "M2 9L6 5L10 7L10 3M7 3H10" : "M2 3L6 7L10 5L10 9M7 9H10"}
        stroke={c} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
};

/* ════════════════════════════════════════════════════════════
   BOTTOM NAV
══════════════════════════════════════════════════════════════ */
function BottomNav({ active, onNavigate }) {
  const tabs = [
    { id:'home',      icon: Icon.Home,      label:'Home' },
    { id:'train',     icon: Icon.Dumbbell,  label:'Train' },
    { id:'nutrition', icon: Icon.Fork,      label:'Food' },
    { id:'progress',  icon: Icon.Chart,     label:'Progress' },
    { id:'settings',  icon: Icon.Person,    label:'Profile' },
  ];
  return (
    <div style={{
      display:'flex', alignItems:'center',
      height: 64, flexShrink: 0,
      background: T.surface,
      borderTop:`0.5px solid ${T.divider}`,
      paddingBottom: 4,
    }}>
      {tabs.map(tab => {
        const isActive = active === tab.id;
        const Ico = tab.icon;
        return (
          <button key={tab.id} onClick={() => onNavigate(tab.id)} style={{
            display:'flex', flexDirection:'column', alignItems:'center',
            justifyContent:'center', gap: 3,
            background:'none', border:'none', cursor:'pointer',
            flex: 1, height:'100%', padding: 0,
            position:'relative',
          }}>
            <Ico c={isActive ? T.accentIron : T.textTertiary} fill={isActive} />
            <span style={{
              fontFamily: T.fontBody, fontSize: 9, fontWeight: isActive?700:500,
              color: isActive ? T.accentIron : T.textTertiary,
              letterSpacing: '0.02em',
            }}>{tab.label}</span>
          </button>
        );
      })}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   BOTTOM SHEET
══════════════════════════════════════════════════════════════ */
function BottomSheet({ open, onClose, title, children, height='auto' }) {
  if (!open) return null;
  return (
    <div style={{
      position:'absolute', inset: 0, zIndex: 100,
      display:'flex', flexDirection:'column', justifyContent:'flex-end',
      background:'rgba(0,0,0,0.55)',
      animation:'fadeIn 200ms ease-out',
    }} onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{
        background: T.surfaceElevated,
        borderRadius: `${T.rxl}px ${T.rxl}px 0 0`,
        maxHeight: height === 'full' ? '92%' : '88%',
        display:'flex', flexDirection:'column',
        animation:'slideUp 280ms cubic-bezier(0.2,0,0,1)',
        borderTop:`0.5px solid ${T.divider}`,
      }}>
        {/* handle */}
        <div style={{ padding: '10px 0 0', display:'flex', justifyContent:'center' }}>
          <div style={{ width: 36, height: 4, borderRadius: T.rfull,
            background: T.surfaceHigh }} />
        </div>
        {title && (
          <div style={{ padding: `12px ${T.md}px 8px`,
            display:'flex', alignItems:'center', justifyContent:'space-between' }}>
            <div style={{ fontFamily: T.fontBody, fontSize: 16,
              fontWeight: 700, color: T.textPrimary }}>{title}</div>
            <button onClick={onClose} style={{ background:'none', border:'none',
              color: T.textSecondary, fontSize: 22, cursor:'pointer',
              padding: 0, lineHeight: 1, fontWeight: 300,
            }}>×</button>
          </div>
        )}
        <div style={{ flex: 1, overflowY:'auto', overflowX:'hidden' }}>
          {children}
        </div>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   PROGRESS BAR (slim top)
══════════════════════════════════════════════════════════════ */
function ProgressBar({ pct, color, height=3 }) {
  return (
    <div style={{ height, background: T.divider, width:'100%' }}>
      <div style={{
        height:'100%', width: `${Math.min(pct,100)}%`,
        background: color || T.accentIron,
        transition: 'width 400ms ease-out',
      }} />
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   STAT BOX (3-up rows)
══════════════════════════════════════════════════════════════ */
function StatBox({ icon, value, label, accent }) {
  return (
    <div style={{
      flex: 1,
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rmd, padding: 12,
    }}>
      <div style={{ marginBottom: 6, height: 14 }}>{icon}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 22, fontWeight: 700,
        color: accent ? T.accentIron : T.textPrimary,
        letterSpacing: '-0.02em', fontVariantNumeric:'tabular-nums',
        lineHeight: 1 }}>{value}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 500,
        color: T.textSecondary, marginTop: 4 }}>{label}</div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   SAFE TOP AREA
══════════════════════════════════════════════════════════════ */
const SAFE_TOP = 56;
function SafeArea() {
  return <div style={{ height: SAFE_TOP, flexShrink: 0,
    background: T.surface }} />;
}

/* ════════════════════════════════════════════════════════════
   SCREEN HEADER (large display title)
══════════════════════════════════════════════════════════════ */
function ScreenHeader({ title, right, subtitle }) {
  return (
    <div style={{
      padding: `${T.lg}px ${T.screenH}px ${T.md}px`,
      display:'flex', justifyContent:'space-between',
      alignItems:'flex-end', gap: T.sm,
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 34, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.04em',
          lineHeight: 1 }}>{title}</div>
        {subtitle && (
          <div style={{ fontFamily: T.fontBody, fontSize: 13,
            color: T.textTertiary, marginTop: 4 }}>{subtitle}</div>
        )}
      </div>
      {right}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   EMPTY STATE
══════════════════════════════════════════════════════════════ */
function EmptyState({ icon, title, subtitle, cta, onCta, secondaryCta, onSecondaryCta }) {
  return (
    <Card style={{ padding: 28, textAlign:'center' }}>
      <div style={{ display:'flex', justifyContent:'center', marginBottom: 12,
        opacity: 0.5 }}>{icon}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
        color: T.textPrimary, marginBottom: 4 }}>{title}</div>
      {subtitle && (
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: T.textSecondary, marginBottom: 16, lineHeight: 1.5 }}>{subtitle}</div>
      )}
      <div style={{ display:'flex', gap: 8, justifyContent:'center' }}>
        {cta && <PrimaryButton label={cta} onPress={onCta} size="md" style={{ width:'auto', padding:'0 18px' }} />}
        {secondaryCta && <GhostButton label={secondaryCta} onPress={onSecondaryCta} />}
      </div>
    </Card>
  );
}

/* ════════════════════════════════════════════════════════════
   EXPORT GLOBALS
══════════════════════════════════════════════════════════════ */
Object.assign(window, {
  PrimaryButton, GhostButton, AmberLink, Spinner,
  SectionLabel, SectionHeader,
  Card, Pill, FilterChip, Toggle,
  Icon, BottomNav, BottomSheet,
  ProgressBar, StatBox,
  SafeArea, ScreenHeader, EmptyState,
  SAFE_TOP,
});

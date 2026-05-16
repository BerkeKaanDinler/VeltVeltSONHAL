// VELT Shared Components v2
// Changes: BottomNav 4-tab icons-only, stepBtn dynamic, SectionHeader typography,
//          updated nav icons (dumbbell, chart uptrend, person)

const { useState, useEffect, useRef } = React;

/* ─── PrimaryButton ─────────────────────────────────────── */
function PrimaryButton({ label, onPress, disabled, loading, style }) {
  const [pressed, setPressed] = useState(false);
  return (
    <button
      onPointerDown={() => !disabled && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={!disabled && !loading ? onPress : undefined}
      style={{
        height:56, width:'100%', borderRadius: T.rmd,
        background: disabled ? `${T.accentIron}55` : T.accentIron,
        border:'none', color:'#fff',
        fontFamily: T.fontBody, fontSize:15, fontWeight:600,
        letterSpacing:'0.01em', cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: pressed ? 0.92 : 1,
        transform: pressed ? 'scale(0.99)' : 'scale(1)',
        transition:'opacity 120ms, transform 120ms',
        boxShadow: disabled ? 'none' : `0 0 20px rgba(217,119,6,0.25)`,
        display:'flex', alignItems:'center', justifyContent:'center',
        gap:8, ...style
      }}
    >
      {loading
        ? <span style={{ width:18, height:18, border:`2px solid #fff4`,
            borderTopColor:'#fff', borderRadius:'50%',
            animation:'spin 0.7s linear infinite', display:'inline-block' }} />
        : label}
    </button>
  );
}

/* ─── GhostButton ───────────────────────────────────────── */
function GhostButton({ label, onPress, style, icon }) {
  return (
    <button onClick={onPress} style={{
      height:48, borderRadius: T.rmd, border:`1px solid ${T.divider}`,
      background:'transparent', color: T.textSecondary,
      fontFamily: T.fontBody, fontSize:14, fontWeight:500,
      cursor:'pointer', display:'flex', alignItems:'center',
      justifyContent:'center', gap:6, padding:'0 20px', ...style
    }}>
      {icon && <span style={{fontSize:16}}>{icon}</span>}
      {label}
    </button>
  );
}

/* ─── TextBtn ────────────────────────────────────────────── */
function TextBtn({ label, onPress, style }) {
  return (
    <button onClick={onPress} style={{
      background:'none', border:'none', color: T.textTertiary,
      fontFamily: T.fontBody, fontSize:13, fontWeight:500,
      cursor:'pointer', padding:'8px 0', ...style
    }}>{label}</button>
  );
}

/* ─── SetRow ─────────────────────────────────────────────── */
function SetRow({ set, setIndex, onComplete, active }) {
  const [weight, setWeight] = useState(set.weight || 0);
  const [reps, setReps]     = useState(set.reps || 0);
  const [done, setDone]     = useState(set.done || false);

  const badgeColor = { W: T.accentIron, D: T.textTertiary, F: T.errorRose }[set.type] || null;
  const badgeBg    = { W: '#1A0F00', D: `${T.textTertiary}22`, F: `${T.errorRose}22` }[set.type] || null;
  const badgeLabel = set.type && set.type !== 'N' ? set.type : null;

  function toggle() {
    const next = !done;
    setDone(next);
    onComplete && onComplete(setIndex, next, weight, reps);
  }

  const rowBg   = active ? T.surfaceElevated : 'transparent';
  const textCol = done ? T.successLime : T.textPrimary;

  // Dynamic step button style (uses T at render time → theme-responsive)
  const sBtn = {
    width:32, height:32, borderRadius: T.rsm, border:'none',
    background: T.surfaceHigh, cursor:'pointer',
    display:'flex', alignItems:'center', justifyContent:'center',
  };

  return (
    <div style={{
      display:'grid', gridTemplateColumns:'32px 1fr 1fr 1fr 48px',
      alignItems:'center', gap: T.xs, padding:`10px ${T.md}px`,
      background: rowBg,
      borderLeft: active ? `3px solid ${T.accentIron}` : '3px solid transparent',
      borderBottom:`1px solid ${T.divider}44`,
      transition:'background 200ms, opacity 200ms',
      opacity: done ? 0.55 : 1,
    }}>
      {/* Set number / badge */}
      <div style={{ textAlign:'center' }}>
        {badgeLabel
          ? <span style={{ fontSize:11, fontWeight:700, color: badgeColor,
              background: badgeBg || `${badgeColor}22`, padding:'2px 5px',
              borderRadius:8 }}>{badgeLabel}</span>
          : <span style={{ fontSize:14, fontWeight:600, color: T.textTertiary,
              fontFamily: T.fontBody }}>{setIndex + 1}</span>
        }
      </div>
      {/* Prev */}
      <div style={{ textAlign:'center', fontSize:12, color: T.textTertiary,
        fontFamily: T.fontBody }}>
        {set.prev ? `${set.prev.weight}×${set.prev.reps}` : '—'}
      </div>
      {/* Weight */}
      <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:4 }}>
        <button onClick={() => setWeight(w => Math.max(0, parseFloat((w-2.5).toFixed(1))))}
          style={sBtn}><span style={{fontSize:16, color: T.textSecondary}}>−</span></button>
        <span style={{ fontSize:15, fontWeight:700, color: textCol,
          fontFamily: T.fontBody, minWidth:40, textAlign:'center',
          fontVariantNumeric:'tabular-nums' }}>{weight}</span>
        <button onClick={() => setWeight(w => parseFloat((w+2.5).toFixed(1)))}
          style={sBtn}><span style={{fontSize:16, color: T.textSecondary}}>+</span></button>
      </div>
      {/* Reps */}
      <div style={{ display:'flex', alignItems:'center', justifyContent:'center', gap:4 }}>
        <button onClick={() => setReps(r => Math.max(0, r-1))}
          style={sBtn}><span style={{fontSize:16, color: T.textSecondary}}>−</span></button>
        <span style={{ fontSize:15, fontWeight:700, color: textCol,
          fontFamily: T.fontBody, minWidth:28, textAlign:'center',
          fontVariantNumeric:'tabular-nums' }}>{reps}</span>
        <button onClick={() => setReps(r => r+1)}
          style={sBtn}><span style={{fontSize:16, color: T.textSecondary}}>+</span></button>
      </div>
      {/* Checkbox */}
      <div onClick={toggle} style={{
        width:44, height:44, display:'flex', alignItems:'center',
        justifyContent:'center', cursor:'pointer', borderRadius: T.rfull,
      }}>
        <div style={{
          width:26, height:26, borderRadius: T.rfull,
          border: done ? 'none' : `2px solid ${T.divider}`,
          background: done ? T.successLime : 'transparent',
          display:'flex', alignItems:'center', justifyContent:'center',
          transition:'all 200ms',
        }}>
          {done && (
            <svg width="14" height="11" viewBox="0 0 14 11" fill="none">
              <path d="M1 5.5L5 9.5L13 1.5" stroke="#0B0F17"
                strokeWidth="2.2" strokeLinecap="round"/>
            </svg>
          )}
        </div>
      </div>
    </div>
  );
}

/* ─── RoutineCard ────────────────────────────────────────── */
function RoutineCard({ routine, onPress }) {
  const [pressed, setPressed] = useState(false);
  return (
    <div
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={onPress}
      style={{
        background: pressed ? T.surfaceHigh : T.surfaceElevated,
        borderRadius: T.rmd, padding:`0 20px`,
        display:'flex', alignItems:'center', gap: T.md,
        height:72, cursor:'pointer',
        transition:'background 120ms',
        overflow:'hidden', position:'relative',
      }}
    >
      {/* 4pt color bar */}
      <div style={{ position:'absolute', left:0, top:0, bottom:0, width:4,
        background: routine.color || T.accentIron }} />
      <div style={{ flex:1, paddingLeft:8 }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:15, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.01em' }}>{routine.name}</div>
        <div style={{ fontFamily: T.fontBody, fontSize:12,
          color: T.textSecondary, marginTop:2 }}>
          {routine.exerciseCount} exercises · {routine.lastDone}
        </div>
      </div>
      <svg width="7" height="12" viewBox="0 0 7 12" fill="none">
        <path d="M1 1L6 6L1 11" stroke={T.textTertiary}
          strokeWidth="1.5" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

/* ─── MethodCard ─────────────────────────────────────────── */
function MethodCard({ method, onPress }) {
  return (
    <div onClick={onPress} style={{
      background: T.surfaceElevated, borderRadius: T.rmd,
      padding:`${T.sm}px 20px`, cursor:'pointer',
      display:'flex', alignItems:'center', gap: T.sm,
    }}>
      <div style={{ width:9, height:9, borderRadius: T.rfull,
        background: method.categoryColor || T.accentIron, flexShrink:0 }} />
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:14, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.01em' }}>{method.name}</div>
        <div style={{ fontFamily: T.fontBody, fontSize:11,
          color: T.textSecondary, marginTop:1,
          whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>
          {method.tagline}
        </div>
      </div>
      <div style={{ display:'flex', gap:4, flexShrink:0 }}>
        <span style={pillStyle(T.surfaceHigh)}>{method.difficulty}</span>
        <span style={pillStyle(T.surfaceHigh)}>{method.frequency}</span>
      </div>
    </div>
  );
}

function pillStyle(bg, color) {
  return {
    fontFamily: T.fontBody, fontSize:10, fontWeight:600,
    color: color || T.textTertiary, background: bg,
    padding:'3px 7px', borderRadius: T.rfull, letterSpacing:'0.03em',
  };
}

/* ─── SectionHeader ──────────────────────────────────────── */
function SectionHeader({ label, action, onAction }) {
  return (
    <div style={{ display:'flex', justifyContent:'space-between',
      alignItems:'center', padding:`0 ${T.md}px`, marginBottom:10 }}>
      <span style={{ fontFamily: T.fontBody, fontSize:11, fontWeight:600,
        color: T.textSecondary, letterSpacing:'0.08em',
        textTransform:'uppercase' }}>
        {label}
      </span>
      {action && (
        <button onClick={onAction} style={{
          background:'none', border:'none', fontSize:12,
          color: T.accentIron, fontFamily: T.fontBody,
          fontWeight:600, cursor:'pointer', padding:0,
        }}>{action} →</button>
      )}
    </div>
  );
}

/* ─── StatCard ───────────────────────────────────────────── */
function StatCard({ value, unit, label, accent }) {
  return (
    <div style={{
      background: T.surfaceElevated, borderRadius: T.rmd,
      padding:`${T.md}px ${T.sm}px`, minWidth:86, textAlign:'center', flex:1,
    }}>
      <div style={{ display:'flex', alignItems:'baseline',
        justifyContent:'center', gap:3 }}>
        <span style={{ fontFamily: T.fontDisplay, fontSize:28, fontWeight:700,
          color: accent ? T.accentIron : T.textPrimary,
          fontVariantNumeric:'tabular-nums',
          letterSpacing:'-0.02em' }}>{value}</span>
        {unit && <span style={{ fontFamily: T.fontBody, fontSize:11,
          fontWeight:400, color: T.textSecondary }}>{unit}</span>}
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:500,
        color: T.textTertiary, marginTop:2, letterSpacing:'0.04em',
        textTransform:'uppercase' }}>{label}</div>
    </div>
  );
}

/* ─── RestTimerBanner ────────────────────────────────────── */
function RestTimerBanner({ seconds, onSkip, onAdd }) {
  const [remaining, setRemaining] = useState(seconds);
  const urgent = remaining <= 30;

  useEffect(() => {
    if (remaining <= 0) return;
    const t = setTimeout(() => setRemaining(r => r-1), 1000);
    return () => clearTimeout(t);
  }, [remaining]);

  useEffect(() => { setRemaining(seconds); }, [seconds]);

  const mins = String(Math.floor(remaining/60)).padStart(2,'0');
  const secs = String(remaining%60).padStart(2,'0');

  return (
    <div style={{
      background: '#1A0F00',
      border: `1px solid ${T.accentIron}`,
      padding:`${T.sm}px ${T.md}px`,
      display:'flex', alignItems:'center', justifyContent:'space-between',
      animation:'slideDown 200ms ease-out',
    }}>
      <button onClick={onSkip} style={{ background:'none', border:'none',
        color: T.textTertiary, fontSize:13, fontWeight:600,
        fontFamily: T.fontBody, cursor:'pointer', minWidth:44 }}>Skip</button>
      <div style={{ textAlign:'center' }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:32, fontWeight:700,
          color: T.accentIron,
          fontVariantNumeric:'tabular-nums', letterSpacing:'-0.03em',
          lineHeight:1 }}>{mins}:{secs}</div>
        <div style={{ fontFamily: T.fontBody, fontSize:10,
          color: T.textTertiary, fontWeight:600,
          textTransform:'uppercase', letterSpacing:'0.08em',
          marginTop:3 }}>Rest</div>
      </div>
      <button onClick={onAdd} style={{
        border:`1px solid ${T.divider}`, borderRadius: T.rfull,
        background: '#1A2030', color: T.textSecondary,
        fontFamily: T.fontBody, fontSize:12, fontWeight:600,
        cursor:'pointer', padding:'5px 12px', minWidth:44,
      }}>+15s</button>
    </div>
  );
}

/* ─── BottomNav — 5 tabs, icons only ────────────────────── */
function BottomNav({ active, onNavigate }) {
  const tabs = [
    { id:'home',      Icon: NavHome      },
    { id:'train',     Icon: NavTrain     },
    { id:'nutrition', Icon: NavNutrition },
    { id:'progress',  Icon: NavProgress  },
    { id:'profile',   Icon: NavProfile   },
  ];
  return (
    <div style={{
      display:'flex', justifyContent:'space-around', alignItems:'center',
      height:56, flexShrink:0,
      background: T.surface,
      borderTop:`0.5px solid ${T.divider}`,
    }}>
      {tabs.map(({ id, Icon }) => {
        const isActive = active === id;
        return (
          <button key={id} onClick={() => onNavigate(id)} style={{
            display:'flex', flexDirection:'column', alignItems:'center',
            justifyContent:'center', position:'relative',
            background:'none', border:'none', cursor:'pointer',
            flex:1, height:'100%', padding:0,
          }}>
            <Icon active={isActive} />
            {isActive && (
              <div style={{ width:20, height:2, background: T.accentIron,
                borderRadius: T.rfull, marginTop:5 }} />
            )}
          </button>
        );
      })}
    </div>
  );
}

/* ─── Nav Icons ──────────────────────────────────────────── */
function NavHome({ active }) {
  const c = active ? T.accentIron : T.textTertiary;
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      {active
        ? <path d="M3 9.5L12 3L21 9.5V20C21 20.55 20.55 21 20 21H15V15H9V21H4C3.45 21 3 20.55 3 20V9.5Z"
            fill={c} />
        : <path d="M3 9.5L12 3L21 9.5V20C21 20.55 20.55 21 20 21H15V15H9V21H4C3.45 21 3 20.55 3 20V9.5Z"
            stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      }
    </svg>
  );
}

function NavTrain({ active }) {
  const c = active ? T.accentIron : T.textTertiary;
  const sw = active ? '2' : '1.5';
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      {/* center bar */}
      <line x1="9" y1="12" x2="15" y2="12" stroke={c} strokeWidth="2.2" strokeLinecap="round"/>
      {/* left grip */}
      <rect x="5.5" y="9.5" width="3.5" height="5" rx="1"
        stroke={c} strokeWidth={sw} fill={active ? `${c}22` : 'none'}/>
      {/* right grip */}
      <rect x="15" y="9.5" width="3.5" height="5" rx="1"
        stroke={c} strokeWidth={sw} fill={active ? `${c}22` : 'none'}/>
      {/* left plate */}
      <rect x="2" y="8" width="3.5" height="8" rx="1.5"
        stroke={c} strokeWidth={sw} fill={active ? c : 'none'}/>
      {/* right plate */}
      <rect x="18.5" y="8" width="3.5" height="8" rx="1.5"
        stroke={c} strokeWidth={sw} fill={active ? c : 'none'}/>
    </svg>
  );
}

function NavProgress({ active }) {
  const c = active ? T.accentIron : T.textTertiary;
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <polyline points="4 18 8 13 12 15.5 17 9 21 6"
        stroke={c} strokeWidth={active?"2":"1.6"}
        strokeLinecap="round" strokeLinejoin="round"/>
      {active && (
        <circle cx="21" cy="6" r="1.5" fill={c}/>
      )}
    </svg>
  );
}

function NavProfile({ active }) {
  const c = active ? T.accentIron : T.textTertiary;
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      {active ? (
        <>
          <circle cx="12" cy="8" r="4" fill={c}/>
          <path d="M4 20c0-4 3.58-7 8-7s8 3 8 7" fill={c}/>
        </>
      ) : (
        <>
          <circle cx="12" cy="8" r="4" stroke={c} strokeWidth="1.6"/>
          <path d="M4 20c0-4 3.58-7 8-7s8 3 8 7"
            stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
        </>
      )}
    </svg>
  );
}

function NavNutrition({ active }) {
  const c = active ? T.accentIron : T.textTertiary;
  const sw = active ? '2' : '1.6';
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      {/* Fork tines */}
      <line x1="7" y1="3" x2="7" y2="7.5" stroke={c} strokeWidth={sw} strokeLinecap="round"/>
      <line x1="5" y1="3" x2="5" y2="6" stroke={c} strokeWidth={sw} strokeLinecap="round"/>
      <line x1="9" y1="3" x2="9" y2="6" stroke={c} strokeWidth={sw} strokeLinecap="round"/>
      {/* Fork curve */}
      <path d="M5 6 Q5 8 7 8 Q9 8 9 6" stroke={c} strokeWidth={sw} fill="none" strokeLinecap="round"/>
      {/* Fork handle */}
      <line x1="7" y1="8" x2="7" y2="21" stroke={c} strokeWidth={sw} strokeLinecap="round"/>
      {/* Knife */}
      <path d="M17 3 C17 3 19 5.5 19 9 C19 11 17.5 12 17 12 L17 21"
        stroke={c} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

/* ─── PRCard ─────────────────────────────────────────────── */
function PRCard({ pr }) {
  return (
    <div style={{
      background: T.surfaceElevated, borderRadius: T.rmd,
      padding:`${T.sm}px ${T.md}px`, minWidth:130, flexShrink:0,
    }}>
      <div style={{ fontFamily: T.fontBody, fontSize:11,
        color: T.textSecondary, fontWeight:500, marginBottom:4 }}>{pr.exercise}</div>
      <div style={{ display:'flex', alignItems:'baseline', gap:5 }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:22, fontWeight:700,
          color: T.accentIron, letterSpacing:'-0.02em',
          fontVariantNumeric:'tabular-nums' }}>{pr.value}</div>
        <span style={{ fontSize:14, color: T.successLime, fontWeight:700 }}>↑</span>
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize:10,
        color: T.textTertiary, marginTop:2 }}>{pr.date}</div>
    </div>
  );
}

/* ─── EmptyState ─────────────────────────────────────────── */
function EmptyState({ icon, title, subtitle, ctaLabel, onCta }) {
  return (
    <div style={{ display:'flex', flexDirection:'column', alignItems:'center',
      justifyContent:'center', gap: T.sm, padding:`${T.xxl}px ${T.xl}px`,
      textAlign:'center' }}>
      <div style={{ fontSize:32, opacity:0.35, color: T.textSecondary }}>{icon}</div>
      <div style={{ fontFamily: T.fontDisplay, fontSize:18, fontWeight:700,
        color: T.textPrimary }}>{title}</div>
      <div style={{ fontFamily: T.fontBody, fontSize:13,
        color: T.textSecondary, lineHeight:1.5 }}>{subtitle}</div>
      {ctaLabel && (
        <GhostButton label={ctaLabel} onPress={onCta}
          style={{ marginTop: T.xs }} />
      )}
    </div>
  );
}

// Expose globally
Object.assign(window, {
  PrimaryButton, GhostButton, TextBtn,
  SetRow, RoutineCard, MethodCard,
  SectionHeader, StatCard,
  RestTimerBanner, BottomNav,
  NavHome, NavTrain, NavProgress, NavProfile, NavNutrition,
  PRCard, EmptyState, pillStyle,
});

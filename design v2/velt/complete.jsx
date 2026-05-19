// VELT — Workout Complete Screen
// Full-screen overlay with animated check, stats, new PRs, exercise summary

const { useState, useEffect } = React;

function WorkoutCompleteScreen({ workoutName, onDone, onShare }) {
  const [drawn, setDrawn]       = useState(false);
  const [exVisible, setExVis]   = useState(false);
  const [showConfetti, setConf] = useState(false);

  useEffect(() => {
    const t1 = setTimeout(() => setDrawn(true), 100);
    const t2 = setTimeout(() => setExVis(true), 700);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, []);

  const stats = [
    { label:'Duration', value:'52', unit:'min' },
    { label:'Volume',   value:'12,440', unit:'kg' },
    { label:'Sets',     value:'18', unit:'' },
    { label:'PRs',      value:'2', unit:'', accent: true },
  ];

  const newPRs = [
    { exercise:'Bench Press', prev:'100 kg × 5', value:'102.5 kg × 5' },
    { exercise:'OHP',         prev:'70 kg × 6',  value:'72.5 kg × 6'  },
  ];

  const exercisesSummary = [
    { name:'Bench Press',         muscle:'Chest',     sets:'3 × 8, 1 × 6' },
    { name:'Incline DB Press',    muscle:'Chest',     sets:'3 × 10' },
    { name:'Overhead Press',      muscle:'Shoulders', sets:'2 × 8, 1 × 6' },
    { name:'Lateral Raise',       muscle:'Shoulders', sets:'3 × 12' },
    { name:'Triceps Pushdown',    muscle:'Arms',      sets:'3 × 12' },
    { name:'Cable Fly',           muscle:'Chest',     sets:'3 × 12' },
  ];

  function handleDone() {
    setConf(true);
    setTimeout(onDone, 800);
  }

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, position:'relative', overflow:'hidden' }}>

      <div style={{ flex: 1, overflowY:'auto',
        padding: `${T.xxl}px ${T.screenH}px ${T.lg}px` }}>

        {/* ═══ ANIMATED CHECK ═══ */}
        <div style={{ display:'flex', justifyContent:'center',
          marginBottom: T.lg }}>
          <CheckRing drawn={drawn}/>
        </div>

        {/* Title */}
        <div style={{ textAlign:'center', marginBottom: T.lg,
          opacity: drawn ? 1 : 0, transform: drawn ? 'translateY(0)' : 'translateY(8px)',
          transition:'all 500ms cubic-bezier(0.2,0,0,1) 300ms' }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 26, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.03em',
            lineHeight: 1.1 }}>Workout Complete</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 14,
            color: T.textSecondary, marginTop: 6 }}>{workoutName || 'Push A'}</div>
        </div>

        {/* ═══ STATS STRIP ═══ */}
        <div style={{ display:'flex', gap: 6, marginBottom: T.lg,
          opacity: drawn ? 1 : 0, transform: drawn ? 'translateY(0)' : 'translateY(12px)',
          transition:'all 500ms cubic-bezier(0.2,0,0,1) 450ms' }}>
          {stats.map(s => (
            <div key={s.label} style={{
              flex: 1, padding: '14px 8px',
              background: T.surfaceElevated,
              border: s.accent
                ? `1px solid ${T.accentIron}`
                : `0.5px solid ${T.divider}`,
              borderRadius: T.rmd, textAlign:'center',
            }}>
              <div style={{ fontFamily: T.fontBody, fontSize: 22, fontWeight: 700,
                color: s.accent ? T.accentIron : T.textPrimary,
                letterSpacing: '-0.025em',
                fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>
                {s.value}
              </div>
              {s.unit && (
                <div style={{ fontFamily: T.fontBody, fontSize: 10,
                  color: T.textSecondary, marginTop: 2 }}>{s.unit}</div>
              )}
              <div style={{ fontFamily: T.fontBody, fontSize: 9, fontWeight: 600,
                color: T.textTertiary, marginTop: 6,
                letterSpacing: '0.08em', textTransform:'uppercase' }}>
                {s.label}
              </div>
            </div>
          ))}
        </div>

        {/* ═══ NEW PRs ═══ */}
        {newPRs.length > 0 && (
          <div style={{ marginBottom: T.lg,
            opacity: exVisible ? 1 : 0,
            transform: exVisible ? 'translateY(0)' : 'translateY(12px)',
            transition:'all 500ms cubic-bezier(0.2,0,0,1)' }}>
            <SectionHeader label="NEW PERSONAL RECORDS"/>
            <div style={{ display:'flex', flexDirection:'column', gap: 8 }}>
              {newPRs.map(pr => <NewPRCard key={pr.exercise} pr={pr}/>)}
            </div>
          </div>
        )}

        {/* ═══ EXERCISES SUMMARY ═══ */}
        <div style={{
          opacity: exVisible ? 1 : 0,
          transform: exVisible ? 'translateY(0)' : 'translateY(12px)',
          transition:'all 500ms cubic-bezier(0.2,0,0,1) 100ms' }}>
          <SectionHeader label="EXERCISES"/>
          <Card padding={0}>
            {exercisesSummary.map((ex, i) => (
              <div key={ex.name} style={{
                padding: '12px 14px',
                borderBottom: i < exercisesSummary.length - 1
                  ? `0.5px solid ${T.divider}` : 'none',
                display:'flex', alignItems:'center', gap: T.sm,
              }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: T.fontBody, fontSize: 14,
                    fontWeight: 600, color: T.textPrimary,
                    letterSpacing: '-0.005em',
                    overflow:'hidden', textOverflow:'ellipsis',
                    whiteSpace:'nowrap' }}>{ex.name}</div>
                  <div style={{ fontFamily: T.fontBody, fontSize: 11,
                    color: T.textTertiary, marginTop: 2,
                    fontVariantNumeric:'tabular-nums' }}>
                    {ex.sets}
                  </div>
                </div>
                <Pill bg={T.surfaceHigh}>{ex.muscle}</Pill>
              </div>
            ))}
          </Card>
        </div>

      </div>

      {/* ═══ STICKY BOTTOM ═══ */}
      <div style={{
        padding: `12px ${T.screenH}px 16px`,
        background: T.surface,
        borderTop: `0.5px solid ${T.divider}`,
        display:'flex', gap: 8,
      }}>
        <GhostButton label="Share" onPress={onShare} style={{ flex: 1 }}/>
        <PrimaryButton label="Done" onPress={handleDone} style={{ flex: 2 }}/>
      </div>

      {/* ═══ CONFETTI on Done ═══ */}
      {showConfetti && <ConfettiBurst/>}
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   ANIMATED CHECK RING
──────────────────────────────────────────────────────── */
function CheckRing({ drawn }) {
  const r = 50;
  const circ = 2 * Math.PI * r;
  return (
    <svg width="120" height="120" viewBox="0 0 120 120">
      {/* Glow */}
      <defs>
        <filter id="glow">
          <feGaussianBlur stdDeviation="4"/>
        </filter>
      </defs>
      <circle cx="60" cy="60" r={r} fill={alpha(T.accentIron, 0.12)}/>
      <circle cx="60" cy="60" r={r}
        stroke={T.accentIron} strokeWidth="3" fill="none"
        strokeLinecap="round"
        strokeDasharray={circ.toFixed(1)}
        strokeDashoffset={drawn ? 0 : circ}
        transform="rotate(-90 60 60)"
        style={{ transition: 'stroke-dashoffset 700ms cubic-bezier(0.2,0,0,1)' }}/>
      <path d="M40 60 L55 75 L82 47"
        stroke="#FFF" strokeWidth="4" fill="none"
        strokeLinecap="round" strokeLinejoin="round"
        strokeDasharray="60" strokeDashoffset={drawn ? 0 : 60}
        style={{ transition:'stroke-dashoffset 400ms cubic-bezier(0.2,0,0,1) 500ms' }}/>
    </svg>
  );
}

/* ────────────────────────────────────────────────────────
   NEW PR CARD
──────────────────────────────────────────────────────── */
function NewPRCard({ pr }) {
  return (
    <div style={{
      background: alpha(T.accentIron, 0.08),
      border: `1px solid ${alpha(T.accentIron, 0.3)}`,
      borderRadius: T.rmd, padding: 14,
      display:'flex', alignItems:'center', gap: 12,
    }}>
      <div style={{ width: 36, height: 36, borderRadius:'50%',
        background: alpha(T.accentIron, 0.18),
        display:'flex', alignItems:'center', justifyContent:'center',
        flexShrink: 0,
      }}>
        <Icon.Trophy c={T.accentIron} size={16}/>
      </div>

      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.01em' }}>{pr.exercise}</div>
        <div style={{ display:'flex', alignItems:'center', gap: 6,
          marginTop: 3, flexWrap:'wrap' }}>
          <span style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, fontVariantNumeric:'tabular-nums',
            textDecoration:'line-through' }}>{pr.prev}</span>
          <span style={{ color: T.textTertiary, fontSize: 11 }}>→</span>
          <span style={{ fontFamily: T.fontBody, fontSize: 12, fontWeight: 700,
            color: T.accentIron, fontVariantNumeric:'tabular-nums' }}>
            {pr.value}
          </span>
        </div>
      </div>

      <Pill bg={T.accentIron} color="#FFF" style={{ fontSize: 9, fontWeight: 800 }}>
        NEW PR!
      </Pill>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   CONFETTI BURST (brief)
──────────────────────────────────────────────────────── */
function ConfettiBurst() {
  const pieces = Array.from({ length: 20 }, (_, i) => ({
    angle: (i / 20) * Math.PI * 2,
    dist: 80 + Math.random() * 60,
    delay: Math.random() * 200,
    color: [T.accentIron, T.successLime, '#fff'][i % 3],
  }));
  return (
    <div style={{ position:'absolute', inset: 0, pointerEvents:'none',
      zIndex: 200, display:'flex', alignItems:'center', justifyContent:'center' }}>
      {pieces.map((p, i) => (
        <div key={i} style={{
          position:'absolute',
          width: 5, height: 14,
          background: p.color, borderRadius: 1,
          opacity: 0,
          animation: `confettiBurst 800ms cubic-bezier(0.2,0.6,0.3,1) ${p.delay}ms forwards`,
          '--dx': `${Math.cos(p.angle) * p.dist}px`,
          '--dy': `${Math.sin(p.angle) * p.dist}px`,
        }}/>
      ))}
    </div>
  );
}

window.WorkoutCompleteScreen = WorkoutCompleteScreen;

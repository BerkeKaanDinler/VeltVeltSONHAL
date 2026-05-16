// VELT — Home Screen + Onboarding v2
// Changes: VELT all accentIron, flame SVG, Today's Plan accent bar, spacing 14/20

const { useState } = React;

/* ── Flame SVG icon ──────────────────────────────────────── */
function FlameSVG() {
  return (
    <svg width="14" height="16" viewBox="0 0 14 16" fill="none">
      <path d="M7 1C7 1 10.5 4.5 10.5 8C10.5 9.38 9.88 10.5 9 11C9.5 9.5 8.5 8.5 7.5 8C7.5 9 7 10 6 10.5C6 8.5 4.5 7 4.5 5C4.5 5 2 7 2 9.5C2 12.54 4.24 15 7 15C9.76 15 12 12.54 12 9.5C12 5.5 7 1 7 1Z"
        fill="#84CC16"/>
    </svg>
  );
}

/* ══════════════════════════════════════════════════════════
   ONBOARDING
══════════════════════════════════════════════════════════ */
function OnboardingScreen({ onFinish }) {
  const [step, setStep] = useState(0);
  const [unit, setUnit] = useState(null);
  const [path, setPath] = useState(null);

  if (step === 0) return (
    <div style={{ flex:1, display:'flex', flexDirection:'column',
      alignItems:'center', justifyContent:'center',
      padding:`0 ${T.xl}px`, background: T.surface }}>
      <div style={{ marginBottom: T.xl, textAlign:'center' }}>
        {/* Wordmark — full accentIron */}
        <div style={{ fontFamily: T.fontDisplay, fontSize:56, fontWeight:700,
          letterSpacing:'-0.04em', lineHeight:1, marginBottom: T.lg,
          color: T.accentIron }}>
          VELT
        </div>
        <div style={{ fontFamily: T.fontDisplay, fontSize:22, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.02em', lineHeight:1.25,
          marginBottom: T.sm }}>
          Track your lifts.<br/>Privately. Offline.
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize:14,
          color: T.textSecondary, lineHeight:1.65 }}>
          No account. No cloud.<br/>Just you and the bar.
        </div>
      </div>
      <div style={{ width:'100%', display:'flex', flexDirection:'column', gap: T.sm }}>
        <PrimaryButton label="Get Started" onPress={() => setStep(1)} />
        <TextBtn label="Already have a backup? Restore"
          onPress={() => setStep(1)}
          style={{ color: T.textTertiary, textAlign:'center' }} />
      </div>
    </div>
  );

  if (step === 1) return (
    <div style={{ flex:1, display:'flex', flexDirection:'column',
      padding:`${T.xxl}px ${T.xl}px ${T.xl}px`, background: T.surface }}>
      <div style={{ fontFamily: T.fontDisplay, fontSize:28, fontWeight:700,
        color: T.textPrimary, letterSpacing:'-0.02em', marginBottom: T.lg }}>
        How do you<br/>measure weight?
      </div>
      <div style={{ display:'flex', gap: T.sm, marginBottom: T.xxl }}>
        {['kg','lb'].map(u => (
          <div key={u} onClick={() => setUnit(u)} style={{
            flex:1, height:80, borderRadius: T.rlg,
            background: T.surfaceElevated,
            border: unit === u ? `2px solid ${T.accentIron}` : `2px solid transparent`,
            display:'flex', alignItems:'center', justifyContent:'center',
            cursor:'pointer', transition:'border 200ms',
          }}>
            <span style={{ fontFamily: T.fontDisplay, fontSize:26, fontWeight:700,
              color: unit === u ? T.accentIron : T.textSecondary }}>{u}</span>
          </div>
        ))}
      </div>
      <PrimaryButton label="Continue" disabled={!unit}
        onPress={() => setStep(2)} />
    </div>
  );

  if (step === 2) {
    const paths = [
      { id:'method',  label:'I have a program in mind',  sub:'Browse training methods & programs' },
      { id:'starter', label:'Show me a starter routine', sub:'PPL / Upper-Lower / 5×5' },
    ];
    return (
      <div style={{ flex:1, display:'flex', flexDirection:'column',
        padding:`${T.xxl}px ${T.xl}px ${T.xl}px`, background: T.surface }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:28, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.02em', marginBottom: T.lg }}>
          How do you want<br/>to start?
        </div>
        <div style={{ display:'flex', flexDirection:'column', gap: T.sm,
          marginBottom: T.xxl }}>
          {paths.map(p => (
            <div key={p.id} onClick={() => setPath(p.id)} style={{
              background: T.surfaceElevated, borderRadius: T.rmd,
              padding:20,
              border: path === p.id ? `2px solid ${T.accentIron}` : `2px solid transparent`,
              cursor:'pointer', transition:'border 200ms',
            }}>
              <div style={{ fontFamily: T.fontDisplay, fontSize:15, fontWeight:700,
                color: path === p.id ? T.accentIron : T.textPrimary,
                letterSpacing:'-0.01em' }}>{p.label}</div>
              <div style={{ fontFamily: T.fontBody, fontSize:12,
                color: T.textSecondary, marginTop:3 }}>{p.sub}</div>
            </div>
          ))}
        </div>
        <PrimaryButton label="Start" disabled={!path} onPress={onFinish} />
        <TextBtn label="I'll set up later" onPress={onFinish}
          style={{ textAlign:'center', marginTop: T.sm }} />
      </div>
    );
  }
  return null;
}

/* ══════════════════════════════════════════════════════════
   HOME SCREEN
══════════════════════════════════════════════════════════ */
function HomeScreen({ onStartWorkout, onNavigate }) {
  const days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  const today = days[new Date().getDay()];

  const todayPlan = {
    name: 'Push A — Chest / Shoulders',
    exerciseCount: 6,
    duration: '~55 min',
    color: '#D97706',
  };
  const lastWorkout = {
    date: 'Yesterday', name: 'Pull A',
    duration: '48 min', volume: '12,440 kg',
  };
  const recentPRs = [
    { exercise:'Bench Press', value:'102.5 kg', date:'2 days ago' },
    { exercise:'Squat',       value:'142.5 kg', date:'5 days ago' },
    { exercise:'OHP',         value:'72.5 kg',  date:'1 week ago' },
  ];
  const streak = 7;

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface }}>

      {/* ── Header ── */}
      <div style={{ padding:`${T.xl}px ${T.md}px ${T.lg}px` }}>
        <div style={{ fontFamily: T.fontBody, fontSize:13, fontWeight:500,
          color: T.textSecondary, letterSpacing:'0.03em',
          textTransform:'uppercase' }}>{today}</div>
        {/* VELT wordmark — all accentIron */}
        <div style={{ fontFamily: T.fontDisplay, fontSize:34, fontWeight:700,
          color: T.accentIron, letterSpacing:'-0.04em', lineHeight:1.1,
          marginTop:3 }}>VELT</div>
      </div>

      <div style={{ display:'flex', flexDirection:'column',
        gap:14, padding:`0 ${T.md}px ${T.xl}px` }}>

        {/* ── Streak banner ── */}
        {streak > 0 && (
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            padding:`${T.sm}px 20px`,
            display:'flex', alignItems:'center', gap: T.xs }}>
            <FlameSVG />
            <span style={{ fontFamily: T.fontBody, fontSize:13, fontWeight:600,
              color: T.successLime }}>{streak}-day streak</span>
            <div style={{ display:'flex', gap:3, alignItems:'center', marginLeft:'auto' }}>
              {Array.from({length:7}, (_,i) => (
                <div key={i} style={{ width:6, height:6, borderRadius:'50%',
                  background: i < streak ? T.accentIron : T.surfaceHigh }} />
              ))}
            </div>
          </div>
        )}

        {/* ── Today's Plan ── */}
        <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
          overflow:'hidden', position:'relative' }}>
          {/* left accent bar (RoutineCard pattern) */}
          <div style={{ position:'absolute', left:0, top:0, bottom:0, width:4,
            background: todayPlan.color }} />
          <div style={{ padding:20, paddingLeft:20 }}>
            <div style={{ fontFamily: T.fontBody, fontSize:11, fontWeight:500,
              color: T.textTertiary, letterSpacing:'0.08em',
              textTransform:'uppercase', marginBottom: T.xs }}>Today's Plan</div>
            <div style={{ fontFamily: T.fontDisplay, fontSize:17, fontWeight:700,
              color: T.textPrimary, letterSpacing:'-0.01em',
              marginBottom: T.xs }}>{todayPlan.name}</div>
            <div style={{ display:'flex', alignItems:'center',
              gap: T.xs, flexWrap:'wrap', marginBottom:6 }}>
              <span style={{ fontFamily: T.fontBody, fontSize:12,
                color: T.textSecondary }}>
                {todayPlan.exerciseCount} exercises
              </span>
              <span style={{ fontFamily: T.fontBody, fontSize:11,
                fontWeight:600, color: T.textTertiary,
                background: T.surfaceHigh, padding:'3px 9px',
                borderRadius: T.rfull }}>
                {todayPlan.duration}
              </span>
            </div>
            <div style={{ fontFamily: T.fontBody, fontSize:11,
              color: T.textTertiary, marginBottom: T.md }}>
              Bench Press · Incline Press · OHP
              <span style={{ color: T.textTertiary }}> +3 more</span>
            </div>
            <PrimaryButton label="Start Workout" onPress={onStartWorkout} />
          </div>
        </div>

        {/* ── Quick Start ── */}
        <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
          padding:20, border:`1px dashed ${T.divider}`,
          display:'flex', flexDirection:'column', gap: T.xs }}>
          <div style={{ fontFamily: T.fontDisplay, fontSize:15, fontWeight:700,
            color: T.textPrimary }}>Empty workout</div>
          <div style={{ fontFamily: T.fontBody, fontSize:12,
            color: T.textSecondary }}>No routine needed</div>
          <GhostButton label="Quick Start" onPress={onStartWorkout}
            style={{ marginTop:6, height:40, fontSize:13 }} />
        </div>

        {/* ── Last Workout ── */}
        <div>
          <SectionHeader label="Last Workout" />
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            padding:20 }}>
            <div style={{ display:'flex', justifyContent:'space-between',
              alignItems:'center', marginBottom: T.sm }}>
              <div style={{ fontFamily: T.fontDisplay, fontSize:16, fontWeight:700,
                color: T.textPrimary }}>{lastWorkout.name}</div>
              <span style={{ fontFamily: T.fontBody, fontSize:11,
                color: T.textTertiary }}>{lastWorkout.date}</span>
            </div>
            <div style={{ display:'flex', alignItems:'center', gap: T.md }}>
              <div>
                <div style={{ fontFamily: T.fontDisplay, fontSize:17,
                  fontWeight:700, color: T.textPrimary,
                  fontVariantNumeric:'tabular-nums' }}>{lastWorkout.duration}</div>
                <div style={{ fontFamily: T.fontBody, fontSize:10,
                  color: T.textTertiary, textTransform:'uppercase',
                  letterSpacing:'0.05em', marginTop:2 }}>Duration</div>
              </div>
              <div style={{ width:1, height:32, background: T.divider }} />
              <div>
                <div style={{ fontFamily: T.fontDisplay, fontSize:17,
                  fontWeight:700, color: T.textPrimary,
                  fontVariantNumeric:'tabular-nums' }}>{lastWorkout.volume}</div>
                <div style={{ fontFamily: T.fontBody, fontSize:10,
                  color: T.textTertiary, textTransform:'uppercase',
                  letterSpacing:'0.05em', marginTop:2 }}>Volume</div>
              </div>
            </div>
          </div>
        </div>

        {/* ── Recent PRs ── */}
        <div>
          <SectionHeader label="Recent PRs" action="See all"
            onAction={() => onNavigate('progress')} />
          <div style={{ display:'flex', gap: T.sm, overflowX:'auto',
            paddingBottom:4 }}>
            {recentPRs.map(pr => <PRCard key={pr.exercise} pr={pr} />)}
          </div>
        </div>

      </div>
    </div>
  );
}

Object.assign(window, { OnboardingScreen, HomeScreen });

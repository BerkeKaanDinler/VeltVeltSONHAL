// VELT — Onboarding (4 pages, horizontal swipe)

const { useState } = React;

const GOALS = [
  { id:'muscle',    label:'Build Muscle',  desc:'Add lean mass & size',          icon: GoalIconMuscle,    color:'#D97706' },
  { id:'fat',       label:'Lose Fat',      desc:'Lean out, keep strength',       icon: GoalIconFat,       color:'#22C55E' },
  { id:'strength',  label:'Strength',      desc:'Push your 1RM higher',           icon: GoalIconStrength,  color:'#6366F1' },
  { id:'endurance', label:'Endurance',     desc:'Last longer, recover faster',   icon: GoalIconEndurance, color:'#06B6D4' },
];

const LEVELS = [
  { id:'beg', label:'Beginner',     range:'< 1 year',    rest:75,  desc:'Building base strength' },
  { id:'int', label:'Intermediate', range:'1 – 3 years', rest:90,  desc:'Past the linear phase' },
  { id:'adv', label:'Advanced',     range:'3+ years',    rest:120, desc:'Programmed periodization' },
];

/* ── Goal icons ────────────────────────────────────────── */
function GoalIconMuscle({ c, size=22 }) {
  return <svg width={size} height={size} viewBox="0 0 22 22" fill="none">
    <path d="M11 3 Q14 5 14 9 Q14 13 11 15 Q8 13 8 9 Q8 5 11 3 Z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
    <path d="M11 15 V19 M9 19 H13" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
  </svg>;
}
function GoalIconFat({ c, size=22 }) {
  return <svg width={size} height={size} viewBox="0 0 22 22" fill="none">
    <path d="M11 3 V11 M7 7 L11 11 L15 7" stroke={c} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/>
    <circle cx="11" cy="15" r="4" stroke={c} strokeWidth="1.6"/>
  </svg>;
}
function GoalIconStrength({ c, size=22 }) {
  return <svg width={size} height={size} viewBox="0 0 22 22" fill="none">
    <path d="M3 11 H19" stroke={c} strokeWidth="2.2" strokeLinecap="round"/>
    <rect x="5" y="8" width="2.5" height="6" rx="0.5" stroke={c} strokeWidth="1.6"/>
    <rect x="14.5" y="8" width="2.5" height="6" rx="0.5" stroke={c} strokeWidth="1.6"/>
  </svg>;
}
function GoalIconEndurance({ c, size=22 }) {
  return <svg width={size} height={size} viewBox="0 0 22 22" fill="none">
    <circle cx="11" cy="11" r="8" stroke={c} strokeWidth="1.5"/>
    <path d="M11 6 V11 L15 13" stroke={c} strokeWidth="1.6" strokeLinecap="round"/>
  </svg>;
}

/* ══════════════════════════════════════════════════════════
   ONBOARDING ROOT — with swipe + slide animation
══════════════════════════════════════════════════════════ */
function OnboardingScreen({ onFinish }) {
  const [page, setPage] = useState(0);
  const [goal, setGoal] = useState(null);
  const [level, setLevel] = useState(null);
  const [unit, setUnit] = useState(null);

  // Drag state
  const [drag, setDrag] = useState({ active:false, startX:0, dx:0 });

  const totalPages = 4;
  const canNext = (
    (page === 0) ||
    (page === 1 && goal) ||
    (page === 2 && level) ||
    (page === 3 && unit)
  );

  function next() {
    if (page === totalPages - 1) {
      onFinish({ goal, level, unit });
    } else if (canNext) {
      setPage(p => p + 1);
    }
  }
  function prev() {
    if (page > 0) setPage(p => p - 1);
  }

  // Touch / pointer handlers
  function onDown(e) {
    const x = e.clientX ?? e.touches?.[0]?.clientX;
    if (x == null) return;
    setDrag({ active:true, startX:x, dx:0 });
  }
  function onMove(e) {
    if (!drag.active) return;
    const x = e.clientX ?? e.touches?.[0]?.clientX;
    if (x == null) return;
    const dx = x - drag.startX;
    // Only allow backward swipe (positive dx going back) freely;
    // Forward swipe (negative dx) only if canNext
    const limited =
      dx > 0  && page === 0          ? dx * 0.2 :  // resist on first page
      dx < 0  && !canNext            ? dx * 0.2 :  // resist if can't proceed
      dx;
    setDrag(d => ({ ...d, dx: limited }));
  }
  function onUp() {
    if (!drag.active) return;
    const threshold = 60;
    if (drag.dx < -threshold && canNext) {
      next();
    } else if (drag.dx > threshold && page > 0) {
      prev();
    }
    setDrag({ active:false, startX:0, dx:0 });
  }

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, overflow:'hidden' }}>

      {/* Progress bar */}
      <div style={{ padding: `${T.md}px ${T.md}px 0` }}>
        <div style={{ height: 3, background: T.surfaceHigh,
          borderRadius: T.rfull, overflow:'hidden' }}>
          <div style={{
            height:'100%',
            width: `${((page + 1) / totalPages) * 100}%`,
            background: T.accentIron, borderRadius: T.rfull,
            transition: 'width 400ms cubic-bezier(0.2,0,0,1)',
          }} />
        </div>
      </div>

      {/* Back chevron on pages > 0 */}
      {page > 0 && (
        <div style={{ padding: `${T.md}px ${T.md}px 0` }}>
          <button onClick={prev} style={{
            background:'none', border:'none', cursor:'pointer',
            padding: 6, display:'flex', alignItems:'center', gap: 4,
            color: T.textSecondary, fontSize: 13, fontWeight: 500,
          }}>
            <Icon.ArrowLeft c={T.textSecondary} size={18}/>
            Back
          </button>
        </div>
      )}

      {/* Pages container — slides horizontally based on `page` */}
      <div
        onPointerDown={onDown}
        onPointerMove={onMove}
        onPointerUp={onUp}
        onPointerLeave={onUp}
        style={{
          flex: 1, position:'relative', overflow:'hidden',
          touchAction: 'pan-y',
        }}>
        <div style={{
          position:'absolute', inset:0,
          display:'flex',
          transform: `translateX(calc(-${page * 100}% + ${drag.dx}px))`,
          transition: drag.active ? 'none' : 'transform 380ms cubic-bezier(0.2,0,0,1)',
          width: `${totalPages * 100}%`,
        }}>
          <div style={{ width: '25%', flexShrink: 0,
            display:'flex', flexDirection:'column' }}>
            <WelcomePage onContinue={next}/>
          </div>
          <div style={{ width: '25%', flexShrink: 0,
            display:'flex', flexDirection:'column',
            overflow:'auto' }}>
            <GoalPage selected={goal} onSelect={setGoal}/>
          </div>
          <div style={{ width: '25%', flexShrink: 0,
            display:'flex', flexDirection:'column',
            overflow:'auto' }}>
            <LevelPage selected={level} onSelect={setLevel}/>
          </div>
          <div style={{ width: '25%', flexShrink: 0,
            display:'flex', flexDirection:'column',
            overflow:'auto' }}>
            <UnitPage selected={unit} onSelect={setUnit}/>
          </div>
        </div>
      </div>

      {/* Page indicator dots (pages 1-3 only) */}
      {page > 0 && (
        <div style={{ display:'flex', justifyContent:'center', gap: 6,
          paddingBottom: 8 }}>
          {Array.from({ length: totalPages }, (_, i) => (
            <div key={i} style={{
              width: i === page ? 22 : 6, height: 6,
              borderRadius: T.rfull,
              background: i === page ? T.accentIron : T.surfaceHigh,
              transition: 'all 300ms cubic-bezier(0.2,0,0,1)',
            }}/>
          ))}
        </div>
      )}

      {/* Sticky bottom CTA */}
      {page > 0 && (
        <div style={{ padding: `${T.sm}px ${T.md}px ${T.lg}px` }}>
          <PrimaryButton
            label={page === totalPages - 1 ? "Let's go →" : 'Continue'}
            disabled={!canNext}
            onPress={next}
          />
        </div>
      )}
    </div>
  );
}

/* ── Page 1: Welcome ──────────────────────────────────── */
function WelcomePage({ onContinue }) {
  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      padding: `${T.xxxl}px ${T.lg}px ${T.lg}px`,
      justifyContent:'space-between' }}>

      <div style={{ display:'flex', flexDirection:'column', gap: T.xl, flex: 1, justifyContent:'center' }}>
        {/* VELT wordmark */}
        <div style={{ fontFamily: T.fontBody, fontSize: 72, fontWeight: 700,
          color: T.accentIron, letterSpacing: '-0.06em', lineHeight: 1 }}>VELT</div>

        {/* Hero statement */}
        <div style={{ fontFamily: T.fontBody, fontSize: 28, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.03em',
          lineHeight: 1.15, maxWidth: 280 }}>
          Built for people who are serious about training.
        </div>

        <div style={{ fontFamily: T.fontBody, fontSize: 13,
          color: T.textSecondary, lineHeight: 1.6, maxWidth: 280 }}>
          No social feed. No fluff. Just the tools and the data to get stronger every week.
        </div>
      </div>

      <PrimaryButton label="Get Started" onPress={onContinue} />
    </div>
  );
}

/* ── Page 2: Goal ─────────────────────────────────────── */
function GoalPage({ selected, onSelect }) {
  return (
    <div style={{ flex: 1, padding: `${T.lg}px ${T.md}px 0` }}>
      <div style={{ marginBottom: T.lg }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 26, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.03em', lineHeight: 1.2 }}>
          What's your<br/>primary goal?
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 13,
          color: T.textSecondary, marginTop: T.xs }}>
          We'll tailor your nutrition targets and program recommendations.
        </div>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr',
        gap: 10 }}>
        {GOALS.map(g => {
          const active = selected === g.id;
          const Ico = g.icon;
          return (
            <div key={g.id} onClick={() => onSelect(g.id)} style={{
              padding: 16, borderRadius: T.rmd,
              background: active ? alpha(g.color, 0.08) : T.surfaceElevated,
              border: active
                ? `1.5px solid ${g.color}`
                : `0.5px solid ${T.divider}`,
              cursor:'pointer', transition:'all 200ms',
              minHeight: 124,
              display:'flex', flexDirection:'column', justifyContent:'space-between',
            }}>
              <div style={{
                width: 38, height: 38, borderRadius: T.rsm,
                background: active ? alpha(g.color, 0.15) : T.surfaceHigh,
                display:'flex', alignItems:'center', justifyContent:'center',
              }}>
                <Ico c={active ? g.color : T.textSecondary} />
              </div>
              <div>
                <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
                  color: T.textPrimary, letterSpacing: '-0.01em',
                  marginBottom: 2 }}>{g.label}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 11,
                  color: T.textSecondary, lineHeight: 1.4 }}>{g.desc}</div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

/* ── Page 3: Experience Level ─────────────────────────── */
function LevelPage({ selected, onSelect }) {
  return (
    <div style={{ flex: 1, padding: `${T.lg}px ${T.md}px 0` }}>
      <div style={{ marginBottom: T.lg }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 26, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.03em', lineHeight: 1.2 }}>
          How long have you<br/>been training?
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 13,
          color: T.textSecondary, marginTop: T.xs }}>
          Sets your rest defaults and program recommendations.
        </div>
      </div>

      <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
        {LEVELS.map(l => {
          const active = selected === l.id;
          return (
            <div key={l.id} onClick={() => onSelect(l.id)} style={{
              padding: 18, borderRadius: T.rmd,
              background: active ? alpha(T.accentIron, 0.08) : T.surfaceElevated,
              border: active
                ? `1.5px solid ${T.accentIron}`
                : `0.5px solid ${T.divider}`,
              cursor:'pointer', transition:'all 200ms',
              display:'flex', alignItems:'center', gap: T.md,
            }}>
              {/* Number badge */}
              <div style={{
                width: 48, height: 48, borderRadius: T.rmd,
                background: active ? T.accentIron : T.surfaceHigh,
                display:'flex', alignItems:'center', justifyContent:'center',
                flexShrink: 0,
              }}>
                <span style={{ fontFamily: T.fontBody, fontSize: 17,
                  fontWeight: 700, color: active ? '#FFF' : T.textSecondary }}>
                  {l.range.replace('+ years','+').replace(' years','y').replace(' year','y').replace('< ','<')}
                </span>
              </div>

              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
                  color: T.textPrimary, letterSpacing: '-0.01em' }}>{l.label}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 12,
                  color: T.textSecondary, marginTop: 2 }}>{l.desc}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 10,
                  color: T.textTertiary, marginTop: 4, letterSpacing: '0.04em',
                  textTransform:'uppercase' }}>
                  Rest timer default · {l.rest}s
                </div>
              </div>

              {active && (
                <div style={{ width: 24, height: 24, borderRadius:'50%',
                  background: T.accentIron, display:'flex',
                  alignItems:'center', justifyContent:'center', flexShrink: 0 }}>
                  <Icon.Check c="#FFF" sw={2.4}/>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

/* ── Page 4: Unit ─────────────────────────────────────── */
function UnitPage({ selected, onSelect }) {
  return (
    <div style={{ flex: 1, padding: `${T.lg}px ${T.md}px 0`,
      display:'flex', flexDirection:'column' }}>
      <div style={{ marginBottom: T.lg }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 26, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.03em', lineHeight: 1.2 }}>
          Pick your<br/>weight unit.
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 13,
          color: T.textSecondary, marginTop: T.xs }}>
          You can change this anytime in Settings.
        </div>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10,
        marginBottom: T.lg }}>
        {['kg','lbs'].map(u => {
          const active = selected === u;
          return (
            <div key={u} onClick={() => onSelect(u)} style={{
              padding: 28, borderRadius: T.rmd,
              background: active ? alpha(T.accentIron, 0.08) : T.surfaceElevated,
              border: active
                ? `1.5px solid ${T.accentIron}`
                : `0.5px solid ${T.divider}`,
              cursor:'pointer', transition:'all 200ms',
              textAlign:'center',
            }}>
              <div style={{ fontFamily: T.fontBody, fontSize: 44, fontWeight: 700,
                color: active ? T.accentIron : T.textSecondary,
                letterSpacing: '-0.04em', lineHeight: 1 }}>{u}</div>
              <div style={{ fontFamily: T.fontBody, fontSize: 11,
                color: T.textTertiary, marginTop: 8 }}>
                {u === 'kg' ? 'kilograms' : 'pounds'}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

window.OnboardingScreen = OnboardingScreen;

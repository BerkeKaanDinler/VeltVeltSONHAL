// VELT — Train Screen v2
// Changes: category dot colors BB/PL/Strength, filter chip styling, spacing 14/20

const { useState } = React;

const ROUTINES = [
  { id:'push-a', name:'Push A — Chest/Shoulders', exerciseCount:6, lastDone:'Yesterday',  color:'#D97706' },
  { id:'pull-a', name:'Pull A — Back/Biceps',     exerciseCount:5, lastDone:'2 days ago', color:'#3B82F6' },
  { id:'legs-a', name:'Legs A — Squat Focus',     exerciseCount:6, lastDone:'3 days ago', color:'#10B981' },
  { id:'push-b', name:'Push B — Shoulder Focus',  exerciseCount:5, lastDone:'4 days ago', color:'#8B5CF6' },
  { id:'pull-b', name:'Pull B — Deadlift Focus',  exerciseCount:5, lastDone:'5 days ago', color:'#EC4899' },
];

const METHODS = [
  { id:'ppl',   name:'Push Pull Legs',       tagline:'Classic hypertrophy split, 6×/week',      difficulty:'Intermediate', frequency:'6×/week',   category:'BB',       categoryColor:'#D97706' },
  { id:'5x5',   name:'StrongLifts 5×5',      tagline:'Compound strength, linear progression',   difficulty:'Beginner',     frequency:'3×/week',   category:'Strength', categoryColor:'#22C55E' },
  { id:'531',   name:'5/3/1 by Jim Wendler', tagline:'Long-term strength, wave loading',        difficulty:'Intermediate', frequency:'4×/week',   category:'PL',       categoryColor:'#6366F1' },
  { id:'ul',    name:'Upper Lower',          tagline:'4-day frequency split, balanced',         difficulty:'Beginner',     frequency:'4×/week',   category:'Strength', categoryColor:'#22C55E' },
  { id:'gzclp', name:'GZCLP',               tagline:'Tier system for volume + strength',       difficulty:'Intermediate', frequency:'3-4×/week', category:'PL',       categoryColor:'#6366F1' },
  { id:'nsuns', name:'nSuns 5/3/1',          tagline:'High volume powerlifting variant',        difficulty:'Advanced',     frequency:'5×/week',   category:'PL',       categoryColor:'#6366F1' },
];

const FILTER_CATS = ['All','Bodybuilding','Powerlifting','Strength'];
const CAT_MAP = { Bodybuilding:'BB', Powerlifting:'PL', Strength:'Strength' };

function TrainScreen({ onStartWorkout }) {
  const [filter, setFilter]           = useState('All');
  const [selectedMethod, setSelected] = useState(null);

  if (selectedMethod) {
    return (
      <MethodDetailScreen
        method={selectedMethod}
        onBack={() => setSelected(null)}
        onStartWorkout={onStartWorkout}
      />
    );
  }

  const filtered = filter === 'All'
    ? METHODS
    : METHODS.filter(m => m.category === CAT_MAP[filter]);

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface }}>
      {/* Header */}
      <div style={{ padding:`${T.xl}px ${T.md}px ${T.md}px`,
        display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:34, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.03em' }}>Train</div>
        <GhostButton label="+ Routine" style={{ height:36, fontSize:12 }}
          onPress={() => {}} />
      </div>

      <div style={{ padding:`0 ${T.md}px`,
        display:'flex', flexDirection:'column', gap:14, paddingBottom: T.xxl }}>

        {/* ── My Routines ── */}
        <div>
          <SectionHeader label="My Routines" />
          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {ROUTINES.map(r => (
              <RoutineCard key={r.id} routine={r} onPress={onStartWorkout} />
            ))}
          </div>
        </div>

        {/* ── Methods & Programs ── */}
        <div>
          <SectionHeader label="Methods & Programs" />

          {/* Filter chips */}
          <div style={{ display:'flex', gap: T.xs, marginBottom: T.sm,
            overflowX:'auto', paddingBottom:2 }}>
            {FILTER_CATS.map(f => {
              const active = filter === f;
              return (
                <button key={f} onClick={() => setFilter(f)} style={{
                  padding:'6px 16px', borderRadius: T.rfull,
                  border: active ? 'none' : `1px solid ${T.divider}`,
                  background: active ? T.accentIron : T.surfaceElevated,
                  color: active ? '#fff' : T.textSecondary,
                  fontFamily: T.fontBody, fontSize:12, fontWeight:600,
                  cursor:'pointer', whiteSpace:'nowrap', flexShrink:0,
                  transition:'background 200ms, color 200ms',
                }}>{f}</button>
              );
            })}
          </div>

          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {filtered.map(m => (
              <MethodCard key={m.id} method={m}
                onPress={() => setSelected(m)} />
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}

/* ── Method Detail ───────────────────────────────────────── */
function MethodDetailScreen({ method, onBack, onStartWorkout }) {
  const DATA = {
    ppl: {
      summary: 'Push Pull Legs organizes training by movement pattern, training each muscle group twice per week with dedicated days.',
      principles: ['Progressive overload on compound lifts','High weekly volume per muscle group','Clear push/pull/legs separation'],
      weekly: [
        {day:'Mon',focus:'Push (Chest, Shoulders, Triceps)'},
        {day:'Tue',focus:'Pull (Back, Biceps)'},
        {day:'Wed',focus:'Legs (Quads, Hamstrings, Glutes)'},
        {day:'Thu',focus:'Push'},
        {day:'Fri',focus:'Pull'},
        {day:'Sat',focus:'Legs'},
        {day:'Sun',focus:'Rest'},
      ],
      idealFor:'Intermediate lifters with solid form on the big compounds, training 6 days/week.',
      cautions:'High frequency demands recovery. Sleep 8h. De-load every 8 weeks.',
    },
    '5x5': {
      summary:'StrongLifts 5×5 is a beginner strength program built around three compound movements. You squat every session.',
      principles:['Three lifts dominate: Squat, Bench, Row/Press/Deadlift','Linear progression — add 2.5kg each session','5 sets of 5 reps, no fluff'],
      weekly:[{day:'Mon',focus:'Workout A (Squat, Bench, Row)'},{day:'Wed',focus:'Workout B (Squat, OHP, Deadlift)'},{day:'Fri',focus:'Workout A'},],
      idealFor:'Complete beginners who want to build a strength base fast.',
      cautions:'Will stall within 3-6 months. Have a next program ready.',
    },
  };
  const d = DATA[method.id] || DATA['ppl'];

  const secTitle = {
    fontFamily: T.fontBody, fontSize:11, fontWeight:500,
    color: T.textTertiary, letterSpacing:'0.08em',
    textTransform:'uppercase', marginBottom: T.xs,
  };

  return (
    <div style={{ flex:1, display:'flex', flexDirection:'column',
      background: T.surface }}>
      {/* Sticky header */}
      <div style={{ padding:`${T.sm}px ${T.md}px`,
        borderBottom:`1px solid ${T.divider}`,
        display:'flex', alignItems:'center', gap: T.sm }}>
        <button onClick={onBack} style={{ background:'none', border:'none',
          color: T.accentIron, fontFamily: T.fontBody, fontSize:15,
          fontWeight:600, cursor:'pointer', padding:`0 ${T.xs}px 0 0`,
          minWidth:44, minHeight:44, display:'flex', alignItems:'center' }}>← Back</button>
        <div style={{ flex:1, fontFamily: T.fontDisplay, fontSize:17,
          fontWeight:700, color: T.textPrimary, letterSpacing:'-0.01em',
          overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>
          {method.name}
        </div>
        <span style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:700,
          color: method.categoryColor,
          background:`${method.categoryColor}22`,
          padding:'3px 8px', borderRadius: T.rfull, letterSpacing:'0.05em',
          textTransform:'uppercase', flexShrink:0 }}>{method.difficulty}</span>
      </div>

      <div style={{ flex:1, overflowY:'auto' }}>
        <div style={{ padding:`${T.lg}px ${T.md}px`,
          display:'flex', flexDirection:'column', gap: T.lg }}>
          <div style={{ fontFamily: T.fontBody, fontSize:14,
            color: T.textSecondary, lineHeight:1.65, fontStyle:'italic' }}>
            {method.tagline}
          </div>
          <div>
            <div style={secTitle}>Summary</div>
            <div style={{ fontFamily: T.fontBody, fontSize:13,
              color: T.textSecondary, lineHeight:1.65 }}>{d.summary}</div>
          </div>
          <div>
            <div style={secTitle}>Core Principles</div>
            <div style={{ display:'flex', flexDirection:'column', gap: T.xs }}>
              {d.principles.map((p,i) => (
                <div key={i} style={{ display:'flex', gap: T.sm,
                  alignItems:'flex-start' }}>
                  <div style={{ width:5, height:5, borderRadius: T.rfull,
                    background: T.accentIron, flexShrink:0, marginTop:6 }} />
                  <span style={{ fontFamily: T.fontBody, fontSize:13,
                    color: T.textSecondary, lineHeight:1.5 }}>{p}</span>
                </div>
              ))}
            </div>
          </div>
          <div>
            <div style={secTitle}>Weekly Structure</div>
            <div style={{ background: T.surfaceElevated,
              borderRadius: T.rsm, overflow:'hidden' }}>
              {d.weekly.map((row,i) => (
                <div key={row.day} style={{
                  display:'flex', gap: T.sm,
                  padding:`${T.xs}px ${T.sm}px`,
                  borderBottom: i < d.weekly.length-1
                    ? `1px solid ${T.divider}44` : 'none',
                }}>
                  <span style={{ fontFamily: T.fontDisplay, fontSize:12,
                    fontWeight:700, color: T.accentIron, minWidth:28 }}>{row.day}</span>
                  <span style={{ fontFamily: T.fontBody, fontSize:12,
                    color: row.focus==='Rest' ? T.textTertiary : T.textSecondary }}>
                    {row.focus}
                  </span>
                </div>
              ))}
            </div>
          </div>
          <div style={{ background: T.surfaceElevated, borderRadius: T.rsm,
            padding: T.sm, borderLeft:`3px solid ${T.accentIron}` }}>
            <div style={{...secTitle, color: T.accentIron }}>Ideal For</div>
            <div style={{ fontFamily: T.fontBody, fontSize:12,
              color: T.textSecondary, lineHeight:1.5 }}>{d.idealFor}</div>
          </div>
          <div style={{ background: T.surfaceElevated, borderRadius: T.rsm,
            padding: T.sm, borderLeft:`3px solid ${T.warningAmber}` }}>
            <div style={{...secTitle, color: T.warningAmber }}>Cautions</div>
            <div style={{ fontFamily: T.fontBody, fontSize:12,
              color: T.textSecondary, lineHeight:1.5 }}>{d.cautions}</div>
          </div>
          <div style={{ height: T.xxl }} />
        </div>
      </div>

      {/* Sticky CTA */}
      <div style={{ padding:`${T.sm}px ${T.md}px`,
        background: T.surfaceHigh, borderTop:`1px solid ${T.divider}` }}>
        <PrimaryButton label="Add Program to My Routines"
          onPress={onStartWorkout} />
      </div>
    </div>
  );
}

Object.assign(window, { TrainScreen, MethodDetailScreen });

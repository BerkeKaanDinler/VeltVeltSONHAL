// VELT — Train Screen
// My Routines + Quick Start + Programs + Program Detail (inline)

const { useState } = React;

const MY_ROUTINES = [
  {
    id:'push-a', name:'Push A', color:'#D97706',
    chips:[{label:'Chest',c:'#D97706'},{label:'Shoulders',c:'#D97706'}],
    exCount:6, duration:'~45m', lastDone:'2d ago',
  },
  {
    id:'pull-a', name:'Pull A', color:'#3B82F6',
    chips:[{label:'Back',c:'#3B82F6'},{label:'Biceps',c:'#3B82F6'}],
    exCount:5, duration:'~50m', lastDone:'4d ago',
  },
  {
    id:'legs-a', name:'Legs A', color:'#22C55E',
    chips:[{label:'Quads',c:'#22C55E'},{label:'Glutes',c:'#22C55E'},{label:'Hams',c:'#22C55E'}],
    exCount:7, duration:'~60m', lastDone:'6d ago',
  },
];

const PROGRAMS = [
  {
    id:'ppl', name:'Push Pull Legs',
    tagline:'Classic 6-day hypertrophy split with PPL movement separation.',
    level:'Intermediate', days:6, goal:'muscle', goalLabel:'Build Muscle',
    description:'PPL trains each muscle group twice per week. High weekly volume on compounds. Best for those with solid technique and recovery capacity.',
    bestFor:'Lifters past their newbie gains, training 6 days a week with good recovery.',
    schedule:[
      {d:'Mon',f:'Push (Chest, Shoulders, Triceps)'},
      {d:'Tue',f:'Pull (Back, Biceps)'},
      {d:'Wed',f:'Legs (Quads, Glutes, Hams)'},
      {d:'Thu',f:'Push'},{d:'Fri',f:'Pull'},{d:'Sat',f:'Legs'},{d:'Sun',f:'Rest'},
    ],
    sampleExercises:['Bench Press','Incline DB Press','Overhead Press','Cable Fly','Triceps Pushdown','Lateral Raise'],
  },
  {
    id:'5x5', name:'StrongLifts 5×5',
    tagline:'Compound strength on a linear progression. Squat every workout.',
    level:'Beginner', days:3, goal:'strength', goalLabel:'Strength',
    description:'Three lifts dominate: Squat, Bench, and Deadlift / Row / OHP. Add 2.5kg every session. Simple, brutal, effective.',
    bestFor:'Total beginners or returning lifters who need a strength base before specialization.',
    schedule:[
      {d:'Mon',f:'Workout A (Squat, Bench, Row)'},
      {d:'Wed',f:'Workout B (Squat, OHP, Deadlift)'},
      {d:'Fri',f:'Workout A'},
      {d:'Tue/Thu/Sat/Sun',f:'Rest'},
    ],
    sampleExercises:['Back Squat','Bench Press','Overhead Press','Barbell Row','Deadlift'],
  },
  {
    id:'ul', name:'Upper Lower',
    tagline:'Balanced 4-day split, twice the frequency on every muscle group.',
    level:'Beginner', days:4, goal:'muscle', goalLabel:'Build Muscle',
    description:'Alternating upper and lower days. Two sessions per muscle weekly. The sweet spot for many intermediate lifters.',
    bestFor:'Anyone with 4 reliable training days and a balanced physique goal.',
    schedule:[
      {d:'Mon',f:'Upper'},{d:'Tue',f:'Lower'},
      {d:'Wed',f:'Rest'},{d:'Thu',f:'Upper'},
      {d:'Fri',f:'Lower'},{d:'Sat/Sun',f:'Rest'},
    ],
    sampleExercises:['Bench Press','Pull-up','Barbell Row','Squat','Romanian Deadlift'],
  },
  {
    id:'531', name:'5/3/1 by Jim Wendler',
    tagline:'Long-term strength on a 4-week wave cycle.',
    level:'Intermediate', days:4, goal:'strength', goalLabel:'Strength',
    description:'Progress your training max slowly. 4-week waves of 5/3/1+ amrap sets. Assistance work via templates (BBB, FSL, etc).',
    bestFor:'Intermediate lifters who hate stalling on linear programs.',
    schedule:[
      {d:'Day 1',f:'Overhead Press 5/3/1'},
      {d:'Day 2',f:'Deadlift 5/3/1'},
      {d:'Day 3',f:'Bench Press 5/3/1'},
      {d:'Day 4',f:'Squat 5/3/1'},
    ],
    sampleExercises:['Overhead Press','Deadlift','Bench Press','Back Squat'],
  },
  {
    id:'nsuns', name:'nSuns 5/3/1 LP',
    tagline:'High-volume 5/3/1 variant for fast intermediates.',
    level:'Advanced', days:6, goal:'strength', goalLabel:'Strength',
    description:'Aggressive volume layered on top of 5/3/1 main work. 9 sets of top lifts daily. Recovery is non-negotiable.',
    bestFor:'Intermediates ready to take a beating and lifters who recover quickly.',
    schedule:[
      {d:'Day 1',f:'Bench + OHP'},
      {d:'Day 2',f:'Squat + Sumo Dl'},
      {d:'Day 3',f:'OHP + Incline'},
      {d:'Day 4',f:'Dl + Front Sq'},
    ],
    sampleExercises:['Bench','Squat','Deadlift','OHP','Incline Bench','Front Squat'],
  },
];

const LEVEL_FILTERS = ['All','Beginner','Intermediate','Advanced'];

/* ══════════════════════════════════════════════════════════
   TRAIN ROOT
══════════════════════════════════════════════════════════ */
function TrainScreen({ onStartWorkout, userGoal='muscle', userLevel='int' }) {
  const [filter, setFilter] = useState('All');
  const [detailProgram, setDetailProgram] = useState(null);

  if (detailProgram) {
    return <ProgramDetail
      program={detailProgram}
      onBack={() => setDetailProgram(null)}
      onAdd={() => { setDetailProgram(null); }}
    />;
  }

  const filtered = filter === 'All'
    ? PROGRAMS
    : PROGRAMS.filter(p => p.level === filter);

  const recommended = PROGRAMS.find(p => p.goal === userGoal) || PROGRAMS[0];
  const userLevelLabel = userLevel === 'beg' ? 'beginner-friendly'
    : userLevel === 'int' ? 'intermediate-level'
    : 'advanced';
  const userGoalLabel = userGoal === 'muscle' ? 'muscle gain'
    : userGoal === 'fat' ? 'fat loss'
    : userGoal === 'strength' ? 'strength'
    : 'endurance';

  return (
    <div style={{ flex: 1, overflowY:'auto', background: T.surface }}>
      <ScreenHeader title="Train" />

      <div style={{ padding: `0 ${T.screenH}px`,
        display:'flex', flexDirection:'column',
        gap: T.sectionGap, paddingBottom: T.bottomNavPad }}>

        {/* ═══ MY ROUTINES ═══ */}
        <div>
          <SectionHeader label="MY ROUTINES" action="+ New" onAction={() => {}}/>
          <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
            {MY_ROUTINES.map(r => (
              <RoutineCard key={r.id} routine={r} onStart={onStartWorkout}/>
            ))}
          </div>
        </div>

        {/* ═══ QUICK START ═══ */}
        <QuickStartCard onPress={onStartWorkout}/>

        {/* ═══ DIVIDER ═══ */}
        <div style={{ display:'flex', alignItems:'center', gap: 12,
          padding: '4px 0' }}>
          <div style={{ flex: 1, height: 0.5, background: T.divider }}/>
          <span style={{ fontFamily: T.fontBody, fontSize: 11, fontWeight: 600,
            color: T.textTertiary, letterSpacing: '0.16em',
            textTransform:'uppercase' }}>Explore Programs</span>
          <div style={{ flex: 1, height: 0.5, background: T.divider }}/>
        </div>

        {/* ═══ RECOMMENDATION BANNER ═══ */}
        <div style={{
          background: alpha(T.accentIron, 0.08),
          border: `1px solid ${alpha(T.accentIron, 0.3)}`,
          borderRadius: T.rmd, padding: 14,
          display:'flex', gap: 12, alignItems:'flex-start',
        }}>
          <div style={{ width: 32, height: 32, borderRadius: T.rsm,
            background: alpha(T.accentIron, 0.15),
            display:'flex', alignItems:'center', justifyContent:'center',
            flexShrink: 0 }}>
            <Icon.Bulb c={T.accentIron}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: T.fontBody, fontSize: 12, fontWeight: 700,
              color: T.accentIron, letterSpacing: '0.02em',
              marginBottom: 4 }}>RECOMMENDED FOR YOU</div>
            <div style={{ fontFamily: T.fontBody, fontSize: 13,
              color: T.textPrimary, lineHeight: 1.5 }}>
              Based on your goal ({userGoalLabel}) and {userLevelLabel} status, try{' '}
              <span style={{ color: T.accentIron, fontWeight: 700 }}>
                {recommended.name}
              </span>.
            </div>
          </div>
        </div>

        {/* ═══ FILTERS + PROGRAMS ═══ */}
        <div>
          <div style={{ display:'flex', gap: 6, marginBottom: 12,
            overflowX:'auto', margin: `0 -${T.screenH}px 12px`,
            padding: `0 ${T.screenH}px` }}>
            {LEVEL_FILTERS.map(f => (
              <FilterChip key={f} label={f}
                active={filter === f}
                onPress={() => setFilter(f)}/>
            ))}
          </div>

          <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
            {filtered.map(p => (
              <ProgramCard key={p.id} program={p}
                isGoalMatch={p.goal === userGoal}
                onPress={() => setDetailProgram(p)}/>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   ROUTINE CARD
──────────────────────────────────────────────────────── */
function RoutineCard({ routine, onStart }) {
  const [pressed, setPressed] = useState(false);
  return (
    <div style={{
      position:'relative', overflow:'hidden',
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rmd,
      padding: '14px 14px 14px 18px',
      display:'flex', alignItems:'stretch', gap: T.sm,
    }}>
      {/* Left color bar */}
      <div style={{ position:'absolute', left: 0, top: 0, bottom: 0,
        width: 3, background: routine.color }}/>

      {/* Content */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.01em' }}>{routine.name}</div>

        {/* Muscle chips */}
        <div style={{ display:'flex', gap: 4, flexWrap:'wrap', marginTop: 6 }}>
          {routine.chips.map(c => (
            <span key={c.label} style={{
              fontFamily: T.fontBody, fontSize: 10, fontWeight: 600,
              color: c.c,
              background: alpha(c.c, 0.12),
              padding: '2px 7px',
              borderRadius: T.rfull,
              letterSpacing: '0.02em',
            }}>{c.label}</span>
          ))}
        </div>

        {/* Meta */}
        <div style={{ fontFamily: T.fontBody, fontSize: 10,
          color: T.textTertiary, marginTop: 8, letterSpacing: '0.01em' }}>
          {routine.exCount} ex · {routine.duration} · Done {routine.lastDone}
        </div>
      </div>

      {/* Right column: more + start */}
      <div style={{ display:'flex', flexDirection:'column',
        alignItems:'flex-end', justifyContent:'space-between',
        flexShrink: 0, gap: 8 }}>
        <button style={{ background:'none', border:'none', cursor:'pointer',
          color: T.textTertiary, fontSize: 16, padding: '0 4px',
          letterSpacing: 1 }}>···</button>

        <button onClick={onStart} style={{
          padding: '7px 14px', borderRadius: T.rsm,
          background: routine.color,
          border:'none', color:'#FFF',
          fontFamily: T.fontBody, fontSize: 11, fontWeight: 700,
          cursor:'pointer',
          display:'flex', alignItems:'center', gap: 4,
          letterSpacing: '0.02em',
        }}>
          <Icon.Play c="#FFF" size={9}/>Start
        </button>
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   QUICK START BAR
──────────────────────────────────────────────────────── */
function QuickStartCard({ onPress }) {
  return (
    <Card onPress={onPress} padding={12}>
      <div style={{ display:'flex', alignItems:'center', gap: T.sm }}>
        <div style={{ width: 38, height: 38, borderRadius: T.rsm,
          background: alpha(T.accentIron, 0.15),
          display:'flex', alignItems:'center', justifyContent:'center',
          flexShrink: 0 }}>
          <Icon.Bolt c={T.accentIron}/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: T.textPrimary }}>Empty Workout</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, marginTop: 2 }}>
            Quick session — no routine needed
          </div>
        </div>
        <Icon.Chevron c={T.textTertiary}/>
      </div>
    </Card>
  );
}

/* ────────────────────────────────────────────────────────
   PROGRAM CARD
──────────────────────────────────────────────────────── */
function ProgramCard({ program, isGoalMatch, onPress }) {
  const level = LEVEL_COLORS[program.level];
  const goalColor = GOAL_COLORS[program.goal];
  return (
    <div onClick={onPress} style={{
      background: T.surfaceElevated,
      border: isGoalMatch ? `1.5px solid ${alpha(T.accentIron, 0.5)}` : `0.5px solid ${T.divider}`,
      borderRadius: T.rmd, padding: 14, cursor:'pointer',
      transition:'border-color 200ms',
    }}>
      {/* Top: name + level pill */}
      <div style={{ display:'flex', justifyContent:'space-between',
        alignItems:'flex-start', gap: T.sm, marginBottom: 4 }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.01em' }}>{program.name}</div>
        </div>
        <Pill bg={level.bg} color={level.fg}>{program.level}</Pill>
      </div>

      {/* Tagline */}
      <div style={{ fontFamily: T.fontBody, fontSize: 12,
        color: T.textSecondary, lineHeight: 1.5, marginBottom: 12 }}>
        {program.tagline}
      </div>

      {/* Bottom row: pills + match indicator */}
      <div style={{ display:'flex', alignItems:'center', gap: 6,
        flexWrap:'wrap' }}>
        <Pill bg={T.surfaceHigh}>{program.days}×/week</Pill>
        <Pill bg={alpha(goalColor, 0.12)} color={goalColor}>{program.goalLabel}</Pill>
        <div style={{ flex: 1 }}/>
        {isGoalMatch ? (
          <div style={{ display:'flex', alignItems:'center', gap: 4 }}>
            <Icon.Star c={T.accentIron}/>
            <span style={{ fontFamily: T.fontBody, fontSize: 11, fontWeight: 700,
              color: T.accentIron }}>Your goal</span>
          </div>
        ) : (
          <span style={{ fontFamily: T.fontBody, fontSize: 11, fontWeight: 600,
            color: T.accentIron }}>View details →</span>
        )}
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════
   PROGRAM DETAIL (inline screen)
═══════════════════════════════════════════════════════ */
function ProgramDetail({ program, onBack, onAdd }) {
  const level = LEVEL_COLORS[program.level];
  const goalColor = GOAL_COLORS[program.goal];
  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface }}>

      {/* Header */}
      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.sm}px` }}>
        <button onClick={onBack} style={{
          background:'none', border:'none', cursor:'pointer',
          padding: 4, marginBottom: 12, marginLeft: -4,
          display:'flex', alignItems:'center', gap: 4,
          color: T.textSecondary, fontFamily: T.fontBody,
          fontSize: 13, fontWeight: 500,
        }}>
          <Icon.ArrowLeft c={T.textSecondary} size={18}/>Back
        </button>

        <div style={{ fontFamily: T.fontBody, fontSize: 30,
          fontWeight: 700, color: T.textPrimary, letterSpacing: '-0.035em',
          lineHeight: 1.05, marginBottom: 10 }}>{program.name}</div>

        <div style={{ display:'flex', gap: 6, flexWrap:'wrap', marginBottom: 6 }}>
          <Pill bg={level.bg} color={level.fg}>{program.level}</Pill>
          <Pill bg={T.surfaceHigh}>{program.days}×/week</Pill>
          <Pill bg={alpha(goalColor, 0.12)} color={goalColor}>{program.goalLabel}</Pill>
        </div>
      </div>

      {/* Scrollable body */}
      <div style={{ flex: 1, overflowY:'auto',
        padding: `0 ${T.screenH}px`, paddingBottom: 100 }}>

        <div style={{ fontFamily: T.fontBody, fontSize: 14,
          color: T.textSecondary, lineHeight: 1.65, marginBottom: T.lg }}>
          {program.description}
        </div>

        {/* Best for callout */}
        <div style={{ position:'relative',
          background: T.surfaceElevated, borderRadius: T.rmd,
          padding: '12px 14px', marginBottom: T.lg,
          paddingLeft: 18 }}>
          <div style={{ position:'absolute', left: 0, top: 0, bottom: 0,
            width: 3, background: T.accentIron,
            borderRadius: `${T.rmd}px 0 0 ${T.rmd}px` }}/>
          <SectionLabel style={{ color: T.accentIron, marginBottom: 4 }}>
            BEST FOR
          </SectionLabel>
          <div style={{ fontFamily: T.fontBody, fontSize: 13,
            color: T.textPrimary, lineHeight: 1.5 }}>
            {program.bestFor}
          </div>
        </div>

        {/* Schedule */}
        <div style={{ marginBottom: T.lg }}>
          <SectionHeader label="WEEKLY SCHEDULE"/>
          <Card padding={0}>
            {program.schedule.map((row, i) => (
              <div key={i} style={{
                display:'flex', gap: T.sm,
                padding: '12px 14px',
                borderBottom: i < program.schedule.length - 1
                  ? `0.5px solid ${T.divider}` : 'none',
              }}>
                <span style={{ fontFamily: T.fontBody, fontSize: 12,
                  fontWeight: 700, color: T.accentIron,
                  minWidth: 80 }}>{row.d}</span>
                <span style={{ fontFamily: T.fontBody, fontSize: 13,
                  color: row.f.includes('Rest') ? T.textTertiary : T.textPrimary }}>
                  {row.f}
                </span>
              </div>
            ))}
          </Card>
        </div>

        {/* Sample exercises */}
        <div>
          <SectionHeader label="SAMPLE EXERCISES"/>
          <div style={{ display:'flex', flexDirection:'column', gap: 4 }}>
            {program.sampleExercises.map(ex => (
              <div key={ex} style={{
                background: T.surfaceElevated,
                borderRadius: T.rsm,
                padding: '10px 14px',
                fontFamily: T.fontBody, fontSize: 13, fontWeight: 500,
                color: T.textPrimary,
                display:'flex', alignItems:'center', gap: 8,
              }}>
                <div style={{ width: 4, height: 4, borderRadius:'50%',
                  background: T.accentIron }}/>
                {ex}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Sticky bottom CTA */}
      <div style={{ padding: `12px ${T.screenH}px`,
        background: T.surface,
        borderTop: `0.5px solid ${T.divider}` }}>
        <PrimaryButton label="Add Program to My Routines" onPress={onAdd}/>
      </div>
    </div>
  );
}

window.TrainScreen = TrainScreen;

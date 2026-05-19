// VELT — Active Workout Screen
// Top bar with timer + Rest timer ring banner + Exercise list with SetRows
// + Add Exercise bottom sheet

const { useState, useEffect, useRef } = React;

/* ── Sample workout data ──────────────────────────────── */
const SAMPLE_WORKOUT = [
  {
    id:'bench', name:'Bench Press', muscle:'Chest', equipment:'Barbell', notes:false,
    sets:[
      { type:'W', weight:60,  reps:10, prev:null },
      { type:'1', weight:80,  reps:8,  prev:{w:80,r:8} },
      { type:'2', weight:80,  reps:8,  prev:{w:80,r:8} },
      { type:'3', weight:85,  reps:6,  prev:{w:82.5,r:7} },
    ],
  },
  {
    id:'incline', name:'Incline DB Press', muscle:'Chest', equipment:'Dumbbell', notes:true,
    sets:[
      { type:'1', weight:30, reps:10, prev:{w:27.5,r:10} },
      { type:'2', weight:30, reps:10, prev:{w:27.5,r:10} },
      { type:'3', weight:30, reps:8,  prev:{w:27.5,r:8}  },
    ],
  },
  {
    id:'ohp', name:'Overhead Press', muscle:'Shoulders', equipment:'Barbell', notes:false,
    sets:[
      { type:'1', weight:50, reps:8, prev:{w:50,r:8} },
      { type:'2', weight:50, reps:8, prev:{w:50,r:8} },
      { type:'3', weight:50, reps:6, prev:{w:47.5,r:7} },
    ],
  },
];

const ADD_EXERCISE_CATALOG = [
  { name:'Bench Press',         muscle:'Chest',     equipment:'Barbell' },
  { name:'Incline Bench Press', muscle:'Chest',     equipment:'Barbell' },
  { name:'Dumbbell Fly',        muscle:'Chest',     equipment:'Dumbbell' },
  { name:'Cable Fly',           muscle:'Chest',     equipment:'Cable' },
  { name:'Pull-up',             muscle:'Back',      equipment:'Body' },
  { name:'Barbell Row',         muscle:'Back',      equipment:'Barbell' },
  { name:'Lat Pulldown',        muscle:'Back',      equipment:'Cable' },
  { name:'Cable Row',           muscle:'Back',      equipment:'Cable' },
  { name:'Overhead Press',      muscle:'Shoulders', equipment:'Barbell' },
  { name:'Lateral Raise',       muscle:'Shoulders', equipment:'Dumbbell' },
  { name:'Face Pull',           muscle:'Shoulders', equipment:'Cable' },
  { name:'Barbell Curl',        muscle:'Arms',      equipment:'Barbell' },
  { name:'Hammer Curl',         muscle:'Arms',      equipment:'Dumbbell' },
  { name:'Triceps Pushdown',    muscle:'Arms',      equipment:'Cable' },
  { name:'Skullcrusher',        muscle:'Arms',      equipment:'EZ-bar' },
  { name:'Back Squat',          muscle:'Legs',      equipment:'Barbell' },
  { name:'Front Squat',         muscle:'Legs',      equipment:'Barbell' },
  { name:'Romanian Deadlift',   muscle:'Legs',      equipment:'Barbell' },
  { name:'Leg Press',           muscle:'Legs',      equipment:'Machine' },
  { name:'Calf Raise',          muscle:'Legs',      equipment:'Machine' },
  { name:'Plank',               muscle:'Core',      equipment:'Body' },
  { name:'Hanging Leg Raise',   muscle:'Core',      equipment:'Body' },
  { name:'Cable Crunch',        muscle:'Core',      equipment:'Cable' },
  { name:'Treadmill',           muscle:'Cardio',    equipment:'Machine' },
];

const MUSCLE_CATEGORIES = ['All','Chest','Back','Shoulders','Arms','Legs','Core','Cardio'];

/* ══════════════════════════════════════════════════════════
   ACTIVE WORKOUT SCREEN
══════════════════════════════════════════════════════════ */
function ActiveWorkoutScreen({ routineName='Push A', onFinish }) {
  const [exercises, setExercises] = useState(
    SAMPLE_WORKOUT.map(e => ({ ...e,
      sets: e.sets.map(s => ({ ...s, done: false }))
    }))
  );
  const [elapsed, setElapsed]     = useState(2843); // start at ~47m for demo
  const [restSec, setRestSec]     = useState(null);
  const [restMax, setRestMax]     = useState(90);
  const [showAdd, setShowAdd]     = useState(false);
  const [editingName, setEditing] = useState(false);
  const [name, setName]           = useState(routineName);

  // Elapsed timer tick
  useEffect(() => {
    const t = setInterval(() => setElapsed(s => s + 1), 1000);
    return () => clearInterval(t);
  }, []);

  // Rest countdown
  useEffect(() => {
    if (restSec === null) return;
    if (restSec <= 0) { setRestSec(null); return; }
    const t = setTimeout(() => setRestSec(r => r - 1), 1000);
    return () => clearTimeout(t);
  }, [restSec]);

  function handleSetDone(exId, setIdx, done) {
    setExercises(prev => prev.map(ex =>
      ex.id !== exId ? ex : {
        ...ex,
        sets: ex.sets.map((s,i) => i !== setIdx ? s : { ...s, done })
      }
    ));
    if (done) {
      setRestSec(restMax);
    }
  }

  function handleSetChange(exId, setIdx, field, value) {
    setExercises(prev => prev.map(ex =>
      ex.id !== exId ? ex : {
        ...ex,
        sets: ex.sets.map((s,i) => i !== setIdx ? s : { ...s, [field]: value })
      }
    ));
  }

  function addSet(exId) {
    setExercises(prev => prev.map(ex => {
      if (ex.id !== exId) return ex;
      const last = ex.sets[ex.sets.length - 1];
      return { ...ex, sets: [...ex.sets, {
        type: String(ex.sets.filter(s => /^\d/.test(s.type)).length + 1),
        weight: last?.weight || 0,
        reps:   last?.reps || 0,
        prev: null, done: false,
      }]};
    }));
  }

  function addExercises(picked) {
    setExercises(prev => [
      ...prev,
      ...picked.map(p => ({
        id: p.name.toLowerCase().replace(/\s/g,'-') + Date.now(),
        name: p.name, muscle: p.muscle, equipment: p.equipment, notes: false,
        sets: [{ type:'1', weight:0, reps:0, prev:null, done:false }],
      })),
    ]);
    setShowAdd(false);
  }

  // Calc progress
  const totalSets = exercises.reduce((a,e) => a + e.sets.length, 0);
  const doneSets  = exercises.reduce((a,e) => a + e.sets.filter(s=>s.done).length, 0);
  const pct = totalSets > 0 ? (doneSets / totalSets) * 100 : 0;

  // Elapsed format
  const hh = String(Math.floor(elapsed / 3600)).padStart(2,'0');
  const mm = String(Math.floor((elapsed % 3600) / 60)).padStart(2,'0');
  const ss = String(elapsed % 60).padStart(2,'0');

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, position:'relative', overflow:'hidden' }}>

      {/* ═══ TOP BAR ═══ */}
      <div style={{
        background: T.surface,
        borderBottom: `0.5px solid ${T.divider}`,
      }}>
        <div style={{ padding: `${T.sm}px ${T.md}px`,
          display:'flex', alignItems:'center', gap: T.sm }}>
          {editingName ? (
            <input
              autoFocus
              value={name}
              onChange={e => setName(e.target.value)}
              onBlur={() => setEditing(false)}
              onKeyDown={e => e.key === 'Enter' && setEditing(false)}
              style={{
                flex: 1, background: T.surfaceHigh,
                border: `1px solid ${T.divider}`, borderRadius: T.rxs,
                padding: '6px 10px',
                fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
                color: T.textPrimary, outline:'none',
              }}/>
          ) : (
            <button onClick={() => setEditing(true)} style={{
              flex: 1, minWidth: 0, textAlign:'left',
              background:'none', border:'none', cursor:'pointer', padding: 0,
              fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
              color: T.textPrimary, letterSpacing: '-0.01em',
              overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap',
            }}>{name}</button>
          )}

          <div style={{ fontFamily: T.fontMono, fontSize: 14, fontWeight: 600,
            color: T.accentIron, fontVariantNumeric:'tabular-nums',
            letterSpacing: '-0.02em' }}>
            {hh}:{mm}:{ss}
          </div>

          <button onClick={onFinish} style={{
            background:'none', border:'none', cursor:'pointer',
            color: T.accentIron, fontFamily: T.fontBody,
            fontSize: 13, fontWeight: 700, padding: '4px 8px',
            letterSpacing: '0.01em',
          }}>Finish</button>
        </div>

        {/* Progress line */}
        <ProgressBar pct={pct} color={T.accentIron} height={2}/>
      </div>

      {/* ═══ REST TIMER ═══ */}
      {restSec !== null && (
        <RestTimerBar
          remaining={restSec}
          max={restMax}
          onSkip={() => setRestSec(null)}
          onAdd={() => setRestSec(s => s + 15)}
        />
      )}

      {/* ═══ EXERCISE LIST ═══ */}
      <div style={{ flex: 1, overflowY:'auto' }}>
        <div style={{ padding: `${T.md}px ${T.screenH}px`,
          paddingBottom: 100,
          display:'flex', flexDirection:'column', gap: 16 }}>
          {exercises.map((ex, exIdx) => (
            <ExerciseSection
              key={ex.id}
              exercise={ex}
              onSetDone={(setIdx, done) => handleSetDone(ex.id, setIdx, done)}
              onChange={(setIdx, field, value) => handleSetChange(ex.id, setIdx, field, value)}
              onAddSet={() => addSet(ex.id)}
            />
          ))}
        </div>
      </div>

      {/* ═══ STICKY BOTTOM ═══ */}
      <div style={{
        padding: `10px ${T.screenH}px 14px`,
        background: T.surface,
        borderTop: `0.5px solid ${T.divider}`,
      }}>
        <GhostButton
          label="+ Add Exercise"
          onPress={() => setShowAdd(true)}
          size="lg"
          style={{ width: '100%' }}
        />
      </div>

      {/* ═══ ADD EXERCISE SHEET ═══ */}
      <BottomSheet
        open={showAdd}
        onClose={() => setShowAdd(false)}
        title="Add Exercise"
        height="full"
      >
        <AddExerciseSheet onAdd={addExercises}/>
      </BottomSheet>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   REST TIMER BAR with circular ring
──────────────────────────────────────────────────────── */
function RestTimerBar({ remaining, max, onSkip, onAdd }) {
  const pct = (remaining / max);
  const r = 18;
  const circ = 2 * Math.PI * r;
  const offset = circ * (1 - pct);
  const mm = String(Math.floor(remaining / 60)).padStart(2,'0');
  const ss = String(remaining % 60).padStart(2,'0');
  return (
    <div style={{
      background: alpha(T.accentIron, 0.12),
      border: `1px solid ${alpha(T.accentIron, 0.3)}`,
      borderTopWidth: 0,
      animation:'slideDown 240ms cubic-bezier(0.2,0,0,1)',
      display:'flex', alignItems:'center', gap: T.sm,
      padding: `10px ${T.md}px`,
    }}>
      {/* Ring */}
      <div style={{ position:'relative', width: 44, height: 44, flexShrink: 0 }}>
        <svg width="44" height="44" style={{ position:'absolute', inset: 0 }}>
          <circle cx="22" cy="22" r={r}
            stroke={alpha(T.accentIron, 0.2)} strokeWidth="3" fill="none"/>
          <circle cx="22" cy="22" r={r}
            stroke={T.accentIron} strokeWidth="3" fill="none"
            strokeDasharray={circ.toFixed(2)}
            strokeDashoffset={offset.toFixed(2)}
            strokeLinecap="round"
            transform="rotate(-90 22 22)"
            style={{ transition:'stroke-dashoffset 950ms linear' }}/>
        </svg>
        <div style={{ position:'absolute', inset: 0, display:'flex',
          alignItems:'center', justifyContent:'center',
          fontFamily: T.fontMono, fontSize: 11, fontWeight: 700,
          color: T.accentIron, fontVariantNumeric:'tabular-nums',
          letterSpacing: '-0.02em' }}>
          {mm}:{ss}
        </div>
      </div>

      {/* Label */}
      <div style={{ flex: 1 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
          color: T.textPrimary }}>Rest</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 11,
          color: T.textTertiary, marginTop: 1 }}>
          Until your next set
        </div>
      </div>

      {/* +15 chip */}
      <button onClick={onAdd} style={{
        background: T.surfaceHigh, border:`0.5px solid ${T.divider}`,
        borderRadius: T.rfull, padding: '5px 10px',
        fontFamily: T.fontBody, fontSize: 11, fontWeight: 700,
        color: T.textSecondary, cursor:'pointer',
      }}>+15s</button>

      {/* Skip */}
      <button onClick={onSkip} style={{
        background:'none', border:'none', cursor:'pointer',
        color: T.textTertiary, fontFamily: T.fontBody,
        fontSize: 12, fontWeight: 600, padding: '5px 4px',
      }}>Skip</button>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   EXERCISE SECTION
──────────────────────────────────────────────────────── */
function ExerciseSection({ exercise, onSetDone, onChange, onAddSet }) {
  return (
    <div style={{
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rmd, overflow:'hidden',
    }}>
      {/* Header */}
      <div style={{
        padding: `12px ${T.md}px`,
        borderBottom: `0.5px solid ${T.divider}`,
        display:'flex', alignItems:'center', gap: T.xs,
      }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 16, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.01em' }}>
            {exercise.name}
          </div>
          <div style={{ display:'flex', gap: 4, marginTop: 4 }}>
            <Pill bg={T.surfaceHigh}>{exercise.muscle}</Pill>
            <Pill bg={T.surfaceHigh}>{exercise.equipment}</Pill>
          </div>
        </div>
        <button style={{ background:'none', border:'none', cursor:'pointer',
          width: 28, height: 28, display:'flex',
          alignItems:'center', justifyContent:'center' }}>
          <Icon.Note c={exercise.notes ? T.accentIron : T.textTertiary}/>
        </button>
        <button style={{ background:'none', border:'none', cursor:'pointer',
          width: 28, height: 28, display:'flex',
          alignItems:'center', justifyContent:'center' }}>
          <Icon.Drag c={T.textTertiary}/>
        </button>
      </div>

      {/* Column headers */}
      <div style={{ display:'grid',
        gridTemplateColumns:'32px 1fr 80px 80px 44px',
        gap: 6, padding: `8px ${T.md}px 6px`,
        fontFamily: T.fontBody, fontSize: 9, fontWeight: 700,
        color: T.textTertiary, letterSpacing: '0.08em',
        textTransform:'uppercase',
      }}>
        <div style={{ textAlign:'center' }}>Set</div>
        <div>Prev</div>
        <div style={{ textAlign:'center' }}>Weight</div>
        <div style={{ textAlign:'center' }}>Reps</div>
        <div/>
      </div>

      {/* Set rows */}
      {exercise.sets.map((set, i) => (
        <SetRow
          key={i}
          set={set}
          setIndex={i}
          onChange={(field, value) => onChange(i, field, value)}
          onDone={done => onSetDone(i, done)}
        />
      ))}

      {/* Add Set */}
      <button onClick={onAddSet} style={{
        width: '100%', padding: '10px',
        background: 'none',
        border:'none',
        borderTop: `0.5px dashed ${T.divider}`,
        color: T.textTertiary, fontFamily: T.fontBody,
        fontSize: 12, fontWeight: 600, cursor:'pointer',
      }}>+ Add Set</button>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   SET ROW
──────────────────────────────────────────────────────── */
function SetRow({ set, setIndex, onChange, onDone }) {
  const [weight, setWeight] = useState(set.weight);
  const [reps, setReps]     = useState(set.reps);
  const done = set.done;

  function pushWeight(v) {
    const next = Math.max(0, parseFloat((v).toFixed(1)));
    setWeight(next); onChange('weight', next);
  }
  function pushReps(v) {
    const next = Math.max(0, v|0);
    setReps(next); onChange('reps', next);
  }

  const badgeColor = set.type === 'W' ? T.accentIron
    : set.type === 'D' ? T.textTertiary
    : set.type === 'F' ? T.errorRose
    : null;
  const isNumeric = /^\d+$/.test(set.type);

  return (
    <div style={{
      display:'grid',
      gridTemplateColumns:'32px 1fr 80px 80px 44px',
      gap: 6, padding: `8px ${T.md}px`,
      alignItems:'center',
      background: done ? alpha(T.successLime, 0.04) : 'transparent',
      borderTop: `0.5px solid ${alpha(T.divider, 0.5)}`,
      opacity: done ? 0.85 : 1,
      transition:'background 200ms, opacity 200ms',
    }}>
      {/* Set badge */}
      <div style={{ textAlign:'center' }}>
        {isNumeric ? (
          <span style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: done ? T.successLime : T.textSecondary,
            fontVariantNumeric:'tabular-nums' }}>{set.type}</span>
        ) : (
          <span style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 800,
            color: badgeColor, background: alpha(badgeColor, 0.15),
            padding: '2px 6px', borderRadius: T.rxs,
            letterSpacing: '0.05em' }}>{set.type}</span>
        )}
      </div>

      {/* Prev */}
      <div style={{ fontFamily: T.fontBody, fontSize: 11,
        color: T.textTertiary, fontVariantNumeric:'tabular-nums' }}>
        {set.prev
          ? <>PREV: <span style={{ color: T.textSecondary }}>
              {set.prev.w}kg × {set.prev.r}
            </span></>
          : <span style={{ color: T.textTertiary }}>—</span>}
      </div>

      {/* Weight */}
      <Stepper value={weight} step={2.5} unit="kg" onChange={pushWeight} done={done}/>

      {/* Reps */}
      <Stepper value={reps} step={1} unit="" onChange={pushReps} done={done}/>

      {/* Check */}
      <button onClick={() => onDone(!done)} style={{
        width: 36, height: 36, marginLeft: 4,
        borderRadius:'50%',
        border: done ? 'none' : `1.5px solid ${T.divider}`,
        background: done ? T.successLime : 'transparent',
        display:'flex', alignItems:'center', justifyContent:'center',
        cursor:'pointer',
        transition:'all 200ms',
        justifySelf:'end',
      }}>
        {done && <Icon.Check c={T.surface} sw={2.6}/>}
      </button>
    </div>
  );
}

/* ── Compact stepper for weight/reps ──────────────────── */
function Stepper({ value, step, unit, onChange, done }) {
  return (
    <div style={{
      background: T.surface,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rxs,
      height: 36,
      display:'flex', alignItems:'center', justifyContent:'space-between',
    }}>
      <button onClick={() => onChange(value - step)} style={{
        width: 22, height:'100%', background:'none', border:'none',
        cursor:'pointer', color: T.textTertiary,
        fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
      }}>−</button>
      <div style={{
        fontFamily: T.fontMono, fontSize: 13, fontWeight: 700,
        color: done ? T.successLime : T.textPrimary,
        fontVariantNumeric:'tabular-nums',
        display:'flex', alignItems:'baseline', gap: 2,
      }}>
        {value % 1 === 0 ? value : value.toFixed(1)}
        {unit && <span style={{ fontSize: 9, color: T.textTertiary,
          fontWeight: 500 }}>{unit}</span>}
      </div>
      <button onClick={() => onChange(value + step)} style={{
        width: 22, height:'100%', background:'none', border:'none',
        cursor:'pointer', color: T.textTertiary,
        fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
      }}>+</button>
    </div>
  );
}

/* ════════════════════════════════════════════════════════
   ADD EXERCISE SHEET
═══════════════════════════════════════════════════════ */
function AddExerciseSheet({ onAdd }) {
  const [query, setQuery]       = useState('');
  const [category, setCategory] = useState('All');
  const [picked, setPicked]     = useState([]);

  const filtered = ADD_EXERCISE_CATALOG.filter(e => {
    const q = query.toLowerCase().trim();
    const matchQ = !q || e.name.toLowerCase().includes(q);
    const matchC = category === 'All' || e.muscle === category;
    return matchQ && matchC;
  });

  function toggle(ex) {
    setPicked(p => p.find(x => x.name === ex.name)
      ? p.filter(x => x.name !== ex.name)
      : [...p, ex]
    );
  }

  return (
    <div style={{ display:'flex', flexDirection:'column', height:'100%' }}>
      {/* Search */}
      <div style={{ padding: `0 ${T.md}px ${T.sm}px` }}>
        <input
          placeholder="Search exercises…"
          value={query}
          onChange={e => setQuery(e.target.value)}
          style={{
            width:'100%', background: T.surfaceHigh,
            border: `0.5px solid ${T.divider}`,
            borderRadius: T.rsm,
            padding: '10px 14px',
            fontFamily: T.fontBody, fontSize: 13,
            color: T.textPrimary, outline:'none',
          }}/>
      </div>

      {/* Category chips */}
      <div style={{ display:'flex', gap: 6, overflowX:'auto',
        padding: `0 ${T.md}px ${T.sm}px` }}>
        {MUSCLE_CATEGORIES.map(c => (
          <FilterChip key={c} label={c}
            active={category === c} onPress={() => setCategory(c)}/>
        ))}
      </div>

      {/* List */}
      <div style={{ flex: 1, overflowY:'auto',
        padding: `0 ${T.md}px ${picked.length ? 80 : 12}px` }}>
        {filtered.map(ex => {
          const isPicked = picked.find(x => x.name === ex.name);
          return (
            <div key={ex.name} onClick={() => toggle(ex)} style={{
              display:'flex', alignItems:'center', gap: T.sm,
              padding: '12px 8px',
              borderBottom: `0.5px solid ${T.divider}`,
              cursor:'pointer',
              background: isPicked ? alpha(T.accentIron, 0.05) : 'transparent',
              borderRadius: T.rxs,
              marginBottom: 2,
            }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: T.fontBody, fontSize: 14,
                  fontWeight: 600, color: T.textPrimary }}>{ex.name}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 11,
                  color: T.textTertiary, marginTop: 2 }}>
                  {ex.muscle} · {ex.equipment}
                </div>
              </div>
              <div style={{
                width: 28, height: 28, borderRadius:'50%',
                background: isPicked ? T.accentIron : T.surfaceHigh,
                border: isPicked ? 'none' : `0.5px solid ${T.divider}`,
                display:'flex', alignItems:'center', justifyContent:'center',
                flexShrink: 0, transition:'all 150ms',
              }}>
                {isPicked
                  ? <Icon.Check c="#FFF" sw={2.4}/>
                  : <Icon.Plus c={T.textSecondary}/>
                }
              </div>
            </div>
          );
        })}
        {filtered.length === 0 && (
          <div style={{ textAlign:'center', padding: 30,
            fontFamily: T.fontBody, fontSize: 13,
            color: T.textTertiary }}>
            No exercises match.
          </div>
        )}
      </div>

      {/* Sticky add bar */}
      {picked.length > 0 && (
        <div style={{
          position:'absolute', bottom: 0, left: 0, right: 0,
          padding: `12px ${T.md}px`,
          background: T.surfaceHigh,
          borderTop: `0.5px solid ${T.divider}`,
        }}>
          <PrimaryButton
            label={`Add ${picked.length} exercise${picked.length === 1 ? '' : 's'}`}
            onPress={() => onAdd(picked)}
          />
        </div>
      )}
    </div>
  );
}

window.ActiveWorkoutScreen = ActiveWorkoutScreen;

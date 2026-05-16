// VELT — Active Workout Screen + Workout Summary

const { useState, useEffect, useRef } = React;

/* ── Sample workout data ──────────────────────────────── */
const WORKOUT_DATA = [
  {
    id: 'bench', name: 'Bench Press', muscle: 'Chest', equipment: 'Barbell',
    sets: [
      { type:'W', weight:60,  reps:10, prev:null,                done:false },
      { type:'N', weight:80,  reps:8,  prev:{weight:80,reps:8},  done:false },
      { type:'N', weight:80,  reps:8,  prev:{weight:80,reps:8},  done:false },
      { type:'N', weight:80,  reps:6,  prev:{weight:77.5,reps:7},done:false },
    ]
  },
  {
    id: 'incline', name: 'Incline DB Press', muscle: 'Chest', equipment: 'Dumbbell',
    sets: [
      { type:'N', weight:30,  reps:10, prev:{weight:27.5,reps:10},done:false },
      { type:'N', weight:30,  reps:10, prev:{weight:27.5,reps:10},done:false },
      { type:'N', weight:30,  reps:8,  prev:{weight:27.5,reps:8}, done:false },
    ]
  },
  {
    id: 'ohp', name: 'Overhead Press', muscle: 'Shoulders', equipment: 'Barbell',
    sets: [
      { type:'N', weight:50,  reps:8,  prev:{weight:50,reps:8},  done:false },
      { type:'N', weight:50,  reps:8,  prev:{weight:50,reps:8},  done:false },
      { type:'N', weight:50,  reps:6,  prev:{weight:47.5,reps:7},done:false },
    ]
  },
];

/* ══════════════════════════════════════════════════════════
   ACTIVE WORKOUT SCREEN
══════════════════════════════════════════════════════════ */
function ActiveWorkoutScreen({ routineName, onFinish }) {
  const [exercises, setExercises]       = useState(WORKOUT_DATA.map(e => ({
    ...e, sets: e.sets.map(s => ({ ...s }))
  })));
  const [currentExIdx, setCurrentExIdx] = useState(0);
  const [restSeconds, setRestSeconds]   = useState(null);
  const [elapsedSecs, setElapsedSecs]   = useState(0);
  const [showMenu, setShowMenu]         = useState(false);

  // Elapsed timer
  useEffect(() => {
    const t = setInterval(() => setElapsedSecs(s => s + 1), 1000);
    return () => clearInterval(t);
  }, []);

  const elapsed = (() => {
    const m = String(Math.floor(elapsedSecs / 60)).padStart(2,'0');
    const s = String(elapsedSecs % 60).padStart(2,'0');
    return `${m}:${s}`;
  })();

  function handleSetComplete(exIdx, setIdx, done) {
    setExercises(prev => {
      const next = prev.map((ex,i) => i !== exIdx ? ex : {
        ...ex,
        sets: ex.sets.map((s,j) => j !== setIdx ? s : { ...s, done })
      });
      return next;
    });
    if (done) {
      setRestSeconds(90);
      // auto-advance exercise if all sets done
      const ex = exercises[exIdx];
      const allDone = ex.sets.every((s, j) => j === setIdx || s.done);
      if (allDone && exIdx < exercises.length - 1) {
        setTimeout(() => setCurrentExIdx(i => i + 1), 400);
      }
    } else {
      setRestSeconds(null);
    }
  }

  function addSet(exIdx) {
    setExercises(prev => prev.map((ex, i) => i !== exIdx ? ex : {
      ...ex,
      sets: [...ex.sets, {
        type:'N',
        weight: ex.sets[ex.sets.length - 1]?.weight || 0,
        reps:   ex.sets[ex.sets.length - 1]?.reps || 0,
        prev: null, done: false
      }]
    }));
  }

  const currentEx = exercises[currentExIdx];
  const upNext    = exercises.slice(currentExIdx + 1);

  const totalSets = exercises.reduce((a,e) => a + e.sets.length, 0);
  const doneSets  = exercises.reduce((a,e) => a + e.sets.filter(s=>s.done).length, 0);

  return (
    <div style={{ flex:1, display:'flex', flexDirection:'column',
      background: T.surface, position:'relative', overflow:'hidden' }}>

      {/* Top bar */}
      <div style={{ padding:`${T.sm}px ${T.md}px`,
        display:'flex', alignItems:'center', justifyContent:'space-between',
        borderBottom:`1px solid ${T.divider}`,
        background: T.surface }}>
        <div style={{ fontFamily:T.fontDisplay, fontSize:15, fontWeight:700,
          color:T.textPrimary, flex:1, letterSpacing:'-0.01em',
          overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap',
          maxWidth:180 }}>{routineName || 'Workout'}</div>
        <div style={{ fontFamily:T.fontDisplay, fontSize:16, color:T.textSecondary,
          fontVariantNumeric:'tabular-nums', letterSpacing:'-0.02em',
          marginRight: T.sm }}>{elapsed}</div>
        <button onClick={() => setShowMenu(m => !m)} style={{
          background:'none', border:'none', cursor:'pointer',
          color: T.textTertiary, fontSize:20, width:36, height:36,
          display:'flex', alignItems:'center', justifyContent:'center',
        }}>⋯</button>
      </div>

      {/* Rest timer */}
      {restSeconds && (
        <RestTimerBanner
          seconds={restSeconds}
          onSkip={() => setRestSeconds(null)}
          onAdd={() => setRestSeconds(s => s + 15)}
        />
      )}

      {/* Scrollable content */}
      <div style={{ flex:1, overflowY:'auto' }}>

        {/* Progress bar */}
        <div style={{ height:3, background: T.divider }}>
          <div style={{ height:'100%', background: T.accentIron,
            width:`${totalSets > 0 ? (doneSets/totalSets)*100 : 0}%`,
            transition:'width 300ms ease-out' }} />
        </div>

        {/* Current exercise */}
        <div style={{ margin:`${T.md}px`, background: T.surfaceElevated,
          borderRadius: T.rmd, overflow:'hidden',
          borderLeft:`3px solid ${T.accentIron}` }}>
          <div style={{ padding:`${T.sm}px ${T.md}px`,
            borderBottom:`1px solid ${T.divider}` }}>
            <div style={{ fontFamily:T.fontDisplay, fontSize:18, fontWeight:700,
              color:T.textPrimary, letterSpacing:'-0.015em' }}>{currentEx.name}</div>
            <div style={{ display:'flex', alignItems:'center', gap: T.sm, marginTop:3 }}>
              <span style={{ fontFamily:T.fontBody, fontSize:11,
                color:T.textSecondary }}>{currentEx.muscle} · {currentEx.equipment}</span>
              {currentEx.sets[0]?.prev && (
                <span style={{ fontFamily:T.fontBody, fontSize:10, fontWeight:600,
                  color:T.textTertiary, background:T.surfaceHigh,
                  padding:'2px 7px', borderRadius:T.rfull }}>
                  Last: {currentEx.sets[0].prev.weight} × {currentEx.sets[0].prev.reps}
                </span>
              )}
            </div>
          </div>

          {/* Set row header */}
          <div style={{ display:'grid',
            gridTemplateColumns:'32px 1fr 1fr 1fr 48px',
            gap: T.xs, padding:`6px ${T.md}px`,
            borderBottom:`1px solid ${T.divider}22` }}>
            {['Set','Prev','Weight','Reps',''].map(h => (
              <div key={h} style={{ fontFamily:T.fontBody, fontSize:9,
                fontWeight:700, color:T.textTertiary,
                letterSpacing:'0.07em', textTransform:'uppercase',
                textAlign:'center' }}>{h}</div>
            ))}
          </div>

          {/* Set rows */}
          {currentEx.sets.map((set, j) => (
            <SetRow
              key={j}
              set={set}
              setIndex={j}
              active={!set.done && j === currentEx.sets.findIndex(s => !s.done)}
              onComplete={(idx, done) => handleSetComplete(currentExIdx, idx, done)}
            />
          ))}

          {/* Add set */}
          <button onClick={() => addSet(currentExIdx)} style={{
            width:'100%', padding:`${T.sm}px`, background:'none',
            border:`1px dashed ${T.divider}`, borderRadius:0,
            color:T.textTertiary, fontFamily:T.fontBody, fontSize:12,
            fontWeight:600, cursor:'pointer',
            borderTop:`1px solid ${T.divider}`,
          }}>+ Add Set</button>
        </div>

        {/* Exercise nav */}
        {exercises.length > 1 && (
          <div style={{ display:'flex', gap: T.xs, padding:`0 ${T.md}px`,
            marginBottom: T.sm, overflowX:'auto' }}>
            {exercises.map((ex, i) => {
              const allDone = ex.sets.every(s => s.done);
              return (
                <button key={ex.id} onClick={() => setCurrentExIdx(i)} style={{
                  padding:'6px 14px', borderRadius:20, border:'none',
                  background: i === currentExIdx
                    ? T.accentIron
                    : allDone ? `${T.successLime}22` : T.surfaceHigh,
                  color: i === currentExIdx ? '#fff'
                    : allDone ? T.successLime : T.textSecondary,
                  fontFamily:T.fontBody, fontSize:11, fontWeight:600,
                  cursor:'pointer', whiteSpace:'nowrap', flexShrink:0,
                  transition:'background 150ms',
                }}>
                  {allDone ? '✓ ' : ''}{ex.name.split(' ')[0]}
                </button>
              );
            })}
          </div>
        )}

        {/* Up next */}
        {upNext.length > 0 && (
          <div style={{ padding:`0 ${T.md}px`, marginBottom: T.md }}>
            <SectionHeader label="Up Next" />
            <div style={{ display:'flex', flexDirection:'column', gap: T.xs }}>
              {upNext.slice(0,2).map(ex => (
                <div key={ex.id} style={{ background: T.surfaceElevated,
                  borderRadius: T.rsm, padding:`${T.xs}px ${T.sm}px`,
                  display:'flex', justifyContent:'space-between',
                  alignItems:'center' }}>
                  <span style={{ fontFamily:T.fontBody, fontSize:13,
                    color:T.textSecondary }}>{ex.name}</span>
                  <span style={{ fontFamily:T.fontBody, fontSize:11,
                    color:T.textTertiary }}>{ex.sets.length} sets</span>
                </div>
              ))}
            </div>
          </div>
        )}

        <div style={{ height: 80 }} />
      </div>

      {/* Sticky bottom */}
      <div style={{ padding:`${T.sm}px ${T.md}px`,
        background: T.surfaceElevated,
        borderTop:`1px solid ${T.divider}` }}>
        <PrimaryButton label="Finish Workout" onPress={onFinish} />
      </div>

      {/* Menu overlay */}
      {showMenu && (
        <div onClick={() => setShowMenu(false)} style={{
          position:'absolute', inset:0, background:'#0008',
          zIndex:20, display:'flex', flexDirection:'column',
          justifyContent:'flex-start', paddingTop:60,
        }}>
          <div onClick={e => e.stopPropagation()} style={{
            background: T.surfaceHigh, margin:`0 ${T.md}px`,
            borderRadius: T.rmd, overflow:'hidden',
          }}>
            {[
              { label:'Add Exercise', color:T.textPrimary },
              { label:'Add Note',     color:T.textPrimary },
              { label:'Cancel Workout', color:T.errorRose },
            ].map(item => (
              <button key={item.label} onClick={() => {
                setShowMenu(false);
                if (item.label === 'Cancel Workout') onFinish();
              }} style={{
                width:'100%', padding:`${T.md}px`, background:'none',
                border:'none', borderBottom:`1px solid ${T.divider}`,
                color:item.color, fontFamily:T.fontBody, fontSize:15,
                fontWeight:500, cursor:'pointer', textAlign:'left',
              }}>{item.label}</button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

/* ══════════════════════════════════════════════════════════
   WORKOUT SUMMARY
══════════════════════════════════════════════════════════ */
function WorkoutSummaryScreen({ onDone }) {
  const [showPR, setShowPR] = useState(false);
  useEffect(() => {
    const t = setTimeout(() => setShowPR(true), 400);
    return () => clearTimeout(t);
  }, []);

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface,
      display:'flex', flexDirection:'column' }}>
      <div style={{ padding:`${T.xxl}px ${T.md}px ${T.xl}px` }}>

        <div style={{ fontFamily:T.fontBody, fontSize:12, fontWeight:700,
          color:T.successLime, letterSpacing:'0.1em',
          textTransform:'uppercase', marginBottom: T.sm }}>Workout Complete</div>

        <div style={{ fontFamily:T.fontDisplay, fontSize:34, fontWeight:700,
          color:T.textPrimary, letterSpacing:'-0.03em',
          lineHeight:1.1, marginBottom: T.xl }}>Push A</div>

        {/* Stats row */}
        <div style={{ display:'flex', gap: T.sm, marginBottom: T.xl }}>
          {[
            { v:'48', u:'min', l:'Duration' },
            { v:'9,840', u:'kg', l:'Volume' },
            { v:'11', u:'', l:'Sets' },
          ].map(s => <StatCard key={s.l} value={s.v} unit={s.u} label={s.l} />)}
        </div>

        {/* PR badge */}
        {showPR && (
          <div style={{
            background: `linear-gradient(135deg, ${T.accentIronSoft}, ${T.accentIron}44)`,
            border:`1px solid ${T.accentIron}66`,
            borderRadius: T.rmd, padding: T.md,
            display:'flex', alignItems:'center', gap: T.sm,
            marginBottom: T.xl,
            animation:'fadeSlideIn 0.6s cubic-bezier(0.2,0,0,1.0)',
          }}>
            <div style={{ width:36, height:36, borderRadius:T.rfull,
              background: T.accentIron, display:'flex',
              alignItems:'center', justifyContent:'center', flexShrink:0 }}>
              <span style={{ fontSize:18 }}>🏆</span>
            </div>
            <div>
              <div style={{ fontFamily:T.fontDisplay, fontSize:14, fontWeight:700,
                color:T.accentIron, letterSpacing:'-0.01em' }}>Personal Record</div>
              <div style={{ fontFamily:T.fontBody, fontSize:12,
                color:T.textSecondary }}>Bench Press — 102.5 kg × 5</div>
            </div>
          </div>
        )}

        {/* Exercise breakdown */}
        <SectionHeader label="Exercises" />
        <div style={{ display:'flex', flexDirection:'column', gap: T.xs }}>
          {WORKOUT_DATA.map(ex => (
            <div key={ex.id} style={{ background: T.surfaceElevated,
              borderRadius: T.rsm, padding:`${T.sm}px ${T.md}px`,
              display:'flex', justifyContent:'space-between', alignItems:'center' }}>
              <div>
                <div style={{ fontFamily:T.fontDisplay, fontSize:14, fontWeight:700,
                  color:T.textPrimary }}>{ex.name}</div>
                <div style={{ fontFamily:T.fontBody, fontSize:11,
                  color:T.textSecondary, marginTop:1 }}>
                  {ex.sets.length} sets
                </div>
              </div>
              <div style={{ textAlign:'right' }}>
                <div style={{ fontFamily:T.fontDisplay, fontSize:15, fontWeight:700,
                  color:T.accentIron, fontVariantNumeric:'tabular-nums' }}>
                  {ex.sets[1]?.weight || ex.sets[0]?.weight} kg
                </div>
                <div style={{ fontFamily:T.fontBody, fontSize:10,
                  color:T.textTertiary }}>top set</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: T.xl }}>
          <PrimaryButton label="Done" onPress={onDone} />
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ActiveWorkoutScreen, WorkoutSummaryScreen });

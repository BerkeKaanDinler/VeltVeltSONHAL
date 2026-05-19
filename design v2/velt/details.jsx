// VELT — Detail Screens
// Exports: WorkoutDetailScreen, ExerciseDetailScreen, PRDetailScreen
// All three deep-dive screens share visual language: sticky header w/ back +
// large title + sticky stats + scrollable body

const { useState } = React;

/* ════════════════════════════════════════════════════════════
   SHARED DETAIL HEADER
══════════════════════════════════════════════════════════════ */
function DetailHeader({ onBack, eyebrow, title, subtitle, right }) {
  return (
    <div style={{
      position:'sticky', top: 0, zIndex: 10,
      padding: `${T.sm}px ${T.screenH}px ${T.md}px`,
      background: T.surface,
      borderBottom: `0.5px solid ${alpha(T.divider, 0.6)}`,
    }}>
      <div style={{ display:'flex', alignItems:'center', gap: T.sm,
        marginBottom: 10 }}>
        <button onClick={onBack} style={{
          background:'none', border:'none', cursor:'pointer',
          padding: 6, marginLeft: -6,
          display:'flex', alignItems:'center', gap: 4,
          color: T.textSecondary, fontFamily: T.fontBody,
          fontSize: 13, fontWeight: 500,
        }}>
          <Icon.ArrowLeft c={T.textSecondary} size={18}/>
        </button>
        <div style={{ flex: 1 }}/>
        {right}
      </div>

      {eyebrow && (
        <div style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 700,
          color: T.accentIron, letterSpacing: '0.1em',
          textTransform:'uppercase', marginBottom: 4 }}>{eyebrow}</div>
      )}
      <div style={{ fontFamily: T.fontBody, fontSize: 26, fontWeight: 700,
        color: T.textPrimary, letterSpacing: '-0.035em', lineHeight: 1.1 }}>
        {title}
      </div>
      {subtitle && (
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: T.textTertiary, marginTop: 4 }}>{subtitle}</div>
      )}
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   WORKOUT DETAIL SCREEN
══════════════════════════════════════════════════════════════ */
function WorkoutDetailScreen({ onBack }) {
  const workout = {
    name: 'Pull A — Back & Biceps',
    date: 'Yesterday · 6:24 PM',
    duration: '52 min',
    volume: '12,440 kg',
    sets: 18,
    prs: 2,
    avgRest: '94s',
    exercises: [
      {
        name:'Deadlift', muscle:'Back',
        sets:[
          { type:'W', w:80,  r:8 },
          { type:'1', w:140, r:5 },
          { type:'2', w:160, r:5 },
          { type:'3', w:172.5, r:3, pr:true },
        ]
      },
      {
        name:'Pull-up', muscle:'Back',
        sets:[
          { type:'1', w:'BW', r:8 },
          { type:'2', w:'BW+10', r:6 },
          { type:'3', w:'BW+15', r:5, pr:true },
        ]
      },
      {
        name:'Barbell Row', muscle:'Back',
        sets:[
          { type:'1', w:80, r:8 },
          { type:'2', w:80, r:8 },
          { type:'3', w:80, r:7 },
        ]
      },
      {
        name:'Cable Row', muscle:'Back',
        sets:[
          { type:'1', w:60, r:10 },
          { type:'2', w:60, r:10 },
          { type:'3', w:65, r:8 },
        ]
      },
      {
        name:'Barbell Curl', muscle:'Arms',
        sets:[
          { type:'1', w:30, r:10 },
          { type:'2', w:30, r:9 },
          { type:'3', w:30, r:8 },
        ]
      },
      {
        name:'Hammer Curl', muscle:'Arms',
        sets:[
          { type:'1', w:14, r:12 },
          { type:'2', w:14, r:12 },
        ]
      },
    ],
    note: 'Felt strong today. Going to bump deadlift TM next week.',
  };

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, overflowY:'auto' }}>

      <DetailHeader
        onBack={onBack}
        eyebrow="COMPLETED WORKOUT"
        title={workout.name}
        subtitle={workout.date}
        right={<GhostButton label="Share" size="sm" onPress={() => {}}/>}
      />

      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.bottomNavPad}px`,
        display:'flex', flexDirection:'column', gap: T.sectionGap }}>

        {/* Stats grid */}
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr',
          gap: 8 }}>
          <DetailStatTile label="Duration" value={workout.duration}/>
          <DetailStatTile label="Volume"   value={workout.volume}/>
          <DetailStatTile label="Sets"     value={workout.sets}/>
          <DetailStatTile label="PRs"      value={workout.prs}
            accent={workout.prs > 0}/>
        </div>

        {/* Avg rest pill */}
        <div style={{ display:'flex', justifyContent:'center',
          marginTop: -10 }}>
          <Pill bg={T.surfaceHigh}>
            <Icon.Timer c={T.textSecondary}/>
            <span style={{ marginLeft: 4 }}>
              Avg rest: <span style={{ color: T.textPrimary,
                fontWeight: 700 }}>{workout.avgRest}</span>
            </span>
          </Pill>
        </div>

        {/* PRs callout if any */}
        {workout.prs > 0 && (
          <div>
            <SectionHeader label={`${workout.prs} NEW PERSONAL RECORDS`}/>
            <div style={{ display:'flex', flexDirection:'column', gap: 8 }}>
              {workout.exercises.flatMap(ex =>
                ex.sets.filter(s => s.pr).map((s, i) => (
                  <div key={`${ex.name}-${i}`} style={{
                    background: alpha(T.accentIron, 0.08),
                    border: `1px solid ${alpha(T.accentIron, 0.3)}`,
                    borderRadius: T.rmd, padding: 12,
                    display:'flex', alignItems:'center', gap: 10,
                  }}>
                    <div style={{ width: 30, height: 30, borderRadius:'50%',
                      background: alpha(T.accentIron, 0.18),
                      display:'flex', alignItems:'center', justifyContent:'center',
                      flexShrink: 0 }}>
                      <Icon.Trophy c={T.accentIron} size={14}/>
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: T.fontBody, fontSize: 13,
                        fontWeight: 700, color: T.textPrimary }}>{ex.name}</div>
                      <div style={{ fontFamily: T.fontBody, fontSize: 11,
                        color: T.accentIron, marginTop: 2,
                        fontVariantNumeric:'tabular-nums', fontWeight: 600 }}>
                        {typeof s.w === 'string' ? s.w : `${s.w} kg`} × {s.r}
                      </div>
                    </div>
                    <Pill bg={T.accentIron} color="#FFF"
                      style={{ fontSize: 9, fontWeight: 800 }}>NEW PR</Pill>
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* Note */}
        {workout.note && (
          <div>
            <SectionHeader label="SESSION NOTE"/>
            <Card padding={14}>
              <div style={{ fontFamily: T.fontBody, fontSize: 13,
                color: T.textSecondary, lineHeight: 1.55,
                fontStyle:'italic' }}>"{workout.note}"</div>
            </Card>
          </div>
        )}

        {/* Exercises */}
        <div>
          <SectionHeader label="EXERCISES"/>
          <div style={{ display:'flex', flexDirection:'column', gap: 10 }}>
            {workout.exercises.map((ex, i) => (
              <ExerciseDetailCard key={i} exercise={ex}/>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}

function DetailStatTile({ label, value, accent }) {
  return (
    <div style={{
      padding: 14,
      background: T.surfaceElevated,
      border: accent ? `1px solid ${T.accentIron}` : `0.5px solid ${T.divider}`,
      borderRadius: T.rmd,
    }}>
      <div style={{ fontFamily: T.fontBody, fontSize: 24, fontWeight: 700,
        color: accent ? T.accentIron : T.textPrimary,
        letterSpacing: '-0.025em', fontVariantNumeric:'tabular-nums',
        lineHeight: 1 }}>{value}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 600,
        color: T.textTertiary, marginTop: 6,
        letterSpacing: '0.08em', textTransform:'uppercase' }}>
        {label}
      </div>
    </div>
  );
}

function ExerciseDetailCard({ exercise }) {
  return (
    <Card padding={0}>
      <div style={{ padding: '12px 14px',
        borderBottom:`0.5px solid ${T.divider}`,
        display:'flex', alignItems:'center', gap: T.sm }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: T.textPrimary }}>{exercise.name}</div>
          <Pill bg={T.surfaceHigh} style={{ marginTop: 4 }}>{exercise.muscle}</Pill>
        </div>
      </div>
      <div>
        {exercise.sets.map((s, i) => (
          <div key={i} style={{
            display:'grid', gridTemplateColumns:'32px 1fr auto',
            padding: '9px 14px', alignItems:'center', gap: T.sm,
            background: s.pr ? alpha(T.accentIron, 0.06) : 'transparent',
            borderBottom: i < exercise.sets.length - 1
              ? `0.5px solid ${alpha(T.divider, 0.4)}` : 'none',
          }}>
            <div style={{ textAlign:'center' }}>
              {s.type === 'W'
                ? <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
                    style={{ fontSize: 9, padding:'2px 6px' }}>W</Pill>
                : <span style={{ fontFamily: T.fontBody, fontSize: 13,
                    fontWeight: 700, color: T.textSecondary }}>{s.type}</span>
              }
            </div>
            <div style={{ fontFamily: T.fontMono, fontSize: 13,
              color: T.textPrimary, fontVariantNumeric:'tabular-nums' }}>
              {typeof s.w === 'string' ? s.w : `${s.w} kg`} × {s.r}
            </div>
            {s.pr
              ? <Icon.Trophy c={T.accentIron} size={14}/>
              : <Icon.Check c={T.successLime} sw={2} size={14}/>
            }
          </div>
        ))}
      </div>
    </Card>
  );
}

/* ════════════════════════════════════════════════════════════
   EXERCISE DETAIL SCREEN
══════════════════════════════════════════════════════════════ */
function ExerciseDetailScreen({ exercise, onBack }) {
  const data = exercise || {
    name: 'Bench Press', muscle:'Chest', equipment:'Barbell',
    topSet: '102.5 kg × 5',
    totalVolume: '24,840',
    sessions: 18,
    prCount: 4,
    chartData: [
      { date:'12w', w:82.5 },
      { date:'10w', w:85   },
      { date:'8w',  w:87.5 },
      { date:'6w',  w:92.5 },
      { date:'4w',  w:95   },
      { date:'3w',  w:97.5 },
      { date:'2w',  w:100  },
      { date:'now', w:102.5 },
    ],
    recent: [
      { date:'Today',    sets:'80×8, 80×8, 85×6, 100×5', pr:true },
      { date:'4d ago',   sets:'80×8, 80×8, 85×6',  pr:false },
      { date:'1w ago',   sets:'77.5×8, 77.5×8, 82.5×6', pr:false },
      { date:'2w ago',   sets:'77.5×8, 77.5×8, 80×6',  pr:false },
      { date:'2.5w ago', sets:'75×8, 75×8, 80×6',   pr:false },
    ],
    note: "Bar path drift on heavy attempts — focus on tucking elbows. Pause at chest helps with lockout strength.",
  };

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, overflowY:'auto' }}>

      <DetailHeader
        onBack={onBack}
        eyebrow={`${data.muscle.toUpperCase()} · ${data.equipment.toUpperCase()}`}
        title={data.name}
      />

      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.bottomNavPad}px`,
        display:'flex', flexDirection:'column', gap: T.sectionGap }}>

        {/* Top set highlight */}
        <Card padding={18}>
          <div style={{ display:'flex', alignItems:'center', gap: T.md }}>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 700,
                color: T.accentIron, letterSpacing: '0.1em',
                textTransform:'uppercase', marginBottom: 4 }}>BEST SET (CURRENT)</div>
              <div style={{ fontFamily: T.fontBody, fontSize: 28, fontWeight: 700,
                color: T.textPrimary, letterSpacing: '-0.035em',
                fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>
                {data.topSet}
              </div>
              <div style={{ fontFamily: T.fontBody, fontSize: 12,
                color: T.successLime, marginTop: 8, fontWeight: 600 }}>
                ↑ +5 kg vs 30 days ago
              </div>
            </div>
            <div style={{ width: 56, height: 56, borderRadius:'50%',
              background: alpha(T.accentIron, 0.15),
              display:'flex', alignItems:'center', justifyContent:'center',
              flexShrink: 0 }}>
              <Icon.Trophy c={T.accentIron} size={24}/>
            </div>
          </div>
        </Card>

        {/* Mini stats row */}
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr',
          gap: 8 }}>
          <DetailStatTile label="Volume" value={data.totalVolume}/>
          <DetailStatTile label="Sessions" value={data.sessions}/>
          <DetailStatTile label="PRs" value={data.prCount} accent/>
        </div>

        {/* Progression chart */}
        <div>
          <SectionHeader label="TOP SET PROGRESSION"/>
          <Card padding={14}>
            <ProgressLineChart data={data.chartData}/>
          </Card>
        </div>

        {/* Recent sessions */}
        <div>
          <SectionHeader label="RECENT SESSIONS"/>
          <Card padding={0}>
            {data.recent.map((s, i) => (
              <div key={i} style={{
                padding: '12px 14px',
                borderBottom: i < data.recent.length - 1
                  ? `0.5px solid ${alpha(T.divider, 0.5)}` : 'none',
                display:'flex', alignItems:'center', gap: T.sm,
                background: s.pr ? alpha(T.accentIron, 0.04) : 'transparent',
              }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: T.fontBody, fontSize: 12,
                    fontWeight: 700, color: T.textPrimary }}>{s.date}</div>
                  <div style={{ fontFamily: T.fontMono, fontSize: 11,
                    color: T.textSecondary, marginTop: 2,
                    fontVariantNumeric:'tabular-nums' }}>{s.sets}</div>
                </div>
                {s.pr && (
                  <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
                    style={{ fontSize: 9, fontWeight: 700 }}>PR</Pill>
                )}
              </div>
            ))}
          </Card>
        </div>

        {/* Form notes */}
        <div>
          <div style={{ display:'flex', justifyContent:'space-between',
            alignItems:'center', marginBottom: 10 }}>
            <SectionLabel>FORM NOTES</SectionLabel>
            <AmberLink label="Edit" onPress={() => {}}/>
          </div>
          <Card padding={14}>
            <div style={{ fontFamily: T.fontBody, fontSize: 13,
              color: T.textSecondary, lineHeight: 1.6 }}>{data.note}</div>
          </Card>
        </div>

      </div>
    </div>
  );
}

/* ── PROGRESSION LINE CHART (with date labels) ─────────── */
function ProgressLineChart({ data }) {
  const w = 320, h = 100;
  const ys = data.map(d => d.w);
  const yMin = Math.min(...ys) - 2;
  const yMax = Math.max(...ys) + 2;

  const pts = data.map((d, i) => [
    (i / (data.length - 1)) * w,
    h - ((d.w - yMin) / (yMax - yMin)) * h
  ]);
  const pathD = pts.map((p, i) =>
    `${i === 0 ? 'M' : 'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`
  ).join(' ');
  const areaD = pathD + ` L${w},${h} L0,${h} Z`;

  return (
    <div>
      <svg viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none"
        style={{ width:'100%', height: 100 }}>
        <defs>
          <linearGradient id="prGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={T.accentIron} stopOpacity="0.3"/>
            <stop offset="100%" stopColor={T.accentIron} stopOpacity="0"/>
          </linearGradient>
        </defs>
        <path d={areaD} fill="url(#prGrad)"/>
        <path d={pathD} stroke={T.accentIron} strokeWidth="2"
          fill="none" strokeLinecap="round" strokeLinejoin="round"
          vectorEffect="non-scaling-stroke"/>
        {pts.map((p, i) => (
          <circle key={i} cx={p[0]} cy={p[1]} r="2.5"
            fill={i === pts.length-1 ? T.accentIron : T.surfaceHigh}
            stroke={T.accentIron} strokeWidth="1.5"
            vectorEffect="non-scaling-stroke"/>
        ))}
      </svg>
      <div style={{ display:'flex', justifyContent:'space-between',
        marginTop: 6 }}>
        {data.map((d, i) => (
          <div key={i} style={{ fontFamily: T.fontBody, fontSize: 9,
            fontWeight: i === data.length-1 ? 700 : 500,
            color: i === data.length-1 ? T.accentIron : T.textTertiary }}>
            {d.date}
          </div>
        ))}
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════════
   PR DETAIL SCREEN
══════════════════════════════════════════════════════════════ */
function PRDetailScreen({ pr, onBack }) {
  const data = pr || {
    exercise: 'Bench Press',
    type: '1RM',
    current: 102.5,
    unit: 'kg',
    reps: 5,
    achieved: 'Today · 6:42 PM',
    note: 'First time hitting triple digits for 5 clean reps. Spotter only assisted on lockout of rep 5.',
    progression: [
      { date:'May 2025', w:80 },
      { date:'Jul 2025', w:85 },
      { date:'Sep 2025', w:87.5 },
      { date:'Nov 2025', w:90 },
      { date:'Jan 2026', w:92.5 },
      { date:'Mar 2026', w:95 },
      { date:'Apr 2026', w:100 },
      { date:'May 2026', w:102.5 },
    ],
    attempts: [
      { date:'Today',     value:'102.5 kg × 5', current:true },
      { date:'5d ago',    value:'100 kg × 5',   pr:true },
      { date:'2w ago',    value:'97.5 kg × 5',  pr:true },
      { date:'5w ago',    value:'95 kg × 5',    pr:true },
      { date:'10w ago',   value:'92.5 kg × 5',  pr:true },
    ],
  };

  return (
    <div style={{ flex: 1, display:'flex', flexDirection:'column',
      background: T.surface, overflowY:'auto' }}>

      <DetailHeader
        onBack={onBack}
        eyebrow={`${data.type} PERSONAL RECORD`}
        title={data.exercise}
        subtitle={data.achieved}
        right={<GhostButton label="Share" size="sm" onPress={() => {}}/>}
      />

      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.bottomNavPad}px`,
        display:'flex', flexDirection:'column', gap: T.sectionGap }}>

        {/* Hero PR value */}
        <Card padding={28} style={{
          background: `linear-gradient(135deg, ${alpha(T.accentIron, 0.12)}, ${alpha(T.accentIron, 0.04)})`,
          border: `1px solid ${alpha(T.accentIron, 0.4)}`,
          textAlign:'center',
        }}>
          <div style={{ width: 56, height: 56, borderRadius:'50%',
            background: alpha(T.accentIron, 0.18),
            display:'flex', alignItems:'center', justifyContent:'center',
            margin:'0 auto 14px' }}>
            <Icon.Trophy c={T.accentIron} size={26}/>
          </div>
          <div style={{ display:'flex', alignItems:'baseline',
            justifyContent:'center', gap: 4 }}>
            <span style={{ fontFamily: T.fontBody, fontSize: 56, fontWeight: 700,
              color: T.accentIron, letterSpacing: '-0.05em',
              fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>
              {data.current}
            </span>
            <span style={{ fontFamily: T.fontBody, fontSize: 18,
              color: T.textSecondary, fontWeight: 500 }}>{data.unit}</span>
          </div>
          <div style={{ fontFamily: T.fontBody, fontSize: 12,
            color: T.textTertiary, marginTop: 6,
            fontVariantNumeric:'tabular-nums' }}>
            × {data.reps} reps
          </div>
        </Card>

        {/* Progression chart */}
        <div>
          <SectionHeader label="ALL-TIME PROGRESSION"/>
          <Card padding={14}>
            <BigProgressionChart data={data.progression}/>
          </Card>
        </div>

        {/* PR Timeline */}
        <div>
          <SectionHeader label="PR ATTEMPTS"/>
          <Card padding={0}>
            {data.attempts.map((a, i) => (
              <div key={i} style={{
                padding: '12px 14px',
                borderBottom: i < data.attempts.length - 1
                  ? `0.5px solid ${alpha(T.divider, 0.4)}` : 'none',
                display:'flex', alignItems:'center', gap: T.sm,
                position:'relative',
              }}>
                {/* Timeline dot + line */}
                <div style={{ position:'relative', width: 16, height: 36,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  flexShrink: 0 }}>
                  {i > 0 && (
                    <div style={{ position:'absolute', top: -10, bottom: 18,
                      left: '50%', width: 1, background: T.divider,
                      transform: 'translateX(-0.5px)' }}/>
                  )}
                  {i < data.attempts.length - 1 && (
                    <div style={{ position:'absolute', top: 18, bottom: -10,
                      left: '50%', width: 1, background: T.divider,
                      transform: 'translateX(-0.5px)' }}/>
                  )}
                  <div style={{
                    width: a.current ? 14 : 10,
                    height: a.current ? 14 : 10,
                    borderRadius:'50%',
                    background: a.current ? T.accentIron : T.surfaceHigh,
                    border: a.current ? `2px solid ${T.surface}` : `1px solid ${T.divider}`,
                    boxShadow: a.current ? `0 0 0 3px ${alpha(T.accentIron, 0.25)}` : 'none',
                    zIndex: 1,
                  }}/>
                </div>

                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: T.fontBody, fontSize: 13,
                    fontWeight: a.current ? 700 : 500,
                    color: a.current ? T.accentIron : T.textPrimary }}>
                    {a.date}
                  </div>
                  <div style={{ fontFamily: T.fontMono, fontSize: 11,
                    color: T.textSecondary, marginTop: 2,
                    fontVariantNumeric:'tabular-nums' }}>{a.value}</div>
                </div>

                {a.current && (
                  <Pill bg={T.accentIron} color="#FFF"
                    style={{ fontSize: 9, fontWeight: 800 }}>CURRENT</Pill>
                )}
                {a.pr && !a.current && (
                  <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
                    style={{ fontSize: 9, fontWeight: 700 }}>PR</Pill>
                )}
              </div>
            ))}
          </Card>
        </div>

        {/* Note */}
        {data.note && (
          <div>
            <div style={{ display:'flex', justifyContent:'space-between',
              alignItems:'center', marginBottom: 10 }}>
              <SectionLabel>PR NOTE</SectionLabel>
              <AmberLink label="Edit" onPress={() => {}}/>
            </div>
            <Card padding={14}>
              <div style={{ fontFamily: T.fontBody, fontSize: 13,
                color: T.textSecondary, lineHeight: 1.6,
                fontStyle:'italic' }}>"{data.note}"</div>
            </Card>
          </div>
        )}

      </div>
    </div>
  );
}

/* ── BIG PROGRESSION CHART (annotated) ─────────────────── */
function BigProgressionChart({ data }) {
  const w = 320, h = 130;
  const ys = data.map(d => d.w);
  const yMin = Math.min(...ys);
  const yMax = Math.max(...ys);
  const padY = (yMax - yMin) * 0.15;
  const min = yMin - padY;
  const max = yMax + padY;

  const pts = data.map((d, i) => [
    (i / (data.length - 1)) * w,
    h - ((d.w - min) / (max - min)) * h
  ]);
  const pathD = pts.map((p, i) =>
    `${i === 0 ? 'M' : 'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`
  ).join(' ');
  const areaD = pathD + ` L${w},${h} L0,${h} Z`;

  const last = pts[pts.length - 1];

  return (
    <div>
      <div style={{ position:'relative' }}>
        <svg viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none"
          style={{ width:'100%', height: 130 }}>
          <defs>
            <linearGradient id="bigPrGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={T.accentIron} stopOpacity="0.35"/>
              <stop offset="100%" stopColor={T.accentIron} stopOpacity="0"/>
            </linearGradient>
          </defs>
          {/* Grid lines */}
          {[0.33, 0.66].map((p, i) => (
            <line key={i} x1="0" x2={w} y1={h*p} y2={h*p}
              stroke={alpha(T.divider, 0.4)} strokeWidth="0.5"
              strokeDasharray="2 3" vectorEffect="non-scaling-stroke"/>
          ))}
          <path d={areaD} fill="url(#bigPrGrad)"/>
          <path d={pathD} stroke={T.accentIron} strokeWidth="2.5"
            fill="none" strokeLinecap="round" strokeLinejoin="round"
            vectorEffect="non-scaling-stroke"/>
          {pts.map((p, i) => (
            <circle key={i} cx={p[0]} cy={p[1]} r="2.5"
              fill={T.surfaceElevated}
              stroke={T.accentIron} strokeWidth="2"
              vectorEffect="non-scaling-stroke"/>
          ))}
          {/* Highlight current */}
          <circle cx={last[0]} cy={last[1]} r="5"
            fill={T.accentIron}
            vectorEffect="non-scaling-stroke"/>
        </svg>
      </div>

      {/* Min/max + range */}
      <div style={{ display:'flex', justifyContent:'space-between',
        marginTop: 10, paddingTop: 10,
        borderTop: `0.5px solid ${T.divider}` }}>
        <div>
          <div style={{ fontFamily: T.fontBody, fontSize: 9, fontWeight: 600,
            color: T.textTertiary, letterSpacing: '0.06em',
            textTransform:'uppercase' }}>Started</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
            color: T.textSecondary, fontVariantNumeric:'tabular-nums',
            marginTop: 2 }}>{data[0].w} kg</div>
        </div>
        <div style={{ textAlign:'center' }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 9, fontWeight: 600,
            color: T.textTertiary, letterSpacing: '0.06em',
            textTransform:'uppercase' }}>Gained</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
            color: T.successLime, fontVariantNumeric:'tabular-nums',
            marginTop: 2 }}>+{(data[data.length-1].w - data[0].w).toFixed(1)} kg</div>
        </div>
        <div style={{ textAlign:'right' }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 9, fontWeight: 600,
            color: T.textTertiary, letterSpacing: '0.06em',
            textTransform:'uppercase' }}>Current</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
            color: T.accentIron, fontVariantNumeric:'tabular-nums',
            marginTop: 2 }}>{data[data.length-1].w} kg</div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  WorkoutDetailScreen,
  ExerciseDetailScreen,
  PRDetailScreen,
});

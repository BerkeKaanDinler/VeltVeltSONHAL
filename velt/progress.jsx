// VELT — Progress Screen v2
// Changes: KPI breathing room, volume 34pt, Pro lock stronger, sparkline stroke 2pt,
//          exercise row last weight = mono + accentIron

const { useState } = React;

function ProgressScreen() {
  const [period, setPeriod] = useState('month');

  const kpis = [
    { v:'48,200', u:'kg', l:'Volume' },
    { v:'12',     u:'',   l:'Workouts' },
    { v:'7',      u:'',   l:'Streak', accent:true },
  ];

  const topExercises = [
    { name:'Bench Press',  last:'102.5 kg', change:'+2.5 kg', trend:[80,82.5,85,85,90,95,100,102.5] },
    { name:'Squat',        last:'142.5 kg', change:'+5.0 kg', trend:[120,125,125,130,132.5,135,140,142.5] },
    { name:'Deadlift',     last:'172.5 kg', change:'+2.5 kg', trend:[150,155,157.5,160,165,170,170,172.5] },
    { name:'OHP',          last:'72.5 kg',  change:'+2.5 kg', trend:[60,62.5,65,65,67.5,70,70,72.5] },
    { name:'Pull-ups',     last:'BW+15 kg', change:'+5 kg',   trend:[0,2.5,5,7.5,10,10,12.5,15] },
  ];

  const recentPRs = [
    { exercise:'Bench Press', type:'1RM',    value:'102.5 kg', date:'2 days ago' },
    { exercise:'Squat',       type:'Volume', value:'3,420 kg', date:'5 days ago' },
    { exercise:'OHP',         type:'1RM',    value:'72.5 kg',  date:'1 week ago' },
  ];

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface }}>
      {/* Header */}
      <div style={{ padding:`${T.xl}px ${T.md}px ${T.md}px`,
        display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:34, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.03em' }}>Progress</div>
        <div style={{ display:'flex', background: T.surfaceElevated,
          borderRadius: T.rsm, overflow:'hidden' }}>
          {['week','month','year'].map(p => (
            <button key={p} onClick={() => setPeriod(p)} style={{
              padding:'5px 13px', border:'none',
              background: period===p ? T.accentIron : 'transparent',
              color: period===p ? '#fff' : T.textTertiary,
              fontFamily: T.fontBody, fontSize:11, fontWeight:600,
              cursor:'pointer', transition:'background 200ms',
              textTransform:'capitalize',
            }}>{p}</button>
          ))}
        </div>
      </div>

      <div style={{ padding:`0 ${T.md}px`,
        display:'flex', flexDirection:'column',
        gap:20, paddingBottom: T.xxl }}>

        {/* KPI — 3 large cards, 28px numbers */}
        <div style={{ display:'flex', gap:10 }}>
          {kpis.map(k => (
            <BigStatCard key={k.l} value={k.v} unit={k.u}
              label={k.l} accent={k.accent} />
          ))}
        </div>

        {/* Volume by Muscle — Pro gated */}
        <div>
          <SectionHeader label="Volume by Muscle" />
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            padding:20, position:'relative', overflow:'hidden' }}>
            <MuscleBars />
            {/* Pro overlay — stronger blur */}
            <div style={{
              position:'absolute', inset:0,
              background:`${T.surface}e0`,
              backdropFilter:'blur(8px)',
              WebkitBackdropFilter:'blur(8px)',
              borderRadius: T.rmd,
              display:'flex', flexDirection:'column',
              alignItems:'center', justifyContent:'center', gap:10,
            }}>
              <div style={{ width:40, height:40, borderRadius: T.rfull,
                background: T.surfaceHigh,
                display:'flex', alignItems:'center', justifyContent:'center' }}>
                <svg width="20" height="22" viewBox="0 0 20 22" fill="none">
                  <rect x="2" y="9" width="16" height="13" rx="2"
                    stroke={T.textTertiary} strokeWidth="1.8"/>
                  <path d="M6 9V6a4 4 0 0 1 8 0v3"
                    stroke={T.textTertiary} strokeWidth="1.8" strokeLinecap="round"/>
                  <circle cx="10" cy="15" r="1.5" fill={T.textTertiary}/>
                </svg>
              </div>
              <div style={{ fontFamily: T.fontDisplay, fontSize:15, fontWeight:700,
                color: T.textPrimary, letterSpacing:'-0.01em' }}>Advanced Analytics</div>
              <div style={{ fontFamily: T.fontBody, fontSize:12,
                color: T.textSecondary }}>Unlock with VELT Pro</div>
              <button style={{
                background:'none', border:`1px solid ${T.accentIron}`,
                color: T.accentIron, fontFamily: T.fontBody, fontSize:13,
                fontWeight:600, padding:'8px 20px', borderRadius: T.rsm,
                cursor:'pointer',
              }}>Upgrade</button>
            </div>
          </div>
        </div>

        {/* Top exercises */}
        <div>
          <SectionHeader label="Top Exercises" />
          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {topExercises.map(ex => (
              <div key={ex.name} style={{ background: T.surfaceElevated,
                borderRadius: T.rmd, padding:`${T.sm}px 20px`,
                display:'flex', alignItems:'center', gap: T.sm }}>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontFamily: T.fontDisplay, fontSize:14,
                    fontWeight:700, color: T.textPrimary,
                    letterSpacing:'-0.01em', overflow:'hidden',
                    textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{ex.name}</div>
                  <div style={{ display:'flex', alignItems:'center', gap:5, marginTop:2 }}>
                    <div style={{ fontFamily: T.fontDisplay, fontSize:12,
                      fontWeight:600, color: T.accentIron,
                      fontVariantNumeric:'tabular-nums' }}>{ex.last}</div>
                    {ex.change && (
                      <span style={{ fontFamily: T.fontBody, fontSize:11,
                        fontWeight:600,
                        color: ex.change.startsWith('+') ? T.successLime : T.errorRose }}>
                        {ex.change}
                      </span>
                    )}
                  </div>
                </div>
                <MiniSparkline data={ex.trend} />
              </div>
            ))}
          </div>
        </div>

        {/* Recent PRs */}
        <div>
          <SectionHeader label="Personal Records" />
          <div style={{ display:'flex', flexDirection:'column', gap:10 }}>
            {recentPRs.map(pr => (
              <div key={pr.exercise} style={{ background: T.surfaceElevated,
                borderRadius: T.rmd, padding:`${T.sm}px 20px`,
                display:'flex', alignItems:'center', gap: T.sm }}>
                <div style={{ width:34, height:34, borderRadius: T.rfull,
                  background:`${T.accentIron}18`,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  flexShrink:0 }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"
                      stroke={T.accentIron} strokeWidth="1.8"
                      strokeLinejoin="round"/>
                  </svg>
                </div>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontFamily: T.fontDisplay, fontSize:14,
                    fontWeight:700, color: T.textPrimary }}>{pr.exercise}</div>
                  <div style={{ display:'flex', alignItems:'center',
                    gap: T.xs, marginTop:2 }}>
                    <span style={{ fontFamily: T.fontBody, fontSize:9,
                      fontWeight:700,
                      color: '#fff',
                      background: pr.type === '1RM' ? T.accentIron : '#6366F1',
                      padding:'2px 6px', borderRadius: T.rfull,
                      letterSpacing:'0.04em' }}>{pr.type}</span>
                    <span style={{ fontFamily: T.fontBody, fontSize:11,
                      color: T.textTertiary }}>{pr.date}</span>
                  </div>
                </div>
                <div style={{ fontFamily: T.fontDisplay, fontSize:16,
                  fontWeight:700, color: T.accentIron,
                  fontVariantNumeric:'tabular-nums',
                  letterSpacing:'-0.01em' }}>{pr.value}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Bodyweight */}
        <div>
          <SectionHeader label="Bodyweight" action="Log" onAction={() => {}} />
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            padding:20 }}>
            <div style={{ display:'flex', justifyContent:'space-between',
              alignItems:'baseline', marginBottom: T.sm }}>
              <div style={{ fontFamily: T.fontDisplay, fontSize:34,
                fontWeight:700, color: T.textPrimary,
                fontVariantNumeric:'tabular-nums',
                letterSpacing:'-0.03em' }}>
                82.5
                <span style={{ fontSize:14, fontWeight:400,
                  color: T.textSecondary }}> kg</span>
              </div>
              <span style={{ fontFamily: T.fontBody, fontSize:12,
                color: T.successLime }}>↗ +1.2 kg this month</span>
            </div>
            <WeightChart />
          </div>
        </div>

      </div>
    </div>
  );
}

/* ── Big Stat Card (KPI strip) ───────────────────────────── */
function BigStatCard({ value, unit, label, accent }) {
  return (
    <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
      padding:`${T.md}px ${T.sm}px`, minWidth:80, textAlign:'center',
      flexShrink:0 }}>
      <div style={{ display:'flex', alignItems:'baseline',
        justifyContent:'center', gap:3 }}>
        <span style={{ fontFamily: T.fontDisplay, fontSize:28, fontWeight:700,
          color: accent ? T.accentIron : T.textPrimary,
          fontVariantNumeric:'tabular-nums',
          letterSpacing:'-0.03em', lineHeight:1 }}>{value}</span>
        {unit && (
          <span style={{ fontFamily: T.fontBody, fontSize:11,
            fontWeight:500, color: T.textSecondary }}>{unit}</span>
        )}
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:600,
        color: T.textTertiary, marginTop:5, letterSpacing:'0.07em',
        textTransform:'uppercase' }}>{label}</div>
    </div>
  );
}

/* ── Mini Sparkline ──────────────────────────────────────── */
function MiniSparkline({ data }) {
  if (!data || data.length < 2) return null;
  const w = 64, h = 28;
  const min = Math.min(...data), max = Math.max(...data);
  const range = max - min || 1;
  const pts = data.map((v,i) => [
    (i/(data.length-1))*w,
    h - ((v-min)/range)*h
  ]);
  const d = pts.map((p,i) =>
    `${i===0?'M':'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`
  ).join(' ');
  return (
    <svg width={w} height={h} style={{ flexShrink:0 }}>
      <path d={d} stroke={T.accentIron} strokeWidth="2"
        fill="none" strokeLinecap="round" strokeLinejoin="round"/>
      <circle cx={pts[pts.length-1][0]} cy={pts[pts.length-1][1]}
        r="2.5" fill={T.accentIron}/>
    </svg>
  );
}

/* ── Weight Chart ────────────────────────────────────────── */
function WeightChart() {
  const data = [81.2,81.5,81.8,81.6,82.0,82.1,82.3,82.5];
  const w = 300, h = 56;
  const min = Math.min(...data) - 0.5;
  const max = Math.max(...data) + 0.5;
  const range = max - min;
  const pts = data.map((v,i) => [
    (i/(data.length-1))*w,
    h - ((v-min)/range)*h
  ]);
  const d = pts.map((p,i) =>
    `${i===0?'M':'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`
  ).join(' ');
  const area = d + ` L${w},${h} L0,${h} Z`;
  return (
    <svg viewBox={`0 0 ${w} ${h}`} style={{ width:'100%', height:56 }}>
      <defs>
        <linearGradient id="wGrad2" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={T.accentIron} stopOpacity="0.18"/>
          <stop offset="100%" stopColor={T.accentIron} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={area} fill="url(#wGrad2)"/>
      <path d={d} stroke={T.accentIron} strokeWidth="2"
        fill="none" strokeLinecap="round" strokeLinejoin="round"/>
      <circle cx={pts[pts.length-1][0]} cy={pts[pts.length-1][1]}
        r="3" fill={T.accentIron}/>
    </svg>
  );
}

/* ── Muscle Bars (behind Pro gate) ──────────────────────── */
function MuscleBars() {
  const muscles = [
    {name:'Chest',     pct:85},
    {name:'Back',      pct:70},
    {name:'Shoulders', pct:60},
    {name:'Legs',      pct:90},
    {name:'Arms',      pct:40},
  ];
  return (
    <div style={{ display:'flex', flexDirection:'column', gap: T.xs }}>
      {muscles.map(m => (
        <div key={m.name} style={{ display:'flex', alignItems:'center', gap: T.sm }}>
          <span style={{ fontFamily: T.fontBody, fontSize:11,
            color: T.textSecondary, minWidth:70 }}>{m.name}</span>
          <div style={{ flex:1, height:6, background: T.surfaceHigh,
            borderRadius: T.rfull, overflow:'hidden' }}>
            <div style={{ width:`${m.pct}%`, height:'100%',
              background: T.accentIron, borderRadius: T.rfull }} />
          </div>
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { ProgressScreen });

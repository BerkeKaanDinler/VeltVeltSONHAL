// VELT — Progress Screen
// KPI strip + Weekly Volume + Bodyweight + PRs + Pro-gated Volume by Muscle

const { useState } = React;

const PERIOD = ['Week','Month','Year'];

// helper for sample data
const VOLUME_WEEK = [9200, 11400, 8700, 12800, 14820, 0, 0];
const VOLUME_8WEEKS = [42000, 46500, 51200, 48200, 49100, 53400, 47800, 51200];

const BODYWEIGHT_LOG = [
  { day:1,  kg:83.2 }, { day:4,  kg:83.4 },
  { day:8,  kg:83.7 }, { day:12, kg:83.8 },
  { day:16, kg:84.0 }, { day:20, kg:84.2 },
  { day:24, kg:84.3 }, { day:28, kg:84.5 },
];

const PR_LIST = [
  { exercise:'Bench Press', date:'2 days ago',  value:'102.5 kg' },
  { exercise:'Back Squat',  date:'5 days ago',  value:'142.5 kg' },
  { exercise:'Deadlift',    date:'1 week ago',  value:'172.5 kg' },
  { exercise:'Overhead Press', date:'1 week ago', value:'72.5 kg' },
  { exercise:'Pull-ups',    date:'2 weeks ago', value:'BW + 15 kg' },
];

/* ══════════════════════════════════════════════════════════
   PROGRESS ROOT
══════════════════════════════════════════════════════════ */
function ProgressScreen({ unit='kg', onOpenPR, onOpenExercise }) {
  const [period, setPeriod] = useState('Week');

  // KPIs change with period
  const kpis = {
    Week:  { volume:'14,820', workouts:5,  streak:7  },
    Month: { volume:'58,420', workouts:18, streak:7  },
    Year:  { volume:'682,400',workouts:194,streak:7  },
  };
  const k = kpis[period];

  return (
    <div style={{ flex: 1, overflowY:'auto', background: T.surface }}>
      <ScreenHeader
        title="Progress"
        right={<PeriodSelector value={period} onChange={setPeriod}/>}
      />

      <div style={{ padding: `0 ${T.screenH}px`,
        display:'flex', flexDirection:'column',
        gap: T.sectionGap, paddingBottom: T.bottomNavPad }}>

        {/* ═══ KPI STRIP ═══ */}
        <div style={{ display:'flex', gap: 8 }}>
          <KpiCard label="Volume" value={k.volume} unit={unit}/>
          <KpiCard label="Workouts" value={k.workouts} unit=""/>
          <KpiCard label="Streak" value={k.streak} unit="days" accent/>
        </div>

        {/* ═══ WEEKLY VOLUME CHART ═══ */}
        <div>
          <SectionHeader label={`VOLUME — LAST 8 ${period.toUpperCase()}S`}/>
          <Card padding={16}>
            <VolumeChart data={VOLUME_8WEEKS}/>
          </Card>
        </div>

        {/* ═══ BODYWEIGHT ═══ */}
        <div>
          <div style={{ display:'flex', justifyContent:'space-between',
            alignItems:'center', marginBottom: 10 }}>
            <SectionLabel>BODYWEIGHT</SectionLabel>
            <AmberLink label="Log" onPress={() => {}}/>
          </div>
          <BodyweightCard data={BODYWEIGHT_LOG} unit={unit}/>
        </div>

        {/* ═══ PERSONAL RECORDS ═══ */}
        <div>
          <SectionHeader label="PERSONAL RECORDS"
            action="See all →" onAction={() => {}}/>
          <Card padding={0}>
            {PR_LIST.map((pr, i) => (
              <div key={pr.exercise} onClick={onOpenPR} style={{
                display:'flex', alignItems:'center', gap: T.sm,
                padding: '12px 14px',
                cursor:'pointer',
                borderBottom: i < PR_LIST.length - 1
                  ? `0.5px solid ${T.divider}` : 'none',
              }}>
                <div style={{ width: 32, height: 32, borderRadius:'50%',
                  background: alpha(T.accentIron, 0.15),
                  display:'flex', alignItems:'center', justifyContent:'center',
                  flexShrink: 0 }}>
                  <Icon.Trophy c={T.accentIron} size={14}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: T.fontBody, fontSize: 14,
                    fontWeight: 600, color: T.textPrimary,
                    letterSpacing: '-0.005em' }}>{pr.exercise}</div>
                  <div style={{ fontFamily: T.fontBody, fontSize: 11,
                    color: T.textTertiary, marginTop: 2 }}>{pr.date}</div>
                </div>
                <div style={{ fontFamily: T.fontBody, fontSize: 16,
                  fontWeight: 700, color: T.accentIron,
                  letterSpacing: '-0.02em',
                  fontVariantNumeric:'tabular-nums' }}>
                  {pr.value}
                </div>
              </div>
            ))}
          </Card>
        </div>

        {/* ═══ VOLUME BY MUSCLE (PRO) ═══ */}
        <div>
          <SectionHeader label="VOLUME BY MUSCLE"/>
          <ProLockCard
            title="Advanced Analytics"
            subtitle="Track volume distribution across muscle groups, view weekly trends, and identify imbalances."
          />
        </div>

      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   PERIOD SELECTOR (segmented control)
──────────────────────────────────────────────────────── */
function PeriodSelector({ value, onChange }) {
  return (
    <div style={{
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rfull,
      padding: 3,
      display:'flex', gap: 2,
    }}>
      {PERIOD.map(p => {
        const active = value === p;
        return (
          <button key={p} onClick={() => onChange(p)} style={{
            padding: '5px 12px',
            borderRadius: T.rfull,
            background: active ? T.accentIron : 'transparent',
            border:'none', cursor:'pointer',
            color: active ? '#FFF' : T.textTertiary,
            fontFamily: T.fontBody, fontSize: 11,
            fontWeight: active ? 700 : 600,
            transition:'all 200ms', letterSpacing: '0.01em',
          }}>{p}</button>
        );
      })}
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   KPI CARD
──────────────────────────────────────────────────────── */
function KpiCard({ label, value, unit, accent }) {
  return (
    <div style={{
      flex: 1, padding: 14,
      background: T.surfaceElevated,
      border: accent ? `1px solid ${T.accentIron}` : `0.5px solid ${T.divider}`,
      borderRadius: T.rmd,
    }}>
      <div style={{ fontFamily: T.fontBody, fontSize: 22, fontWeight: 700,
        color: accent ? T.accentIron : T.textPrimary,
        letterSpacing: '-0.025em', fontVariantNumeric:'tabular-nums',
        lineHeight: 1 }}>{value}</div>
      {unit && (
        <div style={{ fontFamily: T.fontBody, fontSize: 10,
          color: T.textSecondary, marginTop: 3 }}>{unit}</div>
      )}
      <div style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 600,
        color: T.textTertiary, marginTop: 6,
        letterSpacing: '0.08em', textTransform:'uppercase' }}>
        {label}
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   VOLUME CHART (8 bars)
──────────────────────────────────────────────────────── */
function VolumeChart({ data }) {
  const max = Math.max(...data);
  const currentIdx = data.length - 1;
  const yLabels = [0, Math.round(max/2/1000)*1000, Math.round(max/1000)*1000];

  return (
    <div>
      {/* Chart area */}
      <div style={{ position:'relative', display:'flex',
        height: 150, marginBottom: 10 }}>
        {/* Y-axis labels */}
        <div style={{
          width: 36, display:'flex', flexDirection:'column',
          justifyContent:'space-between', paddingRight: 8,
          paddingBottom: 2, paddingTop: 2,
        }}>
          {[...yLabels].reverse().map(v => (
            <div key={v} style={{ fontFamily: T.fontBody, fontSize: 9,
              color: T.textTertiary, textAlign:'right',
              fontVariantNumeric:'tabular-nums' }}>
              {v >= 1000 ? `${v/1000}k` : v}
            </div>
          ))}
        </div>

        {/* Bars */}
        <div style={{ flex: 1, display:'flex',
          alignItems:'flex-end', gap: 6,
          borderLeft:`0.5px solid ${T.divider}`,
          borderBottom:`0.5px solid ${T.divider}`,
          paddingLeft: 4, paddingBottom: 1,
        }}>
          {data.map((v, i) => {
            const h = max > 0 ? (v / max) * 100 : 0;
            const isCurrent = i === currentIdx;
            return (
              <div key={i} style={{
                flex: 1,
                height: `${h}%`,
                background: isCurrent ? T.accentIron : T.surfaceHigh,
                borderRadius: `${T.rxs}px ${T.rxs}px 0 0`,
                transition:'height 600ms ease-out',
                minHeight: 2,
              }}/>
            );
          })}
        </div>
      </div>

      {/* X-axis week labels */}
      <div style={{ paddingLeft: 40, display:'flex', gap: 6 }}>
        {data.map((_, i) => (
          <div key={i} style={{ flex: 1, textAlign:'center',
            fontFamily: T.fontBody, fontSize: 10,
            fontWeight: i === currentIdx ? 700 : 500,
            color: i === currentIdx ? T.accentIron : T.textTertiary,
          }}>W{i + 1}</div>
        ))}
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   BODYWEIGHT CARD
──────────────────────────────────────────────────────── */
function BodyweightCard({ data, unit }) {
  if (!data || data.length === 0) {
    return (
      <Card padding={28} style={{ textAlign:'center' }}>
        <div style={{ display:'flex', justifyContent:'center', marginBottom: 10,
          opacity: 0.5 }}>
          <Icon.Scale c={T.textSecondary}/>
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 13,
          color: T.textSecondary, fontStyle:'italic' }}>
          Tap to log your bodyweight
        </div>
      </Card>
    );
  }

  const latest = data[data.length - 1].kg;
  const first  = data[0].kg;
  const change = (latest - first).toFixed(1);
  const changeUp = parseFloat(change) > 0;

  return (
    <Card padding={16}>
      {/* Top: latest + trend */}
      <div style={{ display:'flex', alignItems:'flex-end',
        justifyContent:'space-between', marginBottom: 12 }}>
        <div>
          <div style={{ fontFamily: T.fontBody, fontSize: 34,
            fontWeight: 700, color: T.textPrimary,
            letterSpacing: '-0.04em',
            fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>
            {latest.toFixed(1)}
            <span style={{ fontSize: 13, color: T.textTertiary,
              fontWeight: 500, marginLeft: 4 }}>{unit}</span>
          </div>
          <div style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, marginTop: 4 }}>
            <span style={{
              color: changeUp ? T.successLime : T.errorRose,
              fontWeight: 600,
            }}>{changeUp ? '+' : ''}{change} {unit}</span> last 30 days
          </div>
        </div>
        <AmberLink label="+ Log today" onPress={() => {}}/>
      </div>

      {/* Mini line chart */}
      <BodyweightChart data={data}/>
    </Card>
  );
}

function BodyweightChart({ data }) {
  const w = 320, h = 70;
  const xs = data.map(d => d.day);
  const ys = data.map(d => d.kg);
  const xMin = Math.min(...xs), xMax = Math.max(...xs);
  const yMin = Math.min(...ys) - 0.3, yMax = Math.max(...ys) + 0.3;

  const pts = data.map(d => [
    ((d.day - xMin) / (xMax - xMin)) * w,
    h - ((d.kg - yMin) / (yMax - yMin)) * h
  ]);
  const pathD = pts.map((p, i) =>
    `${i === 0 ? 'M' : 'L'}${p[0].toFixed(1)},${p[1].toFixed(1)}`
  ).join(' ');
  const areaD = pathD + ` L${w},${h} L0,${h} Z`;

  return (
    <svg viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none"
      style={{ width:'100%', height: 70 }}>
      <defs>
        <linearGradient id="bwGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={T.accentIron} stopOpacity="0.25"/>
          <stop offset="100%" stopColor={T.accentIron} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <path d={areaD} fill="url(#bwGrad)"/>
      <path d={pathD} stroke={T.accentIron} strokeWidth="2"
        fill="none" strokeLinecap="round" strokeLinejoin="round"
        vectorEffect="non-scaling-stroke"/>
      {pts.map((p, i) => (
        <circle key={i} cx={p[0]} cy={p[1]} r="2" fill={T.accentIron}
          vectorEffect="non-scaling-stroke"/>
      ))}
      <circle cx={pts[pts.length-1][0]} cy={pts[pts.length-1][1]}
        r="3.5" fill={T.accentIron} stroke={T.surfaceElevated}
        strokeWidth="2" vectorEffect="non-scaling-stroke"/>
    </svg>
  );
}

/* ────────────────────────────────────────────────────────
   PRO LOCK CARD — clean abstract bg, NO fake data
──────────────────────────────────────────────────────── */
function ProLockCard({ title, subtitle }) {
  return (
    <Card padding={28} style={{
      position:'relative', overflow:'hidden',
      background: T.surfaceElevated,
      textAlign:'center',
    }}>
      {/* Abstract bg pattern */}
      <div style={{ position:'absolute', inset: 0, opacity: 0.4,
        background: `radial-gradient(circle at 25% 30%, ${alpha(T.accentIron, 0.05)}, transparent 40%),
                     radial-gradient(circle at 75% 60%, ${alpha(T.accentIron, 0.03)}, transparent 40%)`,
        pointerEvents:'none' }}/>

      <div style={{ position:'relative' }}>
        <div style={{ width: 48, height: 48, borderRadius:'50%',
          background: T.surfaceHigh, margin:'0 auto 14px',
          display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon.Lock c={T.textSecondary}/>
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 16, fontWeight: 700,
          color: T.textPrimary, letterSpacing: '-0.02em',
          marginBottom: 6 }}>{title}</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: T.textSecondary, lineHeight: 1.55,
          maxWidth: 280, margin:'0 auto 16px' }}>{subtitle}</div>
        <GhostButton label="Upgrade" style={{
          width:'auto', padding:'0 24px', margin:'0 auto',
          borderColor: T.accentIron, color: T.accentIron,
        }}/>
      </div>
    </Card>
  );
}

window.ProgressScreen = ProgressScreen;

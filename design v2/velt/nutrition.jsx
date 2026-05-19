// VELT — Nutrition Screen
// Calorie ring + macros + food log + weekly chart + add food sheet + goals sheet

const { useState } = React;

const SAMPLE_FOODS = [
  { name:'Chicken Breast', kcal:165, p:31, c:0,  f:4, per:'100g' },
  { name:'White Rice',     kcal:130, p:2.7, c:28, f:0.3, per:'100g' },
  { name:'Brown Rice',     kcal:111, p:2.6, c:23, f:0.9, per:'100g' },
  { name:'Greek Yogurt',   kcal:97,  p:9,   c:4,  f:5,  per:'100g' },
  { name:'Banana',         kcal:89,  p:1.1, c:23, f:0.3, per:'1 medium' },
  { name:'Whole Eggs',     kcal:155, p:13,  c:1.1,f:11, per:'2 eggs' },
  { name:'Oats (dry)',     kcal:389, p:17,  c:66, f:7,  per:'100g' },
  { name:'Almonds',        kcal:579, p:21,  c:22, f:50, per:'100g' },
  { name:'Salmon',         kcal:208, p:20,  c:0,  f:13, per:'100g' },
  { name:'Sweet Potato',   kcal:86,  p:1.6, c:20, f:0.1, per:'100g' },
  { name:'Whey Protein',   kcal:120, p:24,  c:3,  f:1.5, per:'1 scoop' },
  { name:'Olive Oil',      kcal:884, p:0,   c:0,  f:100, per:'100g' },
];

const GOAL_PRESETS = {
  muscle:    { label:'Build Muscle', kcal:2800, p:200, c:330, f:85 },
  fat:       { label:'Lose Fat',     kcal:1900, p:170, c:170, f:60 },
  strength:  { label:'Strength',     kcal:2700, p:185, c:300, f:90 },
  endurance: { label:'Endurance',    kcal:2500, p:140, c:340, f:75 },
};

/* ══════════════════════════════════════════════════════════
   NUTRITION ROOT
══════════════════════════════════════════════════════════ */
function NutritionScreen({ userGoal='muscle' }) {
  const [goalSet, setGoalSet] = useState(GOAL_PRESETS[userGoal]);
  const [log, setLog] = useState([
    { id:1, name:'Greek Yogurt + Honey',  kcal:240, p:18, c:36, f:4 },
    { id:2, name:'Chicken Rice Bowl',     kcal:560, p:48, c:65, f:12 },
    { id:3, name:'Whey + Banana',         kcal:280, p:26, c:38, f:3 },
  ]);
  const [showAdd, setShowAdd]     = useState(false);
  const [showGoals, setShowGoals] = useState(false);

  const consumed = {
    kcal: log.reduce((a,f) => a + f.kcal, 0),
    p:    log.reduce((a,f) => a + f.p, 0),
    c:    log.reduce((a,f) => a + f.c, 0),
    f:    log.reduce((a,f) => a + f.f, 0),
  };
  const remaining = goalSet.kcal - consumed.kcal;

  function handleAddFood(food, multiplier=1) {
    setLog(l => [...l, {
      id: Date.now(),
      name: food.name,
      kcal: Math.round(food.kcal * multiplier),
      p:    +(food.p * multiplier).toFixed(1),
      c:    +(food.c * multiplier).toFixed(1),
      f:    +(food.f * multiplier).toFixed(1),
    }]);
    setShowAdd(false);
  }

  function removeFood(id) {
    setLog(l => l.filter(f => f.id !== id));
  }

  return (
    <div style={{ flex: 1, overflowY:'auto', background: T.surface }}>
      <ScreenHeader
        title="Nutrition"
        right={<GhostButton label="Goals" onPress={() => setShowGoals(true)}/>}
      />

      <div style={{ padding: `0 ${T.screenH}px`,
        display:'flex', flexDirection:'column',
        gap: T.sectionGap, paddingBottom: T.bottomNavPad }}>

        {/* ═══ CALORIE RING CARD ═══ */}
        <Card padding={16}>
          <div style={{ display:'flex', alignItems:'center', gap: T.md }}>
            <CalorieRing consumed={consumed.kcal} goal={goalSet.kcal}/>
            <div style={{ flex: 1, display:'flex', flexDirection:'column',
              gap: 12 }}>
              <KcalStat label="Goal"      value={goalSet.kcal} color={T.textSecondary}/>
              <KcalStat label="Consumed"  value={consumed.kcal} color={T.accentIron}/>
              <KcalStat label="Remaining" value={remaining}
                color={remaining >= 0 ? T.successLime : T.errorRose}
                negative={remaining < 0}/>
            </div>
          </div>
        </Card>

        {/* ═══ GOAL CHIP ═══ */}
        <div style={{ display:'flex', justifyContent:'center',
          marginTop: -10 }}>
          <Pill bg={T.surfaceHigh} color={T.textSecondary}
            style={{ fontSize: 11 }}>
            Targets for: <span style={{ color: T.textPrimary,
              fontWeight: 700 }}>{goalSet.label}</span>
          </Pill>
        </div>

        {/* ═══ MACRO BARS ═══ */}
        <Card padding={14}>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr',
            gap: 14 }}>
            <MacroCol label="Protein" current={consumed.p} goal={goalSet.p}
              color={T.protein}/>
            <MacroCol label="Carbs"   current={consumed.c} goal={goalSet.c}
              color={T.carbs}/>
            <MacroCol label="Fat"     current={consumed.f} goal={goalSet.f}
              color={T.fat}/>
          </div>
        </Card>

        {/* ═══ TODAY'S LOG ═══ */}
        <div>
          <div style={{ display:'flex', justifyContent:'space-between',
            alignItems:'center', marginBottom: 10 }}>
            <SectionLabel>TODAY'S LOG</SectionLabel>
            <AmberLink label="+ Add Food" onPress={() => setShowAdd(true)}/>
          </div>
          {log.length === 0 ? (
            <Card onPress={() => setShowAdd(true)} padding={24}
              style={{ textAlign:'center', border:`0.5px dashed ${T.divider}` }}>
              <div style={{ width: 36, height: 36, borderRadius:'50%',
                background: T.surfaceHigh, margin:'0 auto 10px',
                display:'flex', alignItems:'center', justifyContent:'center' }}>
                <Icon.Plus c={T.textSecondary} size={16}/>
              </div>
              <div style={{ fontFamily: T.fontBody, fontSize: 13,
                color: T.textSecondary }}>Tap to log your first meal.</div>
            </Card>
          ) : (
            <div style={{ display:'flex', flexDirection:'column', gap: 6 }}>
              {log.map(f => <FoodLogRow key={f.id} food={f} onRemove={() => removeFood(f.id)}/>)}
            </div>
          )}
        </div>

        {/* ═══ THIS WEEK CHART ═══ */}
        <div>
          <SectionHeader label="THIS WEEK"/>
          <WeekKcalChart goal={goalSet.kcal}/>
        </div>

      </div>

      {/* ═══ ADD FOOD SHEET ═══ */}
      <BottomSheet
        open={showAdd}
        onClose={() => setShowAdd(false)}
        title="Add Food"
        height="full"
      >
        <AddFoodSheet onAdd={handleAddFood}/>
      </BottomSheet>

      {/* ═══ EDIT GOALS SHEET ═══ */}
      <BottomSheet
        open={showGoals}
        onClose={() => setShowGoals(false)}
        title="Edit Nutrition Goals"
      >
        <EditGoalsSheet
          current={goalSet}
          onSave={(g) => { setGoalSet(g); setShowGoals(false); }}
        />
      </BottomSheet>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   CALORIE RING
──────────────────────────────────────────────────────── */
function CalorieRing({ consumed, goal }) {
  const r = 44, stroke = 9;
  const size = 100;
  const cx = size / 2;
  const circ = 2 * Math.PI * r;
  const pct = Math.min(consumed / goal, 1);
  const off = circ * (1 - pct);
  return (
    <div style={{ position:'relative', width:size, height:size, flexShrink: 0 }}>
      <svg width={size} height={size}>
        <circle cx={cx} cy={cx} r={r}
          stroke={T.surfaceHigh} strokeWidth={stroke} fill="none"/>
        <circle cx={cx} cy={cx} r={r}
          stroke={T.accentIron} strokeWidth={stroke} fill="none"
          strokeDasharray={circ.toFixed(2)}
          strokeDashoffset={off.toFixed(2)}
          strokeLinecap="round"
          transform={`rotate(-90 ${cx} ${cx})`}
          style={{ transition:'stroke-dashoffset 600ms ease-out' }}/>
      </svg>
      <div style={{ position:'absolute', inset: 0, display:'flex',
        flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 22, fontWeight: 700,
          color: T.textPrimary, fontVariantNumeric:'tabular-nums',
          letterSpacing: '-0.03em', lineHeight: 1 }}>
          {consumed.toLocaleString()}
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 9,
          color: T.textTertiary, marginTop: 2, fontWeight: 600,
          letterSpacing: '0.06em' }}>kcal</div>
      </div>
    </div>
  );
}

function KcalStat({ label, value, color, negative }) {
  return (
    <div>
      <div style={{ fontFamily: T.fontBody, fontSize: 9,
        color: T.textTertiary, letterSpacing: '0.1em',
        textTransform:'uppercase', marginBottom: 2 }}>{label}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 16, fontWeight: 700,
        color: color, fontVariantNumeric:'tabular-nums',
        letterSpacing: '-0.015em' }}>
        {negative && '-'}
        {Math.abs(value).toLocaleString()}
        <span style={{ fontSize: 10, fontWeight: 500, color: T.textTertiary,
          marginLeft: 3 }}>kcal</span>
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   MACRO COLUMN
──────────────────────────────────────────────────────── */
function MacroCol({ label, current, goal, color }) {
  const pct = Math.min(current / goal, 1);
  return (
    <div>
      <div style={{ display:'flex', justifyContent:'space-between',
        alignItems:'baseline', marginBottom: 5 }}>
        <span style={{ fontFamily: T.fontBody, fontSize: 10, fontWeight: 700,
          color: color, letterSpacing: '0.06em',
          textTransform:'uppercase' }}>{label}</span>
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize: 17, fontWeight: 700,
        color: T.textPrimary, fontVariantNumeric:'tabular-nums',
        letterSpacing: '-0.02em', lineHeight: 1 }}>
        {Math.round(current)}<span style={{ fontSize: 10,
          color: T.textTertiary, fontWeight: 500, marginLeft: 2 }}>g</span>
      </div>
      <div style={{ height: 5, background: T.surfaceHigh,
        borderRadius: T.rfull, overflow:'hidden', marginTop: 6 }}>
        <div style={{ height:'100%', width: `${pct*100}%`,
          background: color, borderRadius: T.rfull,
          transition:'width 500ms ease-out' }}/>
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize: 10,
        color: T.textTertiary, marginTop: 4,
        fontVariantNumeric:'tabular-nums' }}>of {goal}g</div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   FOOD LOG ROW
──────────────────────────────────────────────────────── */
function FoodLogRow({ food, onRemove }) {
  return (
    <div style={{
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rmd, padding: '12px 14px',
      display:'flex', alignItems:'center', gap: T.sm,
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 600,
          color: T.textPrimary, letterSpacing: '-0.005em',
          overflow:'hidden', textOverflow:'ellipsis',
          whiteSpace:'nowrap' }}>{food.name}</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 11,
          color: T.textTertiary, marginTop: 2,
          fontVariantNumeric:'tabular-nums' }}>
          P {Math.round(food.p)}g · C {Math.round(food.c)}g · F {Math.round(food.f)}g
        </div>
      </div>
      <div style={{ textAlign:'right' }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
          color: T.accentIron, fontVariantNumeric:'tabular-nums',
          letterSpacing: '-0.015em' }}>
          {food.kcal}
          <span style={{ fontSize: 9, color: T.textTertiary,
            fontWeight: 500, marginLeft: 2 }}>kcal</span>
        </div>
      </div>
      <button onClick={onRemove} style={{
        background:'none', border:'none', cursor:'pointer',
        color: T.textTertiary, fontSize: 18, lineHeight: 1, padding: 4,
      }}>×</button>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   WEEK KCAL CHART
──────────────────────────────────────────────────────── */
function WeekKcalChart({ goal }) {
  const days = ['Mo','Tu','We','Th','Fr','Sa','Su'];
  const data = [2680, 2420, 2150, 2780, 2530, 1880, 0]; // Sun = today, no log
  const todayIdx = 4; // Fri example
  const max = goal * 1.2;
  const goalY = (1 - goal / max) * 100;

  return (
    <Card padding={14}>
      <div style={{ position:'relative', height: 130,
        marginBottom: 8 }}>
        {/* Goal dashed line */}
        <div style={{
          position:'absolute', left: 0, right: 0,
          top: `${goalY}%`, height: 0,
          borderTop: `1px dashed ${alpha(T.accentIron, 0.4)}`,
          zIndex: 1,
        }}/>
        <div style={{
          position:'absolute', right: 0,
          top: `${goalY}%`, transform:'translateY(-100%)',
          fontFamily: T.fontBody, fontSize: 9,
          color: T.accentIron, fontWeight: 600,
          paddingRight: 2, fontVariantNumeric:'tabular-nums',
        }}>{goal} goal</div>

        {/* Bars */}
        <div style={{ display:'flex', alignItems:'flex-end',
          justifyContent:'space-between', height:'100%',
          gap: 6, position:'relative' }}>
          {days.map((d, i) => {
            const val = data[i];
            const h = val === 0 ? 8 : (val / max) * 100;
            const isToday = i === todayIdx;
            const isFuture = i > todayIdx;
            return (
              <div key={d} style={{
                flex: 1, height:'100%',
                display:'flex', flexDirection:'column',
                alignItems:'center', justifyContent:'flex-end',
              }}>
                <div style={{
                  width:'100%',
                  height: `${h}%`,
                  background: isFuture
                    ? T.surfaceHigh
                    : isToday
                      ? T.accentIron
                      : alpha(T.accentIron, 0.35),
                  borderRadius: `${T.rxs}px ${T.rxs}px 0 0`,
                  transition:'height 600ms ease-out',
                }}/>
              </div>
            );
          })}
        </div>
      </div>

      {/* Labels */}
      <div style={{ display:'flex', gap: 6 }}>
        {days.map((d, i) => (
          <div key={d} style={{ flex: 1, textAlign:'center',
            fontFamily: T.fontBody, fontSize: 11,
            fontWeight: i === todayIdx ? 700 : 500,
            color: i === todayIdx ? T.accentIron : T.textTertiary,
          }}>{d}</div>
        ))}
      </div>
    </Card>
  );
}

/* ════════════════════════════════════════════════════════
   ADD FOOD SHEET
═══════════════════════════════════════════════════════ */
function AddFoodSheet({ onAdd }) {
  const [mode, setMode]       = useState('search'); // 'search' | 'manual'
  const [query, setQuery]     = useState('');
  const [selected, setSelected] = useState(null);

  const filtered = SAMPLE_FOODS.filter(f =>
    !query || f.name.toLowerCase().includes(query.toLowerCase())
  );

  if (selected) {
    return <PortionDetail food={selected} onAdd={onAdd}
      onBack={() => setSelected(null)}/>;
  }

  if (mode === 'manual') {
    return <ManualEntry onAdd={onAdd} onBack={() => setMode('search')}/>;
  }

  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ display:'flex', justifyContent:'flex-end',
        marginBottom: 8 }}>
        <AmberLink label="Enter manually →"
          onPress={() => setMode('manual')}/>
      </div>

      <input
        placeholder="Search foods…"
        value={query}
        onChange={e => setQuery(e.target.value)}
        style={{
          width:'100%', background: T.surfaceHigh,
          border: `0.5px solid ${T.divider}`,
          borderRadius: T.rsm, padding: '10px 14px',
          fontFamily: T.fontBody, fontSize: 13,
          color: T.textPrimary, outline:'none', marginBottom: 12,
        }}/>

      <div style={{ display:'flex', flexDirection:'column', gap: 4 }}>
        {filtered.map(f => (
          <div key={f.name} onClick={() => setSelected(f)} style={{
            display:'flex', alignItems:'center', gap: T.sm,
            padding: '10px 8px', borderRadius: T.rsm,
            cursor:'pointer',
            borderBottom: `0.5px solid ${T.divider}`,
          }}>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontFamily: T.fontBody, fontSize: 13,
                fontWeight: 600, color: T.textPrimary }}>{f.name}</div>
              <div style={{ fontFamily: T.fontBody, fontSize: 10,
                color: T.textTertiary, marginTop: 2,
                fontVariantNumeric:'tabular-nums' }}>
                {f.per} · P {f.p}g · C {f.c}g · F {f.f}g
              </div>
            </div>
            <div style={{ fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
              color: T.accentIron, fontVariantNumeric:'tabular-nums' }}>
              {f.kcal}<span style={{ fontSize: 9, color: T.textTertiary,
                fontWeight: 500, marginLeft: 2 }}>kcal</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function PortionDetail({ food, onAdd, onBack }) {
  const [mult, setMult] = useState(1);
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <button onClick={onBack} style={{
        background:'none', border:'none', cursor:'pointer',
        padding: 4, marginBottom: 12, marginLeft: -4,
        display:'flex', alignItems:'center', gap: 4,
        color: T.textSecondary, fontFamily: T.fontBody,
        fontSize: 13, fontWeight: 500,
      }}><Icon.ArrowLeft c={T.textSecondary} size={18}/>Back</button>

      <div style={{ fontFamily: T.fontBody, fontSize: 20, fontWeight: 700,
        color: T.textPrimary, letterSpacing: '-0.025em' }}>{food.name}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 12,
        color: T.textTertiary, marginBottom: T.md }}>per {food.per}</div>

      <Card padding={16}>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr',
          gap: 14, marginBottom: 16 }}>
          <KcalBox label="Calories" value={Math.round(food.kcal * mult)} unit="kcal" accent/>
          <KcalBox label="Protein"  value={(food.p * mult).toFixed(1)} unit="g"/>
          <KcalBox label="Carbs"    value={(food.c * mult).toFixed(1)} unit="g"/>
          <KcalBox label="Fat"      value={(food.f * mult).toFixed(1)} unit="g"/>
        </div>

        <SectionLabel style={{ marginBottom: 6 }}>× PORTION</SectionLabel>
        <div style={{
          background: T.surfaceHigh,
          border: `0.5px solid ${T.divider}`,
          borderRadius: T.rsm, padding: '4px',
          display:'flex', alignItems:'center', gap: 4,
        }}>
          <button onClick={() => setMult(m => Math.max(0.25, m - 0.25))} style={{
            width: 36, height: 36, background:'none', border:'none',
            color: T.textSecondary, fontSize: 16, fontWeight: 700,
            cursor:'pointer',
          }}>−</button>
          <input type="number" step="0.25"
            value={mult}
            onChange={e => setMult(parseFloat(e.target.value) || 0)}
            style={{
              flex: 1, textAlign:'center',
              background:'none', border:'none', outline:'none',
              fontFamily: T.fontBody, fontSize: 17, fontWeight: 700,
              color: T.textPrimary, fontVariantNumeric:'tabular-nums',
            }}/>
          <button onClick={() => setMult(m => m + 0.25)} style={{
            width: 36, height: 36, background:'none', border:'none',
            color: T.textSecondary, fontSize: 16, fontWeight: 700,
            cursor:'pointer',
          }}>+</button>
        </div>
      </Card>

      <div style={{ marginTop: T.md }}>
        <PrimaryButton label="Add to Log" onPress={() => onAdd(food, mult)}/>
      </div>
    </div>
  );
}

function ManualEntry({ onAdd, onBack }) {
  const [name, setName] = useState('');
  const [vals, setVals] = useState({ kcal:'', p:'', c:'', f:'' });
  const [mult, setMult] = useState(1);

  function save() {
    if (!name.trim()) return;
    onAdd({
      name: name.trim(),
      kcal: parseFloat(vals.kcal) || 0,
      p:    parseFloat(vals.p) || 0,
      c:    parseFloat(vals.c) || 0,
      f:    parseFloat(vals.f) || 0,
      per:  'custom',
    }, mult);
  }

  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <button onClick={onBack} style={{
        background:'none', border:'none', cursor:'pointer',
        padding: 4, marginBottom: 12, marginLeft: -4,
        display:'flex', alignItems:'center', gap: 4,
        color: T.textSecondary, fontFamily: T.fontBody,
        fontSize: 13, fontWeight: 500,
      }}><Icon.ArrowLeft c={T.textSecondary} size={18}/>Back to search</button>

      <SectionLabel style={{ marginBottom: 6 }}>FOOD NAME</SectionLabel>
      <input
        placeholder="e.g. Homemade Smoothie"
        value={name}
        onChange={e => setName(e.target.value)}
        style={{
          width:'100%', background: T.surfaceHigh,
          border:`0.5px solid ${T.divider}`,
          borderRadius: T.rsm, padding: '10px 14px',
          fontFamily: T.fontBody, fontSize: 13,
          color: T.textPrimary, outline:'none', marginBottom: T.md,
        }}/>

      <SectionLabel style={{ marginBottom: 6 }}>NUTRITION</SectionLabel>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr',
        gap: 8, marginBottom: T.md }}>
        <ManualField label="Calories" unit="kcal" value={vals.kcal}
          onChange={v => setVals(s => ({ ...s, kcal: v }))}/>
        <ManualField label="Protein"  unit="g"    value={vals.p}
          onChange={v => setVals(s => ({ ...s, p: v }))}/>
        <ManualField label="Carbs"    unit="g"    value={vals.c}
          onChange={v => setVals(s => ({ ...s, c: v }))}/>
        <ManualField label="Fat"      unit="g"    value={vals.f}
          onChange={v => setVals(s => ({ ...s, f: v }))}/>
      </div>

      <SectionLabel style={{ marginBottom: 6 }}>× PORTION (scales all values)</SectionLabel>
      <div style={{
        background: T.surfaceHigh,
        border: `0.5px solid ${T.divider}`,
        borderRadius: T.rsm, padding: '4px',
        display:'flex', alignItems:'center', gap: 4,
        marginBottom: T.md,
      }}>
        <button onClick={() => setMult(m => Math.max(0.25, m - 0.25))} style={{
          width: 36, height: 36, background:'none', border:'none',
          color: T.textSecondary, fontSize: 16, fontWeight: 700,
          cursor:'pointer',
        }}>−</button>
        <input type="number" step="0.25"
          value={mult}
          onChange={e => setMult(parseFloat(e.target.value) || 0)}
          style={{
            flex: 1, textAlign:'center',
            background:'none', border:'none', outline:'none',
            fontFamily: T.fontBody, fontSize: 17, fontWeight: 700,
            color: T.textPrimary, fontVariantNumeric:'tabular-nums',
          }}/>
        <button onClick={() => setMult(m => m + 0.25)} style={{
          width: 36, height: 36, background:'none', border:'none',
          color: T.textSecondary, fontSize: 16, fontWeight: 700,
          cursor:'pointer',
        }}>+</button>
      </div>

      <PrimaryButton label="Add to Log" onPress={save} disabled={!name.trim()}/>
    </div>
  );
}

function ManualField({ label, unit, value, onChange }) {
  return (
    <div>
      <div style={{ fontFamily: T.fontBody, fontSize: 10,
        color: T.textTertiary, letterSpacing: '0.06em',
        textTransform:'uppercase', marginBottom: 4 }}>
        {label} <span style={{ color: T.textTertiary }}>({unit})</span>
      </div>
      <input type="number"
        placeholder="0"
        value={value}
        onChange={e => onChange(e.target.value)}
        style={{
          width:'100%', background: T.surfaceHigh,
          border:`0.5px solid ${T.divider}`,
          borderRadius: T.rsm, padding: '10px 12px',
          fontFamily: T.fontBody, fontSize: 14, fontWeight: 600,
          color: T.textPrimary, outline:'none',
          fontVariantNumeric:'tabular-nums',
        }}/>
    </div>
  );
}

function KcalBox({ label, value, unit, accent }) {
  return (
    <div>
      <div style={{ fontFamily: T.fontBody, fontSize: 10,
        color: T.textTertiary, letterSpacing: '0.06em',
        textTransform:'uppercase', marginBottom: 4 }}>{label}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 19, fontWeight: 700,
        color: accent ? T.accentIron : T.textPrimary,
        fontVariantNumeric:'tabular-nums', letterSpacing: '-0.02em' }}>
        {value}<span style={{ fontSize: 10, color: T.textTertiary,
          fontWeight: 500, marginLeft: 3 }}>{unit}</span>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════
   EDIT GOALS SHEET
═══════════════════════════════════════════════════════ */
function EditGoalsSheet({ current, onSave }) {
  const [preset, setPreset] = useState(null);
  const [kcal, setKcal] = useState(current.kcal);
  const [p, setP] = useState(current.p);
  const [c, setC] = useState(current.c);
  const [f, setF] = useState(current.f);

  function pickPreset(key) {
    setPreset(key);
    const g = GOAL_PRESETS[key];
    setKcal(g.kcal); setP(g.p); setC(g.c); setF(g.f);
  }

  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <SectionLabel style={{ marginBottom: 8 }}>PRESETS</SectionLabel>
      <div style={{ display:'flex', gap: 6, flexWrap:'wrap',
        marginBottom: T.md }}>
        {Object.entries(GOAL_PRESETS).map(([key, g]) => (
          <FilterChip key={key} label={g.label}
            active={preset === key || (preset === null && g.label === current.label)}
            onPress={() => pickPreset(key)}/>
        ))}
      </div>

      <SectionLabel style={{ marginBottom: 6 }}>TARGETS</SectionLabel>
      <div style={{ display:'flex', flexDirection:'column', gap: 8,
        marginBottom: T.md }}>
        <GoalField label="Calories" unit="kcal" value={kcal} onChange={setKcal}/>
        <GoalField label="Protein"  unit="g"    value={p}    onChange={setP}/>
        <GoalField label="Carbs"    unit="g"    value={c}    onChange={setC}/>
        <GoalField label="Fat"      unit="g"    value={f}    onChange={setF}/>
      </div>

      <PrimaryButton label="Save Goals"
        onPress={() => onSave({
          label: preset ? GOAL_PRESETS[preset].label : current.label,
          kcal: parseInt(kcal,10) || 0, p, c, f,
        })}
      />
    </div>
  );
}

function GoalField({ label, unit, value, onChange }) {
  return (
    <div style={{
      background: T.surfaceHigh,
      border:`0.5px solid ${T.divider}`,
      borderRadius: T.rsm,
      padding: '12px 14px',
      display:'flex', alignItems:'center', gap: T.sm,
    }}>
      <div style={{ flex: 1, fontFamily: T.fontBody, fontSize: 13,
        color: T.textPrimary, fontWeight: 500 }}>{label}</div>
      <input type="number"
        value={value}
        onChange={e => onChange(parseFloat(e.target.value) || 0)}
        style={{
          width: 80, textAlign:'right',
          background:'none', border:'none', outline:'none',
          fontFamily: T.fontBody, fontSize: 15, fontWeight: 700,
          color: T.textPrimary, fontVariantNumeric:'tabular-nums',
        }}/>
      <span style={{ fontFamily: T.fontBody, fontSize: 11,
        color: T.textTertiary, width: 26 }}>{unit}</span>
    </div>
  );
}

window.NutritionScreen = NutritionScreen;

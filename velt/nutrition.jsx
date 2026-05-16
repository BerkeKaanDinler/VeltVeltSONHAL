// VELT — Nutrition Screen v2
// Changes: macro colors, remaining color-coded, weekly bars D97706/surfaceHigh+values,
//          Quick Add chip hover, meal dividers, full polish

const { useState } = React;

/* ── Calorie Ring ────────────────────────────────────────── */
function CalorieRing({ current, goal }) {
  const r = 62, stroke = 11;
  const size = (r + stroke) * 2 + 4;
  const cx = size / 2;
  const circ = 2 * Math.PI * r;
  const pct  = Math.min(current / goal, 1);
  const off  = circ * (1 - pct);
  return (
    <div style={{ position:'relative', width:size, height:size,
      display:'flex', alignItems:'center', justifyContent:'center' }}>
      <svg width={size} height={size} style={{ position:'absolute', inset:0 }}>
        <circle cx={cx} cy={cx} r={r}
          stroke={T.surfaceHigh} strokeWidth={stroke} fill="none"/>
        <circle cx={cx} cy={cx} r={r}
          stroke={T.accentIron} strokeWidth={stroke} fill="none"
          strokeDasharray={circ.toFixed(1)}
          strokeDashoffset={off.toFixed(1)}
          strokeLinecap="round"
          transform={`rotate(-90 ${cx} ${cx})`}
          style={{ transition:'stroke-dashoffset 600ms ease-out' }}/>
      </svg>
      <div style={{ textAlign:'center', zIndex:1 }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:30, fontWeight:700,
          color: T.textPrimary, fontVariantNumeric:'tabular-nums',
          letterSpacing:'-0.03em', lineHeight:1 }}>
          {current.toLocaleString()}
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize:11,
          color: T.textTertiary, marginTop:3 }}>
          of {goal.toLocaleString()} kcal
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:700,
          color: T.accentIron, marginTop:4, letterSpacing:'0.06em',
          textTransform:'uppercase' }}>
          {Math.round(pct * 100)}%
        </div>
      </div>
    </div>
  );
}

/* ── Macro Bar ───────────────────────────────────────────── */
function MacroBar({ name, current, goal, unit, color }) {
  const pct = Math.min(current / goal, 1);
  return (
    <div style={{ flex:1, background: T.surfaceElevated,
      borderRadius: T.rmd, padding:`${T.sm}px ${T.sm}px` }}>
      <div style={{ marginBottom:6 }}>
        <span style={{ fontFamily: T.fontDisplay, fontSize:18, fontWeight:700,
          color: T.textPrimary, fontVariantNumeric:'tabular-nums',
          letterSpacing:'-0.02em' }}>{current}</span>
        <span style={{ fontFamily: T.fontBody, fontSize:11,
          fontWeight:400, color: T.textSecondary, marginLeft:2 }}>{unit}</span>
      </div>
      {/* Progress bar — 4px, matching color */}
      <div style={{ height:4, background: T.surfaceHigh,
        borderRadius:2, overflow:'hidden', marginBottom:5 }}>
        <div style={{ width:`${pct*100}%`, height:'100%',
          background: color, borderRadius:2,
          transition:'width 600ms ease-out' }} />
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:600,
        color: T.textTertiary, letterSpacing:'0.06em',
        textTransform:'uppercase' }}>{name}</div>
    </div>
  );
}

/* ── Meal Row ────────────────────────────────────────────── */
function MealRow({ meal, onAdd, isLast }) {
  const [hov, setHov] = useState(false);
  return (
    <div style={{ borderBottom: isLast ? 'none' : `1px solid ${T.divider}` }}>
      <div style={{ display:'flex', alignItems:'center',
        padding:`14px 20px`, gap: T.sm,
        background: hov ? T.surfaceHigh : 'transparent',
        transition:'background 120ms' }}
        onMouseEnter={() => setHov(true)}
        onMouseLeave={() => setHov(false)}>
        <div style={{ flex:1 }}>
          <div style={{ fontFamily: T.fontDisplay, fontSize:14, fontWeight:700,
            color: T.textPrimary, letterSpacing:'-0.01em' }}>{meal.name}</div>
          {meal.items.length > 0 && (
            <div style={{ fontFamily: T.fontBody, fontSize:11,
              color: T.textTertiary, marginTop:2,
              whiteSpace:'nowrap', overflow:'hidden',
              textOverflow:'ellipsis', maxWidth:160 }}>
              {meal.items.join(' · ')}
            </div>
          )}
        </div>
        <span style={{ fontFamily: T.fontDisplay, fontSize:14, fontWeight:700,
          color: meal.kcal > 0 ? T.textSecondary : T.textTertiary,
          fontVariantNumeric:'tabular-nums' }}>
          {meal.kcal > 0 ? `${meal.kcal} kcal` : '—'}
        </span>
        <button onClick={() => onAdd(meal.name)} style={{
          height:30, padding:'0 12px', borderRadius: T.rfull,
          border:`1px solid ${T.accentIron}44`,
          background:'transparent', color: T.accentIron,
          fontFamily: T.fontBody, fontSize:12, fontWeight:600,
          cursor:'pointer', flexShrink:0,
        }}>+ Add</button>
      </div>
    </div>
  );
}

/* ── Quick Add Chip ──────────────────────────────────────── */
function QuickChip({ label, onPress }) {
  const [hov, setHov] = useState(false);
  return (
    <button onClick={() => onPress(label)}
      onMouseEnter={() => setHov(true)}
      onMouseLeave={() => setHov(false)}
      style={{
        padding:'8px 14px', borderRadius:20,
        border: hov ? `1px solid ${T.accentIron}` : `1px solid ${T.divider}`,
        background: T.surfaceElevated,
        color: hov ? T.accentIron : T.textSecondary,
        fontFamily: T.fontBody, fontSize:12, fontWeight:500,
        cursor:'pointer', transition:'border-color 150ms, color 150ms',
      }}>{label}</button>
  );
}

/* ══════════════════════════════════════════════════════════
   NUTRITION SCREEN
══════════════════════════════════════════════════════════ */
function NutritionScreen() {
  const calories = { current: 1840, goal: 2400 };
  // Protein=#D97706, Carbs=#38BDF8, Fat=#84CC16 (per spec)
  const macros = [
    { name:'Protein', current:142, goal:180, unit:'g', color:'#D97706' },
    { name:'Carbs',   current:210, goal:260, unit:'g', color:'#38BDF8' },
    { name:'Fat',     current:58,  goal:75,  unit:'g', color:'#84CC16' },
  ];
  const meals = [
    { name:'Breakfast', kcal:480,  items:['Oats + banana','Greek yogurt'] },
    { name:'Lunch',     kcal:620,  items:['Chicken rice bowl','Side salad'] },
    { name:'Dinner',    kcal:560,  items:['Salmon + veg'] },
    { name:'Snacks',    kcal:180,  items:['Protein bar'] },
  ];
  const quickAdds = ['Chicken Breast','Brown Rice','Greek Yogurt','Banana','Eggs','Oats'];
  const weekDays  = ['M','T','W','T','F','S','S'];
  const weekKcal  = [2180,2350,1920,2400,1840,0,0];
  const todayIdx  = 4;

  const [toast, setToast] = useState(null);

  const remaining = calories.goal - calories.current;
  const remainingColor = remaining < 0
    ? T.errorRose : remaining < 200
    ? T.warningAmber : T.successLime;

  function handleAdd(label) {
    setToast(`Added to ${label}`);
    setTimeout(() => setToast(null), 1600);
  }

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface,
      position:'relative' }}>

      {/* Header */}
      <div style={{ padding:`${T.xl}px ${T.md}px ${T.md}px`,
        display:'flex', justifyContent:'space-between', alignItems:'flex-end' }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:34, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.03em' }}>Nutrition</div>
        <span style={{ fontFamily: T.fontBody, fontSize:12, fontWeight:600,
          color: T.textTertiary, background: T.surfaceElevated,
          padding:'4px 12px', borderRadius: T.rfull }}>Today</span>
      </div>

      <div style={{ padding:`0 ${T.md}px`,
        display:'flex', flexDirection:'column',
        gap:12, paddingBottom: T.xxl }}>

        {/* Calorie summary */}
        <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
          padding:20, display:'flex', flexDirection:'column',
          alignItems:'center', gap: T.md }}>
          <CalorieRing current={calories.current} goal={calories.goal} />
          {/* Remaining — color-coded */}
          <div style={{ textAlign:'center' }}>
            <span style={{ fontFamily: T.fontDisplay, fontSize:17, fontWeight:700,
              color: remainingColor, fontVariantNumeric:'tabular-nums' }}>
              {remaining > 0
                ? `${remaining.toLocaleString()} kcal remaining`
                : `${Math.abs(remaining).toLocaleString()} kcal over goal`}
            </span>
          </div>
          {/* Macros */}
          <div style={{ display:'flex', gap:8, width:'100%' }}>
            {macros.map(m => <MacroBar key={m.name} {...m} />)}
          </div>
        </div>

        {/* Meals */}
        <div>
          <SectionHeader label="Meals" />
          <div style={{ background: T.surfaceElevated,
            borderRadius: T.rmd, overflow:'hidden' }}>
            {meals.map((meal, i) => (
              <MealRow key={meal.name} meal={meal} onAdd={handleAdd}
                isLast={i === meals.length - 1} />
            ))}
          </div>
        </div>

        {/* Quick Add */}
        <div>
          <SectionHeader label="Quick Add" />
          <div style={{ display:'flex', gap: T.xs, flexWrap:'wrap' }}>
            {quickAdds.map(item => (
              <QuickChip key={item} label={item} onPress={handleAdd} />
            ))}
          </div>
        </div>

        {/* Weekly overview */}
        <div>
          <SectionHeader label="This Week" />
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            padding:`${T.sm}px ${T.md}px` }}>
            <div style={{ display:'flex', gap: T.xs,
              justifyContent:'space-between', alignItems:'flex-end' }}>
              {weekDays.map((day, i) => {
                const kcal   = weekKcal[i];
                const pct    = kcal / 2400;
                const isToday = i === todayIdx;
                const barH   = 48;
                return (
                  <div key={i} style={{ display:'flex', flexDirection:'column',
                    alignItems:'center', gap:3, flex:1 }}>
                    {/* Kcal label above */}
                    <div style={{ fontFamily: T.fontBody, fontSize:9,
                      color: kcal > 0 ? T.textTertiary : 'transparent',
                      fontVariantNumeric:'tabular-nums', letterSpacing:'-0.02em',
                      textAlign:'center' }}>
                      {kcal > 0 ? kcal.toLocaleString() : '·'}
                    </div>
                    {/* Bar */}
                    <div style={{ width:'100%', height:barH,
                      background: T.surfaceHigh,
                      borderRadius: T.rsm, overflow:'hidden',
                      position:'relative' }}>
                      {pct > 0 && (
                        <div style={{
                          position:'absolute', bottom:0, left:0, right:0,
                          height:`${pct*100}%`,
                          background: isToday ? T.accentIron : T.surfaceHigh,
                          borderRadius:`0 0 ${T.rsm}px ${T.rsm}px`,
                          transition:'height 600ms ease-out',
                          // subtle border to distinguish from bg
                          borderTop: isToday ? 'none' : `1px solid ${T.divider}`,
                        }} />
                      )}
                    </div>
                    {/* Day label */}
                    <span style={{ fontFamily: T.fontBody, fontSize:10,
                      fontWeight: isToday ? 700 : 500,
                      color: isToday ? T.accentIron : T.textTertiary }}>
                      {day}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Log Meal CTA */}
        <PrimaryButton label="Log Meal" onPress={() => handleAdd('Log')} />

      </div>

      {/* Toast */}
      {toast && (
        <div style={{ position:'absolute', bottom: T.lg,
          left: T.md, right: T.md,
          background: T.surfaceHigh, borderRadius: T.rmd,
          padding:`${T.sm}px ${T.md}px`, textAlign:'center',
          fontFamily: T.fontBody, fontSize:13, color: T.textPrimary,
          animation:'fadeSlideIn 200ms ease-out',
          border:`1px solid ${T.divider}`,
        }}>{toast}</div>
      )}
    </div>
  );
}

Object.assign(window, { NutritionScreen });

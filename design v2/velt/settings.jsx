// VELT — Settings / Profile Screen

const { useState } = React;

function SettingsScreen({ user, onUpdate, themeKey, onThemeChange, isPro }) {
  const [rest, setRest]   = useState(user?.rest ?? 90);
  const [unit, setUnit]   = useState(user?.unit ?? 'kg');
  const [showLevel, setShowLevel] = useState(false);
  const [showGoal, setShowGoal]   = useState(false);
  const [showNutri, setShowNutri] = useState(false);
  const [showRest, setShowRest]   = useState(false);
  const [showDelete, setShowDelete] = useState(false);
  const [showTheme, setShowTheme] = useState(false);

  const goalLabel =
    user?.goal === 'muscle'    ? 'Build Muscle' :
    user?.goal === 'fat'       ? 'Lose Fat' :
    user?.goal === 'strength'  ? 'Strength' :
    user?.goal === 'endurance' ? 'Endurance' :
    'Build Muscle';

  const levelLabel =
    user?.level === 'beg' ? 'Beginner' :
    user?.level === 'int' ? 'Intermediate' :
    user?.level === 'adv' ? 'Advanced' :
    'Intermediate';

  return (
    <div style={{ flex: 1, overflowY:'auto', background: T.surface }}>

      {/* Header */}
      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.lg}px` }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 28,
          fontWeight: 700, color: T.accentIron,
          letterSpacing: '-0.04em', lineHeight: 1 }}>VELT</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: T.textTertiary, marginTop: 8,
          fontVariantNumeric:'tabular-nums' }}>
          Tracking since Mar 12, 2026 · 47 workouts
        </div>
      </div>

      <div style={{ padding: `0 ${T.screenH}px`,
        display:'flex', flexDirection:'column',
        gap: 20, paddingBottom: T.bottomNavPad }}>

        {/* ═══ APPEARANCE ═══ */}
        <Section title="APPEARANCE">
          <SettingRow
            label="Theme"
            value={window.THEMES[themeKey || 'iron']?.name}
            right={
              <div style={{
                width: 22, height: 22, borderRadius:'50%',
                background: T.accentIron,
                border: `2px solid ${T.surfaceElevated}`,
                boxShadow: `0 0 0 1px ${T.divider}`,
              }}/>
            }
            chevron
            onPress={() => setShowTheme(true)}
          />
        </Section>

        {/* ═══ TRAINING ═══ */}
        <Section title="TRAINING">
          <SettingRow
            label="Rest Timer"
            value={`${rest} seconds`}
            chevron
            onPress={() => setShowRest(true)}
          />
          <SettingRow
            label="Weight Unit"
            right={(
              <div style={{
                background: T.surfaceHigh,
                border: `0.5px solid ${T.divider}`,
                borderRadius: T.rfull, padding: 2,
                display:'flex', gap: 2,
              }}>
                {['kg','lbs'].map(u => {
                  const active = unit === u;
                  return (
                    <button key={u} onClick={() => setUnit(u)} style={{
                      padding: '4px 12px', borderRadius: T.rfull,
                      background: active ? T.accentIron : 'transparent',
                      border:'none', cursor:'pointer',
                      color: active ? '#FFF' : T.textTertiary,
                      fontFamily: T.fontBody, fontSize: 11,
                      fontWeight: 700,
                    }}>{u}</button>
                  );
                })}
              </div>
            )}
          />
          <SettingRow
            label="Experience Level"
            value={levelLabel}
            chevron
            onPress={() => setShowLevel(true)}
          />
        </Section>

        {/* ═══ GOALS ═══ */}
        <Section title="GOALS">
          <SettingRow
            label="Fitness Goal"
            right={
              <Pill bg={alpha(T.accentIron, 0.12)} color={T.accentIron}>
                {goalLabel}
              </Pill>
            }
            chevron
            onPress={() => setShowGoal(true)}
          />
          <SettingRow
            label="Nutrition Targets"
            value="2800 kcal · 200g protein"
            chevron
            onPress={() => setShowNutri(true)}
          />
        </Section>

        {/* ═══ DATA ═══ */}
        <Section title="DATA">
          <SettingRow
            label="Workout History"
            value="47 workouts logged"
            chevron
            onPress={() => {}}
          />
          <SettingRow
            label="Export Data"
            right={
              <Pill bg={T.surfaceHigh} color={T.textTertiary}
                style={{ opacity: 0.6 }}>Coming Soon</Pill>
            }
          />
          <SettingRow
            label="Clear All Data"
            danger
            onPress={() => setShowDelete(true)}
          />
        </Section>

        {/* ═══ APP ═══ */}
        <Section title="APP">
          <SettingRow
            label="App Version"
            value="VELT 1.0.0"
          />
          <VeltProCard/>
        </Section>

      </div>

      {/* SHEETS */}
      <BottomSheet open={showRest} onClose={() => setShowRest(false)}
        title="Default Rest Timer">
        <RestTimerSheet value={rest} onChange={setRest}
          onClose={() => setShowRest(false)}/>
      </BottomSheet>

      <BottomSheet open={showLevel} onClose={() => setShowLevel(false)}
        title="Experience Level">
        <LevelSheet current={user?.level || 'int'}
          onSave={(l) => { onUpdate?.({ level: l }); setShowLevel(false); }}/>
      </BottomSheet>

      <BottomSheet open={showGoal} onClose={() => setShowGoal(false)}
        title="Fitness Goal">
        <GoalSheet current={user?.goal || 'muscle'}
          onSave={(g) => { onUpdate?.({ goal: g }); setShowGoal(false); }}/>
      </BottomSheet>

      <BottomSheet open={showDelete} onClose={() => setShowDelete(false)}
        title="Clear All Data?">
        <DeleteConfirmSheet onCancel={() => setShowDelete(false)}
          onConfirm={() => setShowDelete(false)}/>
      </BottomSheet>

      <BottomSheet open={showTheme} onClose={() => setShowTheme(false)}
        title="Choose Theme" height="full">
        <ThemeSheet currentKey={themeKey} isPro={isPro}
          onSelect={(k) => { onThemeChange?.(k); setShowTheme(false); }}/>
      </BottomSheet>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   SECTION
──────────────────────────────────────────────────────── */
function Section({ title, children }) {
  return (
    <div>
      <SectionLabel style={{ marginBottom: 10, paddingLeft: 4 }}>
        {title}
      </SectionLabel>
      <Card padding={0}>
        {children}
      </Card>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   SETTING ROW
──────────────────────────────────────────────────────── */
function SettingRow({ label, value, right, chevron, onPress, danger, isLast }) {
  const [pressed, setPressed] = useState(false);
  return (
    <div
      onPointerDown={() => onPress && setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      onClick={onPress}
      style={{
        padding: '14px 16px',
        background: pressed ? T.surfaceHigh : 'transparent',
        display:'flex', alignItems:'center', gap: T.sm,
        cursor: onPress ? 'pointer' : 'default',
        borderBottom: isLast ? 'none' : `0.5px solid ${alpha(T.divider, 0.5)}`,
        transition:'background 120ms',
      }}
    >
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 500,
          color: danger ? T.errorRose : T.textPrimary,
          letterSpacing: '-0.005em' }}>{label}</div>
        {value && (
          <div style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, marginTop: 2 }}>{value}</div>
        )}
      </div>
      {right}
      {chevron && !right && <Icon.Chevron c={T.textTertiary}/>}
      {chevron && right && <Icon.Chevron c={T.textTertiary}/>}
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   VELT PRO CARD
──────────────────────────────────────────────────────── */
function VeltProCard() {
  return (
    <div style={{
      position:'relative', overflow:'hidden',
      padding: '14px 16px',
      borderTop: `0.5px solid ${alpha(T.divider, 0.5)}`,
      background: 'transparent',
      borderRadius:'0 0 12px 12px',
    }}>
      {/* Amber border accent on left */}
      <div style={{ position:'absolute', left: 0, top: '15%',
        bottom: '15%', width: 2, background: T.accentIron,
        borderRadius: '0 2px 2px 0' }}/>

      <div style={{ display:'flex', alignItems:'center', gap: T.sm }}>
        <div style={{ width: 36, height: 36, borderRadius:'50%',
          background: alpha(T.accentIron, 0.15),
          display:'flex', alignItems:'center', justifyContent:'center',
          flexShrink: 0 }}>
          <Icon.Lock c={T.accentIron} size={16}/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.01em' }}>VELT Pro</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, marginTop: 2 }}>
            Advanced Analytics & more coming soon
          </div>
        </div>
        <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
          style={{ fontSize: 9, fontWeight: 700 }}>STAY TUNED</Pill>
      </div>
    </div>
  );
}

/* ════════════════════════════════════════════════════════
   SHEETS
═══════════════════════════════════════════════════════ */

function RestTimerSheet({ value, onChange, onClose }) {
  const [v, setV] = useState(value);
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ textAlign:'center', padding: '20px 0' }}>
        <div style={{ fontFamily: T.fontBody, fontSize: 48, fontWeight: 700,
          color: T.accentIron, letterSpacing: '-0.04em',
          fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>{v}</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: T.textSecondary, marginTop: 4 }}>seconds</div>
      </div>

      {/* Slider */}
      <input type="range" min={30} max={300} step={15}
        value={v} onChange={e => setV(parseInt(e.target.value, 10))}
        style={{ width:'100%', accentColor: T.accentIron,
          marginBottom: 8 }}/>

      <div style={{ display:'flex', justifyContent:'space-between',
        fontFamily: T.fontBody, fontSize: 10, color: T.textTertiary,
        marginBottom: 20 }}>
        <span>30s</span>
        <span>5min</span>
      </div>

      {/* Quick chips */}
      <div style={{ display:'flex', gap: 6, justifyContent:'center',
        marginBottom: 20, flexWrap:'wrap' }}>
        {[60, 90, 120, 180].map(t => (
          <FilterChip key={t} label={`${t}s`}
            active={v === t} onPress={() => setV(t)}/>
        ))}
      </div>

      <PrimaryButton label="Save"
        onPress={() => { onChange(v); onClose(); }}/>
    </div>
  );
}

function LevelSheet({ current, onSave }) {
  const [pick, setPick] = useState(current);
  const items = [
    { id:'beg', label:'Beginner',     desc:'Less than 1 year of training', rest:75  },
    { id:'int', label:'Intermediate', desc:'1 – 3 years of training',      rest:90  },
    { id:'adv', label:'Advanced',     desc:'3+ years, programmed training', rest:120 },
  ];
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ display:'flex', flexDirection:'column', gap: 8,
        marginBottom: 16 }}>
        {items.map(item => {
          const active = pick === item.id;
          return (
            <div key={item.id} onClick={() => setPick(item.id)} style={{
              padding: 14, borderRadius: T.rmd,
              background: active ? alpha(T.accentIron, 0.08) : T.surfaceHigh,
              border: active
                ? `1.5px solid ${T.accentIron}`
                : `0.5px solid ${T.divider}`,
              cursor:'pointer', transition:'all 200ms',
              display:'flex', alignItems:'center', gap: T.sm,
            }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
                  color: T.textPrimary }}>{item.label}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 11,
                  color: T.textSecondary, marginTop: 2 }}>{item.desc}</div>
                <div style={{ fontFamily: T.fontBody, fontSize: 10,
                  color: T.textTertiary, marginTop: 4,
                  letterSpacing: '0.04em' }}>
                  Rest · {item.rest}s
                </div>
              </div>
              {active && (
                <div style={{ width: 22, height: 22, borderRadius:'50%',
                  background: T.accentIron,
                  display:'flex', alignItems:'center', justifyContent:'center' }}>
                  <Icon.Check c="#FFF" sw={2.4}/>
                </div>
              )}
            </div>
          );
        })}
      </div>
      <PrimaryButton label="Save" onPress={() => onSave(pick)}/>
    </div>
  );
}

function GoalSheet({ current, onSave }) {
  const [pick, setPick] = useState(current);
  const items = [
    { id:'muscle',    label:'Build Muscle', desc:'Add lean mass & size',     color:'#D97706' },
    { id:'fat',       label:'Lose Fat',     desc:'Lean out, keep strength', color:'#22C55E' },
    { id:'strength',  label:'Strength',     desc:'Push your 1RM higher',    color:'#6366F1' },
    { id:'endurance', label:'Endurance',    desc:'Last longer, recover faster', color:'#06B6D4' },
  ];
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 8,
        marginBottom: 16 }}>
        {items.map(item => {
          const active = pick === item.id;
          return (
            <div key={item.id} onClick={() => setPick(item.id)} style={{
              padding: 14, borderRadius: T.rmd,
              background: active ? alpha(item.color, 0.08) : T.surfaceHigh,
              border: active
                ? `1.5px solid ${item.color}`
                : `0.5px solid ${T.divider}`,
              cursor:'pointer', transition:'all 200ms',
              minHeight: 88,
            }}>
              <div style={{ fontFamily: T.fontBody, fontSize: 13,
                fontWeight: 700, color: T.textPrimary,
                letterSpacing: '-0.005em' }}>{item.label}</div>
              <div style={{ fontFamily: T.fontBody, fontSize: 11,
                color: T.textSecondary, marginTop: 4, lineHeight: 1.4 }}>
                {item.desc}
              </div>
            </div>
          );
        })}
      </div>
      <PrimaryButton label="Save" onPress={() => onSave(pick)}/>
    </div>
  );
}

function DeleteConfirmSheet({ onCancel, onConfirm }) {
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ fontFamily: T.fontBody, fontSize: 14,
        color: T.textSecondary, lineHeight: 1.6, marginBottom: 20 }}>
        This will permanently delete all your workouts, routines, PRs,
        and nutrition logs. <span style={{ color: T.errorRose,
        fontWeight: 700 }}>This cannot be undone.</span>
      </div>
      <div style={{ display:'flex', gap: 8 }}>
        <GhostButton label="Cancel" onPress={onCancel}
          style={{ flex: 1, height: 44 }}/>
        <button onClick={onConfirm} style={{
          flex: 1, height: 44, borderRadius: T.rsm, border:'none',
          background: T.errorRose, color: '#FFF',
          fontFamily: T.fontBody, fontSize: 13, fontWeight: 700,
          cursor:'pointer',
        }}>Delete Everything</button>
      </div>
    </div>
  );
}

window.SettingsScreen = SettingsScreen;

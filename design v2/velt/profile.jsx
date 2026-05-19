// VELT — Profile Screen
// Pro banner, preferences, theme selector, data, about, danger zone

const { useState } = React;

/* ── Theme Preview Card ──────────────────────────────────── */
function ThemeCard({ preview, active, onSelect }) {
  return (
    <div onClick={() => onSelect(preview.key)} style={{
      display:'flex', flexDirection:'column', alignItems:'center',
      gap:5, cursor:'pointer',
    }}>
      <div style={{
        width:88, height:68, borderRadius: T.rsm,
        background: preview.bg, overflow:'hidden', position:'relative',
        border: active
          ? `2px solid ${preview.accent}`
          : `2px solid transparent`,
        transition:'border 200ms',
      }}>
        <div style={{ position:'absolute', top:10, left:8, right:8, height:20,
          background: preview.card, borderRadius:4, opacity:0.9 }} />
        {/* 2 color dots: bg tone + accent */}
        <div style={{ position:'absolute', bottom:8, left:8, display:'flex', gap:4 }}>
          <div style={{ width:8, height:8, borderRadius:'50%',
            background: preview.card, border:'1px solid #ffffff22', flexShrink:0 }} />
          <div style={{ width:8, height:8, borderRadius:'50%',
            background: preview.accent, flexShrink:0 }} />
        </div>
        {active && (
          <div style={{ position:'absolute', top:4, right:5,
            width:14, height:14, borderRadius:'50%',
            background: preview.accent,
            display:'flex', alignItems:'center', justifyContent:'center' }}>
            <svg width="7" height="6" viewBox="0 0 7 6" fill="none">
              <path d="M1 3L2.5 4.5L6 1.5" stroke="#fff"
                strokeWidth="1.3" strokeLinecap="round"/>
            </svg>
          </div>
        )}
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize:10, fontWeight:500,
        color: active ? preview.accent : T.textTertiary,
        textAlign:'center', whiteSpace:'nowrap',
        letterSpacing:'0.02em' }}>{preview.name}</div>
    </div>
  );
}

/* ── Setting Row ─────────────────────────────────────────── */
function SettingRow({ label, value, sub, onPress, danger, rightEl }) {
  return (
    <div onClick={onPress} style={{
      display:'flex', alignItems:'center', justifyContent:'space-between',
      padding:`14px 20px`, cursor: onPress ? 'pointer' : 'default',
      borderBottom:`1px solid ${T.divider}44`,
      gap: T.sm,
    }}>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ fontFamily: T.fontBody, fontSize:14, fontWeight:500,
          color: danger ? T.errorRose : T.textPrimary,
          letterSpacing:'-0.005em' }}>{label}</div>
        {sub && (
          <div style={{ fontFamily: T.fontBody, fontSize:11,
            color: T.textTertiary, marginTop:2 }}>{sub}</div>
        )}
      </div>
      {rightEl || (
        value && (
          <div style={{ display:'flex', alignItems:'center', gap: T.xs }}>
            <span style={{ fontFamily: T.fontBody, fontSize:13,
              color: T.textTertiary }}>{value}</span>
            {onPress && (
              <svg width="6" height="10" viewBox="0 0 6 10" fill="none">
                <path d="M1 1L5 5L1 9" stroke={T.textTertiary}
                  strokeWidth="1.4" strokeLinecap="round"/>
              </svg>
            )}
          </div>
        )
      )}
    </div>
  );
}

/* ── Toggle ──────────────────────────────────────────────── */
function Toggle({ value, onChange }) {
  return (
    <div onClick={() => onChange(!value)} style={{
      width:42, height:24, borderRadius: T.rfull,
      background: value ? T.accentIron : T.surfaceHigh,
      position:'relative', cursor:'pointer', flexShrink:0,
      transition:'background 200ms',
    }}>
      <div style={{
        position:'absolute', top:3,
        left: value ? 21 : 3,
        width:18, height:18, borderRadius:'50%',
        background:'#fff',
        transition:'left 200ms',
        boxShadow:'0 1px 3px #0004',
      }} />
    </div>
  );
}

/* ── Section block ───────────────────────────────────────── */
function ProfileSection({ title, children }) {
  return (
    <div>
      {title && (
        <div style={{ padding:`${T.sm}px ${T.md}px 8px`,
          fontFamily: T.fontBody, fontSize:11, fontWeight:600,
          color: T.textTertiary, letterSpacing:'0.08em',
          textTransform:'uppercase' }}>{title}</div>
      )}
      <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
        overflow:'hidden' }}>
        {children}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════
   PROFILE SCREEN
══════════════════════════════════════════════════════════ */
function ProfileScreen({ currentTheme, onThemeChange }) {
  const [unit, setUnit]       = useState('kg');
  const [restTime, setRest]   = useState(90);
  const [isPro]               = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const themes = window.THEME_PREVIEWS || [];

  return (
    <div style={{ flex:1, overflowY:'auto', background: T.surface }}>
      {/* Header */}
      <div style={{ padding:`${T.xl}px ${T.md}px ${T.md}px` }}>
        <div style={{ fontFamily: T.fontDisplay, fontSize:34, fontWeight:700,
          color: T.textPrimary, letterSpacing:'-0.03em' }}>Profile</div>
      </div>

      <div style={{ padding:`0 ${T.md}px`, display:'flex',
        flexDirection:'column', gap:20, paddingBottom: T.xxl }}>

        {/* ── Pro Banner ── */}
        {!isPro && (
          <div style={{ background: T.surfaceElevated, borderRadius: T.rmd,
            overflow:'hidden', position:'relative' }}>
            {/* left 4px accent bar */}
            <div style={{ position:'absolute', left:0, top:0, bottom:0,
              width:4, background: T.accentIron }} />
            <div style={{ padding:20 }}>
              <div style={{ display:'flex', alignItems:'center',
                gap: T.xs, marginBottom: T.sm }}>
                <span style={{ fontFamily: T.fontBody, fontSize:10,
                  fontWeight:700, color: T.accentIron,
                  background:`${T.accentIron}18`, padding:'2px 8px',
                  borderRadius: T.rfull, letterSpacing:'0.1em',
                  textTransform:'uppercase' }}>Free Plan</span>
              </div>
              <div style={{ fontFamily: T.fontDisplay, fontSize:17,
                fontWeight:700, color: T.textPrimary,
                letterSpacing:'-0.01em', marginBottom:6 }}>
                Upgrade to VELT Pro
              </div>
              <div style={{ fontFamily: T.fontBody, fontSize:12,
                color: T.textSecondary, marginBottom: T.md,
                lineHeight:1.55 }}>
                Unlimited routines · Full history · Advanced analytics
              </div>
              <PrimaryButton label="Upgrade — From $4.99/mo"
                style={{ maxWidth:280 }} onPress={() => {}} />
            </div>
          </div>
        )}

        {/* ── Preferences ── */}
        <ProfileSection title="Preferences">
          <SettingRow label="Weight Unit" rightEl={
            <div style={{ display:'flex', background: T.surfaceHigh,
              borderRadius: T.rsm, overflow:'hidden' }}>
              {['kg','lb'].map(u => (
                <button key={u} onClick={() => setUnit(u)} style={{
                  padding:'4px 14px', border:'none',
                  background: unit===u ? T.accentIron : 'transparent',
                  color: unit===u ? '#fff' : T.textTertiary,
                  fontFamily: T.fontBody, fontSize:12, fontWeight:700,
                  cursor:'pointer', transition:'background 200ms',
                }}>{u}</button>
              ))}
            </div>
          } />
          <SettingRow
            label="Default Rest Timer"
            value={`${restTime}s`}
            rightEl={
              <div style={{ display:'flex', alignItems:'center', gap: T.xs }}>
                <button onClick={() => setRest(r => Math.max(30, r-15))}
                  style={{ width:28, height:28, borderRadius: T.rsm,
                    background: T.surfaceHigh, border:'none',
                    color: T.textSecondary, fontSize:16, cursor:'pointer',
                    display:'flex', alignItems:'center', justifyContent:'center' }}>−</button>
                <span style={{ fontFamily: T.fontBody, fontSize:13,
                  color: T.textPrimary, fontVariantNumeric:'tabular-nums',
                  minWidth:36, textAlign:'center' }}>{restTime}s</span>
                <button onClick={() => setRest(r => Math.min(300, r+15))}
                  style={{ width:28, height:28, borderRadius: T.rsm,
                    background: T.surfaceHigh, border:'none',
                    color: T.textSecondary, fontSize:16, cursor:'pointer',
                    display:'flex', alignItems:'center', justifyContent:'center' }}>+</button>
              </div>
            }
          />
        </ProfileSection>

        {/* ── Theme Selector ── */}
        <ProfileSection title="Appearance">
          <div style={{ padding:`${T.sm}px 20px ${T.md}px` }}>
            <div style={{ fontFamily: T.fontBody, fontSize:14, fontWeight:500,
              color: T.textPrimary, marginBottom: T.sm }}>Theme</div>
            {/* Theme grid — 5 per row, 2 rows, horizontal scroll */}
            <div style={{ overflowX:'auto', paddingBottom:4 }}>
              <div style={{
                display:'grid',
                gridTemplateColumns:'repeat(5, 88px)',
                gridTemplateRows:'auto auto',
                gap:8,
                width:'fit-content',
              }}>
                {themes.map(preview => (
                  <ThemeCard
                    key={preview.key}
                    preview={preview}
                    active={currentTheme === preview.key}
                    onSelect={onThemeChange}
                  />
                ))}
              </div>
            </div>
            <div style={{ fontFamily: T.fontBody, fontSize:11,
              color: T.textTertiary, marginTop: T.xs }}>
              {themes.find(t => t.key === currentTheme)?.name || 'Iron Dark'}
            </div>
          </div>
        </ProfileSection>

        {/* ── Data ── */}
        <ProfileSection title="Data">
          <SettingRow label="Export as CSV" value="" onPress={() => {}} />
          <SettingRow label="Export as JSON" value="" onPress={() => {}} />
          <SettingRow label="iCloud Backup" sub="Encrypted end-to-end"
            rightEl={
              <div style={{ display:'flex', alignItems:'center', gap: T.xs }}>
                <span style={{ fontFamily: T.fontBody, fontSize:10,
                  fontWeight:700, color: T.accentIron,
                  background:`${T.accentIron}18`,
                  padding:'2px 7px', borderRadius: T.rfull,
                  letterSpacing:'0.05em' }}>PRO</span>
                <svg width="12" height="14" viewBox="0 0 12 14" fill="none">
                  <rect x="1" y="5" width="10" height="9" rx="1.5"
                    stroke={T.textTertiary} strokeWidth="1.4"/>
                  <path d="M3 5V3.5a3 3 0 0 1 6 0V5"
                    stroke={T.textTertiary} strokeWidth="1.4" strokeLinecap="round"/>
                </svg>
              </div>
            }
          />
        </ProfileSection>

        {/* ── About ── */}
        <ProfileSection title="About">
          <SettingRow label="Version" value="1.0.0 (build 42)" />
          <SettingRow label="Restore Purchases" value="" onPress={() => {}} />
          <SettingRow label="Privacy Policy" value="" onPress={() => {}} />
          <SettingRow label="Terms of Service" value="" onPress={() => {}} />
        </ProfileSection>

        {/* ── Danger Zone ── */}
        <ProfileSection title="Danger Zone">
          {!confirmDelete ? (
            <SettingRow
              label="Delete All Data"
              sub="This cannot be undone"
              danger
              onPress={() => setConfirmDelete(true)}
            />
          ) : (
            <div style={{ padding:20 }}>
              <div style={{ fontFamily: T.fontBody, fontSize:13,
                color: T.textSecondary, marginBottom: T.md, lineHeight:1.5 }}>
                All your workouts, routines and PRs will be permanently deleted.
                Are you sure?
              </div>
              <div style={{ display:'flex', gap: T.sm }}>
                <button onClick={() => setConfirmDelete(false)} style={{
                  flex:1, height:44, borderRadius: T.rsm,
                  border:`1px solid ${T.divider}`,
                  background:'transparent', color: T.textSecondary,
                  fontFamily: T.fontBody, fontSize:14, fontWeight:600,
                  cursor:'pointer',
                }}>Cancel</button>
                <button onClick={() => setConfirmDelete(false)} style={{
                  flex:1, height:44, borderRadius: T.rsm, border:'none',
                  background:`${T.errorRose}22`, color: T.errorRose,
                  fontFamily: T.fontBody, fontSize:14, fontWeight:600,
                  cursor:'pointer',
                }}>Delete All</button>
              </div>
            </div>
          )}
        </ProfileSection>

      </div>
    </div>
  );
}

Object.assign(window, { ProfileScreen });

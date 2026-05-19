// VELT — Theme Picker Sheet
// Shown from Settings → Theme. 4 themes (2 free + 2 pro).
// Tapping a Pro theme when !isPro shows an upgrade prompt instead.

const { useState } = React;

function ThemeSheet({ currentKey, isPro, onSelect }) {
  const [upgradePrompt, setUpgradePrompt] = useState(null);
  const themes = window.THEME_KEYS.map(k => ({ key: k, ...window.THEMES[k] }));

  function pick(theme) {
    if (theme.tier === 'pro' && !isPro) {
      setUpgradePrompt(theme);
      return;
    }
    onSelect(theme.key);
  }

  if (upgradePrompt) {
    return <UpgradePromptInline
      theme={upgradePrompt}
      onBack={() => setUpgradePrompt(null)}/>;
  }

  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <div style={{ fontFamily: T.fontBody, fontSize: 12,
        color: T.textTertiary, marginBottom: 16, lineHeight: 1.5 }}>
        Theme changes apply instantly across every screen.
      </div>

      {/* FREE section */}
      <SectionLabel style={{ marginBottom: 8 }}>FREE</SectionLabel>
      <div style={{ display:'flex', flexDirection:'column', gap: 8,
        marginBottom: 20 }}>
        {themes.filter(t => t.tier === 'free').map(t => (
          <ThemeCard key={t.key} theme={t}
            active={currentKey === t.key}
            locked={false}
            onSelect={() => pick(t)}/>
        ))}
      </div>

      {/* PRO section */}
      <div style={{ display:'flex', alignItems:'center',
        gap: 6, marginBottom: 8 }}>
        <SectionLabel>VELT PRO</SectionLabel>
        {!isPro && (
          <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
            style={{ fontSize: 9, fontWeight: 700 }}>UPGRADE</Pill>
        )}
      </div>
      <div style={{ display:'flex', flexDirection:'column', gap: 8 }}>
        {themes.filter(t => t.tier === 'pro').map(t => (
          <ThemeCard key={t.key} theme={t}
            active={currentKey === t.key}
            locked={!isPro}
            onSelect={() => pick(t)}/>
        ))}
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   THEME PREVIEW CARD
──────────────────────────────────────────────────────── */
function ThemeCard({ theme, active, locked, onSelect }) {
  return (
    <div onClick={onSelect} style={{
      background: T.surfaceHigh,
      border: active
        ? `1.5px solid ${T.accentIron}`
        : `0.5px solid ${T.divider}`,
      borderRadius: T.rmd,
      padding: 12, cursor:'pointer',
      display:'flex', alignItems:'center', gap: 12,
      position:'relative', overflow:'hidden',
    }}>
      {/* Preview swatch */}
      <div style={{
        width: 64, height: 64, borderRadius: T.rsm,
        background: theme.surface, position:'relative',
        flexShrink: 0, overflow:'hidden',
        border: `0.5px solid ${theme.divider}`,
      }}>
        <div style={{
          position:'absolute', top: 8, left: 6, right: 6,
          height: 14,
          background: theme.surfaceElevated,
          borderRadius: 3,
        }}/>
        <div style={{
          position:'absolute', top: 26, left: 6,
          width: 28, height: 8,
          background: theme.surfaceHigh, borderRadius: 2,
        }}/>
        <div style={{
          position:'absolute', bottom: 8, left: 6,
          width: 18, height: 18, borderRadius:'50%',
          background: theme.accentIron,
        }}/>
        <div style={{
          position:'absolute', bottom: 14, right: 6,
          width: 22, height: 6,
          background: theme.accentIron, borderRadius: 2,
          opacity: 0.6,
        }}/>
      </div>

      {/* Info */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display:'flex', alignItems:'center',
          gap: 6, marginBottom: 2 }}>
          <span style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.01em' }}>
            {theme.name}
          </span>
          {locked && <Icon.Lock c={T.textTertiary} size={12}/>}
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 11,
          color: T.textTertiary, lineHeight: 1.4 }}>
          {theme.description}
        </div>
      </div>

      {/* Trailing indicator */}
      {active ? (
        <div style={{ width: 22, height: 22, borderRadius:'50%',
          background: T.accentIron, flexShrink: 0,
          display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon.Check c="#FFF" sw={2.4}/>
        </div>
      ) : locked ? (
        <Pill bg={alpha(T.accentIron, 0.15)} color={T.accentIron}
          style={{ fontSize: 9, fontWeight: 700 }}>PRO</Pill>
      ) : null}
    </div>
  );
}

/* ── Inline upgrade prompt when user taps a locked theme ── */
function UpgradePromptInline({ theme, onBack }) {
  return (
    <div style={{ padding: `0 ${T.md}px ${T.md}px` }}>
      <button onClick={onBack} style={{
        background:'none', border:'none', cursor:'pointer',
        padding: 4, marginBottom: 12, marginLeft: -4,
        display:'flex', alignItems:'center', gap: 4,
        color: T.textSecondary, fontFamily: T.fontBody,
        fontSize: 13, fontWeight: 500,
      }}>
        <Icon.ArrowLeft c={T.textSecondary} size={18}/>Back to themes
      </button>

      {/* Big preview */}
      <div style={{
        background: theme.surface,
        border: `0.5px solid ${theme.divider}`,
        borderRadius: T.rlg, padding: 20,
        marginBottom: 20, textAlign:'center',
      }}>
        <div style={{ width: 50, height: 50, borderRadius:'50%',
          background: alpha(theme.accentIron, 0.18),
          display:'flex', alignItems:'center', justifyContent:'center',
          margin:'0 auto 12px' }}>
          <Icon.Lock c={theme.accentIron} size={20}/>
        </div>
        <div style={{ fontFamily: T.fontBody, fontSize: 20,
          fontWeight: 700, color: theme.textPrimary,
          letterSpacing: '-0.02em' }}>{theme.name}</div>
        <div style={{ fontFamily: T.fontBody, fontSize: 12,
          color: theme.textSecondary, marginTop: 6,
          maxWidth: 240, margin:'6px auto 0', lineHeight: 1.5 }}>
          {theme.description}
        </div>
      </div>

      <div style={{ fontFamily: T.fontBody, fontSize: 13,
        color: T.textSecondary, textAlign:'center', lineHeight: 1.5,
        marginBottom: 16 }}>
        Premium themes are part of <span style={{ color: T.accentIron,
        fontWeight: 700 }}>VELT Pro</span>, alongside advanced analytics,
        cloud backup, and more.
      </div>

      <PrimaryButton label="Upgrade to VELT Pro" onPress={() => {}}/>
    </div>
  );
}

window.ThemeSheet = ThemeSheet;

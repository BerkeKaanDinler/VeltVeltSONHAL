// VELT — App Shell v2
// Theme state + Object.assign mutation for real-time re-theming
// Profile tab added as 4th nav item

const { useState } = React;

const SAFE_TOP = 62;

function SafeArea() {
  return <div style={{ height: SAFE_TOP, flexShrink:0, background: T.surface }} />;
}

function VeltApp() {
  const [screen, setScreen]       = useState('onboarding');
  const [activeTab, setActiveTab] = useState('home');
  const [workoutName, setWorkoutName] = useState('Push A — Chest / Shoulders');
  const [themeKey, setThemeKey]   = useState('iron');

  // Apply theme: mutate window.T in place so all components pick up new colors
  const applyTheme = (key) => {
    const theme = window.THEMES && window.THEMES[key];
    if (!theme) return;
    Object.assign(window.T, theme);
    setThemeKey(key);
  };

  // Expose globally for profile screen
  window.setVeltTheme = applyTheme;

  function startWorkout(name) {
    if (name) setWorkoutName(name);
    setScreen('workout');
  }
  function finishWorkout() { setScreen('summary'); }
  function doneWithSummary() {
    setActiveTab('home');
    setScreen('home');
  }
  function navigate(tab) {
    setActiveTab(tab);
    setScreen(tab);
  }

  /* ── Onboarding ─────────────────────────────────────────── */
  if (screen === 'onboarding') return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column',
      background: T.surface }}>
      <SafeArea />
      <OnboardingScreen onFinish={() => { setScreen('home'); setActiveTab('home'); }} />
    </div>
  );

  /* ── Active Workout ─────────────────────────────────────── */
  if (screen === 'workout') return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column',
      background: T.surface }}>
      <SafeArea />
      <ActiveWorkoutScreen routineName={workoutName} onFinish={finishWorkout} />
    </div>
  );

  /* ── Workout Summary ────────────────────────────────────── */
  if (screen === 'summary') return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column',
      background: T.surface }}>
      <SafeArea />
      <WorkoutSummaryScreen onDone={doneWithSummary} />
    </div>
  );

  /* ── Main App — tab bar ─────────────────────────────────── */
  const tabScreen = (() => {
    if (activeTab === 'home')
      return <HomeScreen onStartWorkout={() => startWorkout()} onNavigate={navigate} />;
    if (activeTab === 'train')
      return <TrainScreen onStartWorkout={() => startWorkout()} />;
    if (activeTab === 'nutrition')
      return <NutritionScreen />;
    if (activeTab === 'progress')
      return <ProgressScreen />;
    if (activeTab === 'profile')
      return <ProfileScreen currentTheme={themeKey} onThemeChange={applyTheme} />;
    return null;
  })();

  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column',
      background: T.surface }}>
      <SafeArea />
      {tabScreen}
      <BottomNav active={activeTab} onNavigate={navigate} />
    </div>
  );
}

window.VeltApp = VeltApp;

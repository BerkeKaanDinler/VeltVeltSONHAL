// VELT — App Shell with detail screens + theme state

const { useState } = React;

function VeltApp() {
  // screens: 'onboarding' | 'home' | 'train' | 'nutrition' | 'progress' |
  //          'settings' | 'workout' | 'complete' |
  //          'workout-detail' | 'exercise-detail' | 'pr-detail'
  const [screen, setScreen]       = useState('onboarding');
  const [activeTab, setActiveTab] = useState('home');
  const [prevTab, setPrevTab]     = useState('home');
  const [workoutName, setWorkoutName] = useState('Push A');
  const [themeKey, setThemeKey]   = useState('iron');
  const [isPro, setIsPro]         = useState(false);
  const [user, setUser] = useState({
    goal: 'muscle', level: 'int', unit: 'kg', rest: 90,
  });

  function startWorkout(name) {
    if (name) setWorkoutName(name);
    setScreen('workout');
  }
  function finishWorkout() { setScreen('complete'); }
  function doneWithComplete() {
    setActiveTab('home');
    setScreen('home');
  }

  function navigate(tab) {
    setPrevTab(activeTab);
    setActiveTab(tab);
    setScreen(tab);
  }

  function openWorkoutDetail() {
    setPrevTab(activeTab);
    setScreen('workout-detail');
  }
  function openExerciseDetail() {
    setPrevTab(activeTab);
    setScreen('exercise-detail');
  }
  function openPRDetail() {
    setPrevTab(activeTab);
    setScreen('pr-detail');
  }
  function backFromDetail() {
    setScreen(prevTab);
  }

  function changeTheme(key) {
    setThemeKey(key);
    window.applyTheme(key);
  }
  function updateUser(patch) { setUser(u => ({ ...u, ...patch })); }

  // ── ONBOARDING ──────────────────────────────────────
  if (screen === 'onboarding') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <OnboardingScreen onFinish={(data) => {
          setUser(u => ({ ...u, ...data }));
          setScreen('home'); setActiveTab('home');
        }}/>
      </div>
    );
  }

  // ── ACTIVE WORKOUT (no tab bar) ─────────────────────
  if (screen === 'workout') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <ActiveWorkoutScreen routineName={workoutName} onFinish={finishWorkout}/>
      </div>
    );
  }
  if (screen === 'complete') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <WorkoutCompleteScreen workoutName={workoutName}
          onDone={doneWithComplete} onShare={() => {}}/>
      </div>
    );
  }

  // ── DETAIL SCREENS (no tab bar) ─────────────────────
  if (screen === 'workout-detail') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <WorkoutDetailScreen onBack={backFromDetail}/>
      </div>
    );
  }
  if (screen === 'exercise-detail') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <ExerciseDetailScreen onBack={backFromDetail}/>
      </div>
    );
  }
  if (screen === 'pr-detail') {
    return (
      <div style={{ height:'100%', display:'flex', flexDirection:'column',
        background: T.surface }}>
        <SafeArea/>
        <PRDetailScreen onBack={backFromDetail}/>
      </div>
    );
  }

  // ── MAIN TABS ───────────────────────────────────────
  const tabContent = (() => {
    if (activeTab === 'home')
      return <HomeScreen
        onStartWorkout={() => startWorkout()}
        onNavigate={navigate}
        onOpenWorkout={openWorkoutDetail}
        onOpenPR={openPRDetail}
        userGoal={user.goal}/>;
    if (activeTab === 'train')
      return <TrainScreen
        onStartWorkout={() => startWorkout()}
        userGoal={user.goal} userLevel={user.level}/>;
    if (activeTab === 'nutrition')
      return <NutritionScreen userGoal={user.goal}/>;
    if (activeTab === 'progress')
      return <ProgressScreen
        unit={user.unit}
        onOpenPR={openPRDetail}
        onOpenExercise={openExerciseDetail}/>;
    if (activeTab === 'settings')
      return <SettingsScreen
        user={user} onUpdate={updateUser}
        themeKey={themeKey} onThemeChange={changeTheme}
        isPro={isPro}/>;
    return null;
  })();

  return (
    <div style={{ height:'100%', display:'flex', flexDirection:'column',
      background: T.surface, position:'relative', overflow:'hidden' }}>
      <SafeArea/>
      {tabContent}
      <BottomNav active={activeTab} onNavigate={navigate}/>
    </div>
  );
}

window.VeltApp = VeltApp;

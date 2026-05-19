// VELT — Home Screen
// Greeting + Today's Plan + Stats + Last 7 Days + Last Session + PRs

const { useState } = React;

function HomeScreen({ onStartWorkout, onNavigate, onOpenWorkout, onOpenPR, userGoal='muscle' }) {
  const now = new Date();
  const hour = now.getHours();
  const greeting =
    hour < 6  ? 'Late night.' :
    hour < 12 ? 'Good morning.' :
    hour < 18 ? 'Good afternoon.' :
                'Good evening.';
  const motivation = hour < 12
    ? 'Strong start. Today is push day.'
    : hour < 18
      ? "Crush it. You're 2 sessions ahead of last week."
      : 'Wind down session — keep the streak alive.';

  // Mock today's plan
  const today = {
    name: 'Push A',
    fullName: 'Push A — Chest & Shoulders',
    exerciseCount: 6,
    duration: '~45 min',
    preview: 'Bench · Incline DB · OHP',
    plusMore: 3,
  };

  // Stats
  const streak = 7;
  const weekVolume = '14,820';
  const monthCount = 18;

  // Last 7 days
  const today_dow = now.getDay(); // 0 = Sunday
  const week = [
    { d:'Mo', done:true  },
    { d:'Tu', done:true  },
    { d:'We', done:false, isPast:true },
    { d:'Th', done:true  },
    { d:'Fr', done:true  },
    { d:'Sa', done:false, isToday:true },
    { d:'Su', done:false, isFuture:true },
  ];
  const doneCount = week.filter(d => d.done).length;

  // Last session
  const lastSession = {
    name: 'Pull A — Back & Biceps',
    date: '2 days ago',
    duration: '52 min',
    sets: 18,
    volume: '12,440 kg',
    preview: 'Deadlift · Pull-up · Row',
  };

  // PRs
  const prs = [
    { exercise: 'Bench Press', weight: '102.5 kg', date: '2d ago' },
    { exercise: 'Squat',       weight: '142.5 kg', date: '5d ago' },
    { exercise: 'OHP',         weight: '72.5 kg',  date: '1w ago' },
    { exercise: 'Deadlift',    weight: '172.5 kg', date: '2w ago' },
  ];

  const goalLabel = userGoal === 'muscle' ? 'Build Muscle'
    : userGoal === 'fat' ? 'Lose Fat'
    : userGoal === 'strength' ? 'Strength'
    : 'Endurance';
  const goalColor = GOAL_COLORS[userGoal] || T.accentIron;

  return (
    <div style={{ flex: 1, overflowY:'auto', background: T.surface }}>

      {/* HEADER */}
      <div style={{ padding: `${T.lg}px ${T.screenH}px ${T.lg}px`,
        display:'flex', alignItems:'flex-start', gap: T.sm }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 30,
            fontWeight: 700, color: T.textPrimary,
            letterSpacing: '-0.03em', lineHeight: 1.05 }}>
            {greeting}
          </div>
          <div style={{ fontFamily: T.fontBody, fontSize: 13,
            color: T.textTertiary, marginTop: 4 }}>
            {motivation}
          </div>
        </div>
        <button onClick={() => onNavigate('settings')} style={{
          background: alpha(goalColor, 0.12),
          border: `1px solid ${alpha(goalColor, 0.3)}`,
          borderRadius: T.rfull,
          padding: '6px 12px 6px 9px',
          display:'flex', alignItems:'center', gap: 5,
          cursor:'pointer', flexShrink: 0,
        }}>
          <Icon.Trend c={goalColor} up size={11}/>
          <span style={{ fontFamily: T.fontBody, fontSize: 11,
            fontWeight: 700, color: goalColor,
            letterSpacing: '0.01em' }}>{goalLabel}</span>
        </button>
      </div>

      <div style={{ padding: `0 ${T.screenH}px`,
        display:'flex', flexDirection:'column',
        gap: T.sectionGap, paddingBottom: T.bottomNavPad }}>

        {/* ═══ TODAY'S PLAN ═══ */}
        <TodayPlanCard plan={today} onStart={onStartWorkout} />

        {/* ═══ STATS ROW ═══ */}
        <div style={{ display:'flex', gap: 8 }}>
          <StatBox
            icon={<Icon.Flame c={streak >= 3 ? T.accentIron : T.textTertiary}/>}
            value={streak}
            label="Day Streak"
            accent={streak >= 3}
          />
          <StatBox
            icon={<Icon.Dumbbell c={T.textSecondary} />}
            value={weekVolume}
            label="kg this week"
          />
          <StatBox
            icon={<Icon.Check c={T.textSecondary} sw={2}/>}
            value={monthCount}
            label="This Month"
          />
        </div>

        {/* ═══ LAST 7 DAYS ═══ */}
        <Last7Days week={week} doneCount={doneCount} />

        {/* ═══ LAST SESSION ═══ */}
        <div>
          <SectionHeader label="LAST SESSION" />
          <LastSessionCard session={lastSession} onPress={onOpenWorkout} />
        </div>

        {/* ═══ PERSONAL RECORDS ═══ */}
        <div>
          <SectionHeader label="PERSONAL RECORDS"
            action="See all →" onAction={() => onNavigate('progress')} />
          <div style={{ display:'flex', gap: 8, overflowX:'auto',
            margin: `0 -${T.screenH}px`, padding: `0 ${T.screenH}px 4px`,
            scrollSnapType:'x mandatory' }}>
            {prs.map((pr, i) => <PRMiniCard key={pr.exercise} pr={pr} onPress={onOpenPR}/>)}
          </div>
        </div>

      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   TODAY'S PLAN CARD — dominant card with amber top edge
──────────────────────────────────────────────────────── */
function TodayPlanCard({ plan, onStart }) {
  return (
    <div style={{
      position:'relative',
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rlg,
      padding: 20, paddingTop: 22,
      overflow:'hidden',
    }}>
      {/* Top amber edge gradient */}
      <div style={{
        position:'absolute', top: 0, left: 0, right: 0, height: 3,
        background: `linear-gradient(90deg, transparent, ${T.accentIron} 25%, ${T.accentIron} 75%, transparent)`,
      }}/>

      {/* Top row: label + duration pill */}
      <div style={{ display:'flex', justifyContent:'space-between',
        alignItems:'center', marginBottom: 10 }}>
        <SectionLabel style={{ color: T.accentIron, fontSize: 10 }}>
          TODAY'S PLAN
        </SectionLabel>
        <Pill bg={T.surfaceHigh} color={T.textSecondary}>
          {plan.exerciseCount} ex · {plan.duration}
        </Pill>
      </div>

      {/* Routine name */}
      <div style={{ fontFamily: T.fontBody, fontSize: 24, fontWeight: 700,
        color: T.textPrimary, letterSpacing: '-0.025em',
        lineHeight: 1.1, marginBottom: 8 }}>
        {plan.fullName}
      </div>

      {/* Exercise preview */}
      <div style={{ fontFamily: T.fontBody, fontSize: 12,
        color: T.textTertiary, marginBottom: 16, lineHeight: 1.5 }}>
        {plan.preview} <span style={{ color: T.textTertiary }}>+{plan.plusMore} more</span>
      </div>

      {/* CTA */}
      <PrimaryButton
        label={`Start ${plan.name}`}
        icon={<Icon.Play c="#FFF" size={10}/>}
        onPress={onStart}
      />

      {/* Empty workout link */}
      <button onClick={onStart} style={{
        width: '100%', marginTop: 12, padding: 4,
        background:'none', border:'none', cursor:'pointer',
        fontFamily: T.fontBody, fontSize: 12, color: T.textTertiary,
        textAlign:'center',
      }}>
        or start an empty workout →
      </button>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   LAST 7 DAYS
──────────────────────────────────────────────────────── */
function Last7Days({ week, doneCount }) {
  return (
    <div>
      <div style={{ display:'flex', justifyContent:'space-between',
        alignItems:'baseline', marginBottom: 10 }}>
        <SectionLabel>LAST 7 DAYS</SectionLabel>
        <span style={{ fontFamily: T.fontBody, fontSize: 11,
          color: T.textSecondary }}>
          <span style={{ color: T.textPrimary, fontWeight: 700 }}>
            {doneCount}
          </span> / 7 sessions
        </span>
      </div>

      <div style={{ display:'flex', gap: 8 }}>
        {week.map((day, i) => {
          let bg = T.surfaceElevated;
          let border = `0.5px solid ${T.divider}`;
          let content = null;

          if (day.done) {
            bg = T.accentIron;
            content = <Icon.Check c="#FFF" sw={2.4}/>;
          } else if (day.isToday) {
            bg = 'transparent';
            border = `1.5px dashed ${T.accentIron}`;
          } else if (day.isFuture) {
            bg = T.surfaceElevated;
            border = `0.5px solid ${T.divider}`;
          }

          return (
            <div key={i} style={{ flex: 1, display:'flex',
              flexDirection:'column', alignItems:'center', gap: 6 }}>
              <div style={{
                width: '100%', aspectRatio: 1,
                background: bg, border,
                borderRadius: T.rsm,
                display:'flex', alignItems:'center', justifyContent:'center',
              }}>
                {content}
              </div>
              <span style={{ fontFamily: T.fontBody, fontSize: 10,
                fontWeight: day.isToday ? 700 : 500,
                color: day.isToday ? T.accentIron : T.textTertiary,
                letterSpacing: '0.04em' }}>{day.d}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   LAST SESSION CARD
──────────────────────────────────────────────────────── */
function LastSessionCard({ session, onPress }) {
  return (
    <Card onPress={onPress} padding={14}>
      <div style={{ display:'flex', alignItems:'center', gap: T.sm }}>
        {/* Icon block */}
        <div style={{
          width: 44, height: 44, borderRadius: T.rsm,
          background: T.surfaceHigh, flexShrink: 0,
          display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <Icon.Dumbbell c={T.accentIron}/>
        </div>

        {/* Info */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: T.fontBody, fontSize: 14, fontWeight: 700,
            color: T.textPrimary, letterSpacing: '-0.01em',
            overflow:'hidden', textOverflow:'ellipsis',
            whiteSpace:'nowrap' }}>{session.name}</div>
          <div style={{ fontFamily: T.fontBody, fontSize: 11,
            color: T.textTertiary, marginTop: 2,
            overflow:'hidden', textOverflow:'ellipsis',
            whiteSpace:'nowrap' }}>{session.preview}</div>
          {/* Mini stats */}
          <div style={{ display:'flex', gap: 10, marginTop: 6 }}>
            <MiniStat icon={<Icon.Timer c={T.textTertiary}/>} value={session.duration}/>
            <MiniStat icon={<Icon.Dumbbell c={T.textTertiary}/>} value={session.volume}/>
            <MiniStat icon={<Icon.Check c={T.textTertiary} sw={1.8}/>} value={session.sets}/>
          </div>
        </div>

        {/* Right: date + chevron */}
        <div style={{ display:'flex', flexDirection:'column',
          alignItems:'flex-end', gap: 8, flexShrink: 0 }}>
          <Pill bg={T.surfaceHigh}>{session.date}</Pill>
          <Icon.Chevron c={T.textTertiary}/>
        </div>
      </div>
    </Card>
  );
}

function MiniStat({ icon, value }) {
  return (
    <div style={{ display:'flex', alignItems:'center', gap: 3 }}>
      {icon}
      <span style={{ fontFamily: T.fontBody, fontSize: 10,
        color: T.textSecondary, fontVariantNumeric:'tabular-nums',
        fontWeight: 500 }}>{value}</span>
    </div>
  );
}

/* ────────────────────────────────────────────────────────
   PR MINI CARD (horizontal scroll)
──────────────────────────────────────────────────────── */
function PRMiniCard({ pr, onPress }) {
  return (
    <div onClick={onPress} style={{
      width: 138, flexShrink: 0,
      background: T.surfaceElevated,
      border: `0.5px solid ${T.divider}`,
      borderRadius: T.rmd,
      padding: 12, scrollSnapAlign: 'start',
      cursor: onPress ? 'pointer' : 'default',
    }}>
      <div style={{ display:'flex', justifyContent:'space-between',
        alignItems:'flex-start', marginBottom: 16 }}>
        <Icon.Trophy c={T.accentIron} size={14}/>
        <span style={{ fontFamily: T.fontBody, fontSize: 10,
          color: T.textTertiary }}>{pr.date}</span>
      </div>
      <div style={{ fontFamily: T.fontBody, fontSize: 22, fontWeight: 700,
        color: T.textPrimary, letterSpacing: '-0.025em',
        fontVariantNumeric:'tabular-nums', lineHeight: 1 }}>{pr.weight}</div>
      <div style={{ fontFamily: T.fontBody, fontSize: 11,
        color: T.textSecondary, marginTop: 4,
        overflow:'hidden', textOverflow:'ellipsis',
        whiteSpace:'nowrap' }}>{pr.exercise}</div>
    </div>
  );
}

window.HomeScreen = HomeScreen;

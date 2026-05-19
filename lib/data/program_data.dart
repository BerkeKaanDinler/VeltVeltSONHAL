import '../models/routine.dart';
import '../models/workout.dart' show WorkoutExercise;
import '../widgets/set_row.dart';

// ── Helper ─────────────────────────────────────────────────
WorkoutExercise _ex(
  String id,
  String name,
  String muscle,
  String equipment,
  List<SetRowData> sets,
) =>
    WorkoutExercise(
        id: id, name: name, muscle: muscle, equipment: equipment, sets: sets);

SetRowData _s(int i, double w, int r,
    {SetType type = SetType.normal,
    ({double weight, int reps})? prev}) =>
    SetRowData(index: i, type: type, weight: w, reps: r, prev: prev);

SetRowData _w(int i, double w, int r) => _s(i, w, r, type: SetType.warmup);

// ── Program model ──────────────────────────────────────────
class VeltProgram {
  const VeltProgram({
    required this.id,
    required this.name,
    required this.tagline,
    required this.difficulty,
    required this.frequency,
    required this.routines,
  });
  final String id;
  final String name;
  final String tagline;
  final String difficulty;
  final String frequency;
  final List<Routine> routines;
}

// ══════════════════════════════════════════════════════════
//  PUSH PULL LEGS — 6 days
// ══════════════════════════════════════════════════════════
final _pplPushA = Routine(
  id: 'ppl-push-a',
  name: 'Push A — Chest / Tri',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('bench', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 60, 10),
      _s(1, 80, 8,  prev: (weight: 80,   reps: 8)),
      _s(2, 80, 8,  prev: (weight: 80,   reps: 8)),
      _s(3, 80, 6,  prev: (weight: 77.5, reps: 7)),
    ]),
    _ex('incline', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 30, 10, prev: (weight: 27.5, reps: 10)),
      _s(1, 30, 10, prev: (weight: 27.5, reps: 10)),
      _s(2, 30, 8,  prev: (weight: 27.5, reps: 8)),
    ]),
    _ex('cable-fly', 'Cable Fly', 'Chest', 'Cable', [
      _s(0, 15, 12), _s(1, 15, 12), _s(2, 15, 10),
    ]),
    _ex('ohp', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 50, 8, prev: (weight: 50, reps: 8)),
      _s(1, 50, 8, prev: (weight: 50, reps: 8)),
      _s(2, 50, 6, prev: (weight: 47.5, reps: 7)),
    ]),
    _ex('lat-raise', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 12, 15), _s(1, 12, 15), _s(2, 12, 12),
    ]),
    _ex('tri-push', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 22.5, 12), _s(1, 22.5, 12), _s(2, 22.5, 10),
    ]),
  ],
);

final _pplPushB = Routine(
  id: 'ppl-push-b',
  name: 'Push B — Shoulders / Tri',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('ohp-b', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 40, 10),
      _s(0, 52.5, 8), _s(1, 52.5, 8), _s(2, 52.5, 6),
    ]),
    _ex('arnold', 'Arnold Press', 'Shoulders', 'Dumbbell', [
      _s(0, 22, 10), _s(1, 22, 10), _s(2, 22, 8),
    ]),
    _ex('cable-lat', 'Cable Lateral Raise', 'Shoulders', 'Cable', [
      _s(0, 8, 15), _s(1, 8, 15), _s(2, 8, 12),
    ]),
    _ex('pec-fly', 'Pec Deck Fly', 'Chest', 'Machine', [
      _s(0, 50, 12), _s(1, 50, 12), _s(2, 50, 10),
    ]),
    _ex('skull', 'Skullcrusher', 'Triceps', 'Barbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 8),
    ]),
    _ex('dips', 'Dips', 'Triceps', 'Bodyweight', [
      _s(0, 0, 12), _s(1, 0, 12), _s(2, 0, 10),
    ]),
  ],
);

final _pplPullA = Routine(
  id: 'ppl-pull-a',
  name: 'Pull A — Back / Bi',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('bb-row', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 60, 10),
      _s(1, 80, 8, prev: (weight: 77.5, reps: 8)),
      _s(2, 80, 8, prev: (weight: 77.5, reps: 8)),
      _s(3, 80, 6, prev: (weight: 77.5, reps: 6)),
    ]),
    _ex('lat-pull', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 60, 10, prev: (weight: 57.5, reps: 10)),
      _s(1, 60, 10, prev: (weight: 57.5, reps: 10)),
      _s(2, 60, 8,  prev: (weight: 57.5, reps: 8)),
    ]),
    _ex('cable-row', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 8),
    ]),
    _ex('face-pull', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 25, 15), _s(1, 25, 15), _s(2, 25, 12),
    ]),
    _ex('hammer', 'Hammer Curl', 'Biceps', 'Dumbbell', [
      _s(0, 18, 10, prev: (weight: 16, reps: 10)),
      _s(1, 18, 10, prev: (weight: 16, reps: 10)),
      _s(2, 18, 8,  prev: (weight: 16, reps: 8)),
    ]),
  ],
);

final _pplPullB = Routine(
  id: 'ppl-pull-b',
  name: 'Pull B — Deadlift / Back',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('deadlift', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 80, 5),
      _s(1, 120, 5, prev: (weight: 117.5, reps: 5)),
      _s(2, 120, 3, prev: (weight: 117.5, reps: 5)),
    ]),
    _ex('pullup', 'Pull-Up', 'Back', 'Bodyweight', [
      _s(0, 0, 8, prev: (weight: 0, reps: 8)),
      _s(1, 0, 8, prev: (weight: 0, reps: 7)),
      _s(2, 0, 6, prev: (weight: 0, reps: 6)),
    ]),
    _ex('db-row', 'DB Row', 'Back', 'Dumbbell', [
      _s(0, 35, 10, prev: (weight: 32.5, reps: 10)),
      _s(1, 35, 10, prev: (weight: 32.5, reps: 10)),
      _s(2, 35, 8,  prev: (weight: 32.5, reps: 8)),
    ]),
    _ex('bb-curl', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 35, 10), _s(1, 35, 10), _s(2, 35, 8),
    ]),
    _ex('rev-fly', 'Reverse Pec Fly', 'Rear Delt', 'Machine', [
      _s(0, 30, 15), _s(1, 30, 15), _s(2, 30, 12),
    ]),
  ],
);

final _pplLegsA = Routine(
  id: 'ppl-legs-a',
  name: 'Legs A — Squat Focus',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('squat', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 8),
      _s(1, 100, 5, prev: (weight: 97.5, reps: 5)),
      _s(2, 100, 5, prev: (weight: 97.5, reps: 5)),
      _s(3, 100, 5, prev: (weight: 97.5, reps: 5)),
    ]),
    _ex('rdl', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 80, 8, prev: (weight: 77.5, reps: 8)),
      _s(1, 80, 8, prev: (weight: 77.5, reps: 8)),
      _s(2, 80, 6, prev: (weight: 77.5, reps: 6)),
    ]),
    _ex('leg-press', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 140, 10), _s(1, 140, 10), _s(2, 140, 8),
    ]),
    _ex('leg-curl', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 45, 12), _s(1, 45, 12), _s(2, 45, 10),
    ]),
    _ex('calf', 'Standing Calf Raise', 'Calves', 'Machine', [
      _s(0, 60, 15), _s(1, 60, 15), _s(2, 60, 12),
    ]),
  ],
);

final _pplLegsB = Routine(
  id: 'ppl-legs-b',
  name: 'Legs B — Hip Focus',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('rdl-b', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _w(0, 60, 8),
      _s(1, 80, 8), _s(2, 80, 8), _s(3, 80, 6),
    ]),
    _ex('hip-thrust', 'Hip Thrust', 'Glutes', 'Barbell', [
      _s(0, 80, 10), _s(1, 80, 10), _s(2, 80, 8),
    ]),
    _ex('leg-press-b', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 130, 12), _s(1, 130, 12), _s(2, 130, 10),
    ]),
    _ex('leg-ext', 'Leg Extension', 'Quads', 'Machine', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 10),
    ]),
    _ex('calf-b', 'Seated Calf Raise', 'Calves', 'Machine', [
      _s(0, 40, 15), _s(1, 40, 15), _s(2, 40, 12),
    ]),
    _ex('lunge', 'Walking Lunge', 'Glutes', 'Dumbbell', [
      _s(0, 20, 12), _s(1, 20, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  STRONGLIFTS 5×5 — 2 routines (alternate A/B)
// ══════════════════════════════════════════════════════════
final _sl5x5A = Routine(
  id: 'sl-a',
  name: 'Workout A — Squat/Bench/Row',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-a', 'Squat', 'Quads', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 80, 5), _s(2, 80, 5), _s(3, 80, 5), _s(4, 80, 5), _s(5, 80, 5),
    ]),
    _ex('bench-a', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 70, 5), _s(2, 70, 5), _s(3, 70, 5), _s(4, 70, 5), _s(5, 70, 5),
    ]),
    _ex('row-a', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 60, 5), _s(2, 60, 5), _s(3, 60, 5), _s(4, 60, 5), _s(5, 60, 5),
    ]),
  ],
);

final _sl5x5B = Routine(
  id: 'sl-b',
  name: 'Workout B — Squat/OHP/DL',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-b', 'Squat', 'Quads', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 80, 5), _s(2, 80, 5), _s(3, 80, 5), _s(4, 80, 5), _s(5, 80, 5),
    ]),
    _ex('ohp-b', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 50, 5), _s(2, 50, 5), _s(3, 50, 5), _s(4, 50, 5), _s(5, 50, 5),
    ]),
    _ex('dl-b', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 100, 5),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  5/3/1 — 4 lift days (wave loading)
// ══════════════════════════════════════════════════════════
// Week 1: 65%×5 / 75%×5 / 85%×5+  — represented as 3 working sets
// Assistance: 5×10 @ ~50% (First Set Last protocol)
final _press531 = Routine(
  id: '531-press',
  name: 'Press Day — OHP',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('ohp-531', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 37.5, 5), _s(2, 42.5, 5), _s(3, 47.5, 5),
    ]),
    _ex('bench-assist', 'Bench Press (FSL)', 'Chest', 'Barbell', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 10),
      _s(3, 55, 10), _s(4, 55, 10),
    ]),
    _ex('tri-531', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 20, 10), _s(1, 20, 10), _s(2, 20, 10),
    ]),
    _ex('face-531', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 20, 15), _s(1, 20, 15), _s(2, 20, 15),
    ]),
  ],
);

final _deadlift531 = Routine(
  id: '531-dead',
  name: 'Deadlift Day',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('dl-531', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 70, 5),
      _s(1, 90, 5), _s(2, 105, 5), _s(3, 117.5, 5),
    ]),
    _ex('row-531', 'Barbell Row (FSL)', 'Back', 'Barbell', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 10),
      _s(3, 55, 10), _s(4, 55, 10),
    ]),
    _ex('lat-531', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 10),
    ]),
    _ex('plank-531', 'Plank', 'Core', 'Bodyweight', [
      _s(0, 0, 60), _s(1, 0, 60), _s(2, 0, 60),
    ]),
  ],
);

final _bench531 = Routine(
  id: '531-bench',
  name: 'Bench Day',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('bench-531', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 65, 5), _s(2, 75, 5), _s(3, 85, 5),
    ]),
    _ex('ohp-assist', 'Overhead Press (FSL)', 'Shoulders', 'Barbell', [
      _s(0, 37.5, 10), _s(1, 37.5, 10), _s(2, 37.5, 10),
      _s(3, 37.5, 10), _s(4, 37.5, 10),
    ]),
    _ex('dips-531', 'Dips', 'Triceps', 'Bodyweight', [
      _s(0, 0, 10), _s(1, 0, 10), _s(2, 0, 10),
    ]),
    _ex('curl-531', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 10),
    ]),
  ],
);

final _squat531 = Routine(
  id: '531-squat',
  name: 'Squat Day',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('sq-531', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 75, 5), _s(2, 87.5, 5), _s(3, 100, 5),
    ]),
    _ex('rdl-531', 'Romanian Deadlift (FSL)', 'Hamstrings', 'Barbell', [
      _s(0, 60, 10), _s(1, 60, 10), _s(2, 60, 10),
      _s(3, 60, 10), _s(4, 60, 10),
    ]),
    _ex('legpress-531', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 120, 10), _s(1, 120, 10), _s(2, 120, 10),
    ]),
    _ex('legcurl-531', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  UPPER / LOWER — 4 days
// ══════════════════════════════════════════════════════════
final _ulUpperA = Routine(
  id: 'ul-upper-a',
  name: 'Upper A — Strength',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('bench-ul', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 82.5, 6), _s(2, 82.5, 6), _s(3, 82.5, 6), _s(4, 82.5, 6),
    ]),
    _ex('row-ul', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 55, 5),
      _s(1, 75, 6), _s(2, 75, 6), _s(3, 75, 6), _s(4, 75, 6),
    ]),
    _ex('ohp-ul', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 52.5, 8), _s(1, 52.5, 8), _s(2, 52.5, 8),
    ]),
    _ex('latpull-ul', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 60, 10), _s(1, 60, 10), _s(2, 60, 10),
    ]),
    _ex('curl-ul', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 30, 12), _s(1, 30, 12), _s(2, 30, 10),
    ]),
    _ex('tri-ul', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 22.5, 12), _s(1, 22.5, 12), _s(2, 22.5, 10),
    ]),
  ],
);

final _ulUpperB = Routine(
  id: 'ul-upper-b',
  name: 'Upper B — Hypertrophy',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('incline-ul', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 30, 8), _s(1, 30, 8), _s(2, 30, 8), _s(3, 30, 8),
    ]),
    _ex('pullup-ul', 'Pull-Up', 'Back', 'Bodyweight', [
      _s(0, 0, 8), _s(1, 0, 8), _s(2, 0, 8), _s(3, 0, 8),
    ]),
    _ex('dbshoulder-ul', 'DB Shoulder Press', 'Shoulders', 'Dumbbell', [
      _s(0, 22, 10), _s(1, 22, 10), _s(2, 22, 10),
    ]),
    _ex('cablerow-ul', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 10),
    ]),
    _ex('hammer-ul', 'Hammer Curl', 'Biceps', 'Dumbbell', [
      _s(0, 18, 12), _s(1, 18, 12), _s(2, 18, 10),
    ]),
    _ex('push-ul', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 22.5, 12), _s(1, 22.5, 12), _s(2, 22.5, 10),
    ]),
  ],
);

final _ulLowerA = Routine(
  id: 'ul-lower-a',
  name: 'Lower A — Squat Focus',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('sq-ul', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 100, 6), _s(2, 100, 6), _s(3, 100, 6), _s(4, 100, 6),
    ]),
    _ex('rdl-ul', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 80, 8), _s(1, 80, 8), _s(2, 80, 8),
    ]),
    _ex('legpress-ul', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 140, 10), _s(1, 140, 10), _s(2, 140, 10),
    ]),
    _ex('legcurl-ul', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 45, 12), _s(1, 45, 12), _s(2, 45, 12),
    ]),
    _ex('calf-ul', 'Calf Raise', 'Calves', 'Machine', [
      _s(0, 60, 15), _s(1, 60, 15), _s(2, 60, 15),
    ]),
  ],
);

final _ulLowerB = Routine(
  id: 'ul-lower-b',
  name: 'Lower B — Deadlift Focus',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('dl-ul', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 80, 5),
      _s(1, 130, 5), _s(2, 130, 5), _s(3, 130, 5),
    ]),
    _ex('hipthrust-ul', 'Hip Thrust', 'Glutes', 'Barbell', [
      _s(0, 80, 10), _s(1, 80, 10), _s(2, 80, 10),
    ]),
    _ex('legpress-ulb', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 130, 12), _s(1, 130, 12), _s(2, 130, 12),
    ]),
    _ex('legext-ul', 'Leg Extension', 'Quads', 'Machine', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 12),
    ]),
    _ex('calf-ulb', 'Seated Calf Raise', 'Calves', 'Machine', [
      _s(0, 40, 15), _s(1, 40, 15), _s(2, 40, 15),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  GZCLP — Tier system, 2 rotating workouts (A/B/C/D)
// ══════════════════════════════════════════════════════════
// T1 = 5×3, T2 = 4×6, T3 = 3×10+
final _gzclpA = Routine(
  id: 'gzclp-a',
  name: 'GZCLP A — Squat / Bench',
  colorValue: 0xFFEC4899,
  exercises: [
    _ex('sq-gz', 'Squat (T1 — 5×3)', 'Quads', 'Barbell', [
      _w(0, 60, 3),
      _s(1, 90, 3), _s(2, 90, 3), _s(3, 90, 3), _s(4, 90, 3), _s(5, 90, 3),
    ]),
    _ex('bench-gz', 'Bench Press (T2 — 4×6)', 'Chest', 'Barbell', [
      _s(0, 70, 6), _s(1, 70, 6), _s(2, 70, 6), _s(3, 70, 6),
    ]),
    _ex('latpull-gz', 'Lat Pulldown (T3 — 3×10+)', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 15),
    ]),
    _ex('ohp-gz', 'Overhead Press (T2 — 3×6)', 'Shoulders', 'Barbell', [
      _s(0, 45, 6), _s(1, 45, 6), _s(2, 45, 6),
    ]),
    _ex('row-gz', 'DB Row (T3 — 3×10+)', 'Back', 'Dumbbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 15),
    ]),
  ],
);

final _gzclpB = Routine(
  id: 'gzclp-b',
  name: 'GZCLP B — OHP / Deadlift',
  colorValue: 0xFFEC4899,
  exercises: [
    _ex('ohp-gz2', 'Overhead Press (T1 — 5×3)', 'Shoulders', 'Barbell', [
      _w(0, 30, 3),
      _s(1, 45, 3), _s(2, 45, 3), _s(3, 45, 3), _s(4, 45, 3), _s(5, 45, 3),
    ]),
    _ex('dl-gz', 'Deadlift (T2 — 4×6)', 'Back', 'Barbell', [
      _s(0, 90, 6), _s(1, 90, 6), _s(2, 90, 6), _s(3, 90, 6),
    ]),
    _ex('row-gz2', 'DB Row (T3 — 3×10+)', 'Back', 'Dumbbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 15),
    ]),
    _ex('bench-gz2', 'Bench Press (T2 — 3×6)', 'Chest', 'Barbell', [
      _s(0, 70, 6), _s(1, 70, 6), _s(2, 70, 6),
    ]),
    _ex('push-gz', 'Tricep Pushdown (T3 — 3×10+)', 'Triceps', 'Cable', [
      _s(0, 20, 10), _s(1, 20, 10), _s(2, 20, 15),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  nSuns 5/3/1 — High volume, 5 days
// ══════════════════════════════════════════════════════════
// Main lift: 9-set amrap ladder.  Assistance: 5×5 secondary lift.
final _nsunsMon = Routine(
  id: 'nsuns-mon',
  name: 'Monday — OHP / Bench',
  colorValue: 0xFFEA580C,
  exercises: [
    _ex('ohp-ns', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 37.5, 5), _s(2, 42.5, 3), _s(3, 47.5, 1),
      _s(4, 47.5, 3), _s(5, 42.5, 3), _s(6, 37.5, 5),
      _s(7, 35,   5), _s(8, 30,   5),
    ]),
    _ex('bench-ns', 'Bench Press', 'Chest', 'Barbell', [
      _s(0, 65, 5), _s(1, 65, 5), _s(2, 65, 5), _s(3, 65, 5), _s(4, 65, 5),
    ]),
    _ex('lat-ns', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 10),
    ]),
  ],
);

final _nsunsTue = Routine(
  id: 'nsuns-tue',
  name: 'Tuesday — Deadlift / Squat',
  colorValue: 0xFFEA580C,
  exercises: [
    _ex('dl-ns', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 80, 5),
      _s(1, 90, 5), _s(2, 105, 3), _s(3, 117.5, 1),
      _s(4, 117.5, 3), _s(5, 105, 3), _s(6, 90, 5),
    ]),
    _ex('sq-ns', 'Squat', 'Quads', 'Barbell', [
      _s(0, 80, 5), _s(1, 80, 5), _s(2, 80, 5), _s(3, 80, 5), _s(4, 80, 5),
    ]),
    _ex('curl-ns', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 10),
    ]),
  ],
);

final _nsunsWed = Routine(
  id: 'nsuns-wed',
  name: 'Wednesday — Bench / OHP',
  colorValue: 0xFFEA580C,
  exercises: [
    _ex('bench-ns2', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 65, 5), _s(2, 75, 3), _s(3, 85, 1),
      _s(4, 85, 3), _s(5, 75, 3), _s(6, 65, 5),
      _s(7, 60, 5), _s(8, 55, 5),
    ]),
    _ex('ohp-ns2', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 37.5, 5), _s(1, 37.5, 5), _s(2, 37.5, 5),
      _s(3, 37.5, 5), _s(4, 37.5, 5),
    ]),
    _ex('row-ns', 'Cable Row', 'Back', 'Cable', [
      _s(0, 50, 10), _s(1, 50, 10), _s(2, 50, 10),
    ]),
  ],
);

final _nsunsThu = Routine(
  id: 'nsuns-thu',
  name: 'Thursday — Squat / Deadlift',
  colorValue: 0xFFEA580C,
  exercises: [
    _ex('sq-ns2', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 75, 5), _s(2, 87.5, 3), _s(3, 100, 1),
      _s(4, 100, 3), _s(5, 87.5, 3), _s(6, 75, 5),
      _s(7, 70, 5),
    ]),
    _ex('rdl-ns', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 70, 5), _s(1, 70, 5), _s(2, 70, 5), _s(3, 70, 5), _s(4, 70, 5),
    ]),
    _ex('legcurl-ns', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 12),
    ]),
  ],
);

final _nsunsFri = Routine(
  id: 'nsuns-fri',
  name: 'Friday — Bench / OHP',
  colorValue: 0xFFEA580C,
  exercises: [
    _ex('bench-ns3', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 65, 5), _s(2, 75, 3), _s(3, 85, 1),
      _s(4, 85, 3), _s(5, 75, 5), _s(6, 65, 5),
      _s(7, 60, 5), _s(8, 55, 5),
    ]),
    _ex('ohp-ns3', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 42.5, 5), _s(1, 42.5, 5), _s(2, 42.5, 5),
    ]),
    _ex('lat-ns2', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 57.5, 10), _s(1, 57.5, 10), _s(2, 57.5, 10),
    ]),
    _ex('face-ns', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 22.5, 15), _s(1, 22.5, 15), _s(2, 22.5, 15),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  BEGINNER FULL BODY — 3 days (ABA/BAB)
// ══════════════════════════════════════════════════════════
final _begFullA = Routine(
  id: 'beg-full-a',
  name: 'Full Body A',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-bfa', 'Squat', 'Quads', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 60, 5), _s(2, 60, 5), _s(3, 60, 5),
    ]),
    _ex('bench-bfa', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 50, 5), _s(2, 50, 5), _s(3, 50, 5),
    ]),
    _ex('row-bfa', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 45, 5), _s(2, 45, 5), _s(3, 45, 5),
    ]),
    _ex('rdl-bfa', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 50, 8), _s(1, 50, 8),
    ]),
    _ex('plank-bfa', 'Plank', 'Core', 'Bodyweight', [
      _s(0, 0, 30), _s(1, 0, 30), _s(2, 0, 30),
    ]),
  ],
);

final _begFullB = Routine(
  id: 'beg-full-b',
  name: 'Full Body B',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-bfb', 'Squat', 'Quads', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 60, 5), _s(2, 60, 5), _s(3, 60, 5),
    ]),
    _ex('ohp-bfb', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 20, 5),
      _s(1, 35, 5), _s(2, 35, 5), _s(3, 35, 5),
    ]),
    _ex('dl-bfb', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 80, 5),
    ]),
    _ex('latpull-bfb', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 40, 8), _s(1, 40, 8), _s(2, 40, 8),
    ]),
    _ex('lateral-bfb', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 8, 12), _s(1, 8, 12), _s(2, 8, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  PPL 3-DAY — once per muscle per week, high volume
// ══════════════════════════════════════════════════════════
final _ppl3Push = Routine(
  id: 'ppl3-push',
  name: 'Push Day',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('bench-p3', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 55, 8),
      _s(1, 75, 8, prev: (weight: 72.5, reps: 8)),
      _s(2, 75, 8, prev: (weight: 72.5, reps: 8)),
      _s(3, 75, 6, prev: (weight: 72.5, reps: 7)),
    ]),
    _ex('incline-p3', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 27.5, 10), _s(1, 27.5, 10), _s(2, 27.5, 8),
    ]),
    _ex('pecdeck-p3', 'Pec Deck Machine', 'Chest', 'Machine', [
      _s(0, 45, 12), _s(1, 45, 12), _s(2, 45, 10),
    ]),
    _ex('ohp-p3', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 45, 8), _s(1, 45, 8), _s(2, 45, 6),
    ]),
    _ex('lat-p3', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 10, 15), _s(1, 10, 15), _s(2, 10, 12),
    ]),
    _ex('tri-p3', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 20, 12), _s(1, 20, 12), _s(2, 20, 10),
    ]),
  ],
);

final _ppl3Pull = Routine(
  id: 'ppl3-pull',
  name: 'Pull Day',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('row-p3', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 50, 8),
      _s(1, 70, 8, prev: (weight: 67.5, reps: 8)),
      _s(2, 70, 8, prev: (weight: 67.5, reps: 8)),
      _s(3, 70, 6, prev: (weight: 67.5, reps: 7)),
    ]),
    _ex('latpull-p3', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 55, 10), _s(1, 55, 10), _s(2, 55, 8),
    ]),
    _ex('cablerow-p3', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 50, 10), _s(1, 50, 10), _s(2, 50, 8),
    ]),
    _ex('facepull-p3', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 22.5, 15), _s(1, 22.5, 15), _s(2, 22.5, 12),
    ]),
    _ex('bbcurl-p3', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 8),
    ]),
    _ex('hammer-p3', 'Hammer Curl', 'Biceps', 'Dumbbell', [
      _s(0, 16, 12), _s(1, 16, 12), _s(2, 16, 10),
    ]),
  ],
);

final _ppl3Legs = Routine(
  id: 'ppl3-legs',
  name: 'Leg Day',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('sq-p3', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 8),
      _s(1, 90, 8, prev: (weight: 87.5, reps: 8)),
      _s(2, 90, 8, prev: (weight: 87.5, reps: 8)),
      _s(3, 90, 6, prev: (weight: 87.5, reps: 7)),
    ]),
    _ex('rdl-p3', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 70, 10), _s(1, 70, 10), _s(2, 70, 8),
    ]),
    _ex('legpress-p3', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 130, 12), _s(1, 130, 12), _s(2, 130, 10),
    ]),
    _ex('legcurl-p3', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 10),
    ]),
    _ex('calf-p3', 'Standing Calf Raise', 'Calves', 'Machine', [
      _s(0, 55, 15), _s(1, 55, 15), _s(2, 55, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  FULL BODY HYPERTROPHY — 3 days A/B/C
// ══════════════════════════════════════════════════════════
final _fbhA = Routine(
  id: 'fbh-a',
  name: 'Full Body A — Squat Focus',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('sq-fbh', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 90, 8), _s(2, 90, 8), _s(3, 90, 8), _s(4, 90, 8),
    ]),
    _ex('bench-fbh', 'Bench Press', 'Chest', 'Barbell', [
      _s(0, 72.5, 8), _s(1, 72.5, 8), _s(2, 72.5, 8), _s(3, 72.5, 8),
    ]),
    _ex('latpull-fbh', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 57.5, 10), _s(1, 57.5, 10), _s(2, 57.5, 10),
    ]),
    _ex('rdl-fbh', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 75, 10), _s(1, 75, 10), _s(2, 75, 10),
    ]),
    _ex('lat-fbh', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 10, 15), _s(1, 10, 15), _s(2, 10, 15),
    ]),
  ],
);

final _fbhB = Routine(
  id: 'fbh-b',
  name: 'Full Body B — Hip Hinge Focus',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('hipthrust-fbh', 'Hip Thrust', 'Glutes', 'Barbell', [
      _s(0, 80, 10), _s(1, 80, 10), _s(2, 80, 10),
    ]),
    _ex('incline-fbh', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 27.5, 10), _s(1, 27.5, 10), _s(2, 27.5, 10),
    ]),
    _ex('cablerow-fbh', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 52.5, 10), _s(1, 52.5, 10), _s(2, 52.5, 10),
    ]),
    _ex('legpress-fbh', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 130, 12), _s(1, 130, 12), _s(2, 130, 12),
    ]),
    _ex('facepull-fbh', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 22.5, 15), _s(1, 22.5, 15), _s(2, 22.5, 15),
    ]),
  ],
);

final _fbhC = Routine(
  id: 'fbh-c',
  name: 'Full Body C — Deadlift Focus',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('dl-fbh', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 70, 5),
      _s(1, 110, 5), _s(2, 110, 5), _s(3, 110, 5),
    ]),
    _ex('ohp-fbh', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 47.5, 8), _s(1, 47.5, 8), _s(2, 47.5, 8),
    ]),
    _ex('row-fbh', 'Barbell Row', 'Back', 'Barbell', [
      _s(0, 70, 8), _s(1, 70, 8), _s(2, 70, 8),
    ]),
    _ex('legext-fbh', 'Leg Extension', 'Quads', 'Machine', [
      _s(0, 37.5, 12), _s(1, 37.5, 12), _s(2, 37.5, 12),
    ]),
    _ex('cablecurl-fbh', 'Cable Curl', 'Biceps', 'Cable', [
      _s(0, 17.5, 12), _s(1, 17.5, 12), _s(2, 17.5, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  STRENGTH 3-DAY — big 5 compound focus
// ══════════════════════════════════════════════════════════
final _str3A = Routine(
  id: 'str3-a',
  name: 'Workout A',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-s3a', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 100, 5), _s(2, 100, 5), _s(3, 100, 5), _s(4, 100, 5),
    ]),
    _ex('bench-s3a', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 80, 5), _s(2, 80, 5), _s(3, 80, 5), _s(4, 80, 5),
    ]),
    _ex('row-s3a', 'Barbell Row', 'Back', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 72.5, 5), _s(2, 72.5, 5), _s(3, 72.5, 5), _s(4, 72.5, 5),
    ]),
    _ex('ohp-s3a', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 30, 5),
      _s(1, 50, 5), _s(2, 50, 5), _s(3, 50, 5),
    ]),
  ],
);

final _str3B = Routine(
  id: 'str3-b',
  name: 'Workout B',
  colorValue: 0xFF22C55E,
  exercises: [
    _ex('sq-s3b', 'Squat', 'Quads', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 100, 5), _s(2, 100, 5), _s(3, 100, 5), _s(4, 100, 5),
    ]),
    _ex('dl-s3b', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 80, 3),
      _s(1, 130, 3), _s(2, 130, 3), _s(3, 130, 3),
    ]),
    _ex('cgbench-s3b', 'Close-Grip Bench Press', 'Triceps', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 65, 5), _s(2, 65, 5), _s(3, 65, 5),
    ]),
    _ex('latpull-s3b', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 60, 8), _s(1, 60, 8), _s(2, 60, 8),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  POWERBUILDING — 4 days, strength + volume blocks
// ══════════════════════════════════════════════════════════
final _pbPush = Routine(
  id: 'pb-push',
  name: 'Push — Bench Focus',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('bench-pb', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 90, 5, prev: (weight: 87.5, reps: 5)),
      _s(2, 90, 5, prev: (weight: 87.5, reps: 5)),
      _s(3, 90, 5, prev: (weight: 87.5, reps: 5)),
      _s(4, 90, 5, prev: (weight: 87.5, reps: 5)),
    ]),
    _ex('bench-pb2', 'Bench Press', 'Chest', 'Barbell', [
      _s(0, 72.5, 8), _s(1, 72.5, 8), _s(2, 72.5, 8),
    ]),
    _ex('incline-pb', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 10),
    ]),
    _ex('ohp-pb', 'Overhead Press', 'Shoulders', 'Barbell', [
      _s(0, 50, 8), _s(1, 50, 8), _s(2, 50, 8),
    ]),
    _ex('tri-pb', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 22.5, 12), _s(1, 22.5, 12), _s(2, 22.5, 12),
    ]),
  ],
);

final _pbSquat = Routine(
  id: 'pb-squat',
  name: 'Squat Day — Legs',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('sq-pb', 'Squat', 'Quads', 'Barbell', [
      _w(0, 70, 5),
      _s(1, 110, 5, prev: (weight: 107.5, reps: 5)),
      _s(2, 110, 5, prev: (weight: 107.5, reps: 5)),
      _s(3, 110, 5, prev: (weight: 107.5, reps: 5)),
      _s(4, 110, 5, prev: (weight: 107.5, reps: 5)),
    ]),
    _ex('legpress-pb', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 150, 10), _s(1, 150, 10), _s(2, 150, 10),
    ]),
    _ex('legext-pb', 'Leg Extension', 'Quads', 'Machine', [
      _s(0, 42.5, 12), _s(1, 42.5, 12), _s(2, 42.5, 12),
    ]),
    _ex('legcurl-pb', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 42.5, 12), _s(1, 42.5, 12), _s(2, 42.5, 12),
    ]),
    _ex('calf-pb', 'Standing Calf Raise', 'Calves', 'Machine', [
      _s(0, 65, 15), _s(1, 65, 15), _s(2, 65, 15),
    ]),
  ],
);

final _pbDead = Routine(
  id: 'pb-dead',
  name: 'Deadlift — Pull',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('dl-pb', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 100, 3),
      _s(1, 150, 3, prev: (weight: 147.5, reps: 3)),
      _s(2, 150, 3, prev: (weight: 147.5, reps: 3)),
      _s(3, 150, 3, prev: (weight: 147.5, reps: 3)),
    ]),
    _ex('row-pb', 'Barbell Row', 'Back', 'Barbell', [
      _s(0, 82.5, 8), _s(1, 82.5, 8), _s(2, 82.5, 8), _s(3, 82.5, 8),
    ]),
    _ex('latpull-pb', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 62.5, 10), _s(1, 62.5, 10), _s(2, 62.5, 10),
    ]),
    _ex('cablerow-pb', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 57.5, 10), _s(1, 57.5, 10), _s(2, 57.5, 10),
    ]),
    _ex('facepull-pb', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 25, 15), _s(1, 25, 15), _s(2, 25, 15),
    ]),
  ],
);

final _pbOhp = Routine(
  id: 'pb-ohp',
  name: 'OHP — Shoulders & Arms',
  colorValue: 0xFF6366F1,
  exercises: [
    _ex('ohp-pb2', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 40, 5),
      _s(1, 60, 5, prev: (weight: 57.5, reps: 5)),
      _s(2, 60, 5, prev: (weight: 57.5, reps: 5)),
      _s(3, 60, 5, prev: (weight: 57.5, reps: 5)),
      _s(4, 60, 5, prev: (weight: 57.5, reps: 5)),
    ]),
    _ex('arnold-pb', 'Arnold Press', 'Shoulders', 'Dumbbell', [
      _s(0, 22, 10), _s(1, 22, 10), _s(2, 22, 10),
    ]),
    _ex('lat-pb', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 12, 15), _s(1, 12, 15), _s(2, 12, 15),
    ]),
    _ex('hammer-pb', 'Hammer Curl', 'Biceps', 'Dumbbell', [
      _s(0, 20, 10), _s(1, 20, 10), _s(2, 20, 10),
    ]),
    _ex('skull-pb', 'Skullcrusher', 'Triceps', 'Barbell', [
      _s(0, 32.5, 10), _s(1, 32.5, 10), _s(2, 32.5, 10),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  CHEST & TRICEPS FOCUS — 3 rotating sessions
// ══════════════════════════════════════════════════════════
final _ctA = Routine(
  id: 'ct-a',
  name: 'Chest & Triceps A',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('bench-cta', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 55, 5),
      _s(1, 82.5, 6), _s(2, 82.5, 6), _s(3, 82.5, 6), _s(4, 82.5, 6),
    ]),
    _ex('inclinebb-cta', 'Incline Bench Press', 'Chest', 'Barbell', [
      _s(0, 65, 8), _s(1, 65, 8), _s(2, 65, 8),
    ]),
    _ex('cablefly-cta', 'Cable Fly', 'Chest', 'Cable', [
      _s(0, 15, 12), _s(1, 15, 12), _s(2, 15, 12),
    ]),
    _ex('cgbench-cta', 'Close-Grip Bench Press', 'Triceps', 'Barbell', [
      _s(0, 60, 8), _s(1, 60, 8), _s(2, 60, 8),
    ]),
    _ex('trip-cta', 'Tricep Pushdown', 'Triceps', 'Cable', [
      _s(0, 22.5, 12), _s(1, 22.5, 12), _s(2, 22.5, 12),
    ]),
  ],
);

final _ctB = Routine(
  id: 'ct-b',
  name: 'Chest & Triceps B',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('inclinedb-ctb', 'Incline DB Press', 'Chest', 'Dumbbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 10), _s(3, 30, 10),
    ]),
    _ex('dbbench-ctb', 'Dumbbell Bench Press', 'Chest', 'Dumbbell', [
      _s(0, 27.5, 10), _s(1, 27.5, 10), _s(2, 27.5, 10),
    ]),
    _ex('pecdeck-ctb', 'Pec Deck Machine', 'Chest', 'Machine', [
      _s(0, 50, 12), _s(1, 50, 12), _s(2, 50, 12),
    ]),
    _ex('skull-ctb', 'Skullcrusher', 'Triceps', 'Barbell', [
      _s(0, 32.5, 10), _s(1, 32.5, 10), _s(2, 32.5, 10),
    ]),
    _ex('ohtext-ctb', 'Overhead Tricep Extension', 'Triceps', 'Cable', [
      _s(0, 17.5, 12), _s(1, 17.5, 12), _s(2, 17.5, 12),
    ]),
  ],
);

final _ctC = Routine(
  id: 'ct-c',
  name: 'Chest & Triceps C',
  colorValue: 0xFFD97706,
  exercises: [
    _ex('bench-ctc', 'Bench Press', 'Chest', 'Barbell', [
      _w(0, 55, 5),
      _s(1, 85, 5), _s(2, 85, 5), _s(3, 85, 5), _s(4, 85, 5), _s(5, 85, 5),
    ]),
    _ex('dips-ctc', 'Dips', 'Chest', 'Bodyweight', [
      _s(0, 0, 12), _s(1, 0, 12), _s(2, 0, 10),
    ]),
    _ex('dbfly-ctc', 'Dumbbell Fly', 'Chest', 'Dumbbell', [
      _s(0, 14, 12), _s(1, 14, 12), _s(2, 14, 12),
    ]),
    _ex('tridips-ctc', 'Tricep Dips', 'Triceps', 'Bodyweight', [
      _s(0, 0, 12), _s(1, 0, 12), _s(2, 0, 10),
    ]),
    _ex('kickback-ctc', 'Tricep Kickback', 'Triceps', 'Dumbbell', [
      _s(0, 10, 15), _s(1, 10, 15), _s(2, 10, 15),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  BACK & BICEPS FOCUS — 3 rotating sessions
// ══════════════════════════════════════════════════════════
final _bbiA = Routine(
  id: 'bbi-a',
  name: 'Back & Biceps A',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('dl-bbi', 'Deadlift', 'Back', 'Barbell', [
      _w(0, 80, 3),
      _s(1, 120, 5), _s(2, 120, 5), _s(3, 120, 5),
    ]),
    _ex('row-bbi', 'Barbell Row', 'Back', 'Barbell', [
      _s(0, 75, 8), _s(1, 75, 8), _s(2, 75, 8), _s(3, 75, 8),
    ]),
    _ex('latpull-bbi', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 60, 10), _s(1, 60, 10), _s(2, 60, 10),
    ]),
    _ex('bbcurl-bbi', 'Barbell Curl', 'Biceps', 'Barbell', [
      _s(0, 35, 10), _s(1, 35, 10), _s(2, 35, 10),
    ]),
    _ex('hammer-bbi', 'Hammer Curl', 'Biceps', 'Dumbbell', [
      _s(0, 18, 10), _s(1, 18, 10), _s(2, 18, 10),
    ]),
  ],
);

final _bbiB = Routine(
  id: 'bbi-b',
  name: 'Back & Biceps B',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('pullup-bbi', 'Pull-Up', 'Back', 'Bodyweight', [
      _s(0, 0, 8), _s(1, 0, 8), _s(2, 0, 8), _s(3, 0, 8),
    ]),
    _ex('cablerow-bbi', 'Seated Cable Row', 'Back', 'Cable', [
      _s(0, 57.5, 10), _s(1, 57.5, 10), _s(2, 57.5, 10),
    ]),
    _ex('dbrow-bbi', 'Dumbbell Row', 'Back', 'Dumbbell', [
      _s(0, 35, 10), _s(1, 35, 10), _s(2, 35, 10),
    ]),
    _ex('dbcurl-bbi', 'Dumbbell Curl', 'Biceps', 'Dumbbell', [
      _s(0, 16, 12), _s(1, 16, 12), _s(2, 16, 12),
    ]),
    _ex('preach-bbi', 'Preacher Curl', 'Biceps', 'Barbell', [
      _s(0, 25, 10), _s(1, 25, 10), _s(2, 25, 10),
    ]),
  ],
);

final _bbiC = Routine(
  id: 'bbi-c',
  name: 'Back & Biceps C',
  colorValue: 0xFF3B82F6,
  exercises: [
    _ex('latpull-bbic', 'Lat Pulldown', 'Back', 'Cable', [
      _s(0, 62.5, 10), _s(1, 62.5, 10), _s(2, 62.5, 10), _s(3, 62.5, 10),
    ]),
    _ex('tbar-bbic', 'T-Bar Row', 'Back', 'Barbell', [
      _s(0, 42.5, 8), _s(1, 42.5, 8), _s(2, 42.5, 8),
    ]),
    _ex('straight-bbic', 'Straight-Arm Pulldown', 'Back', 'Cable', [
      _s(0, 20, 12), _s(1, 20, 12), _s(2, 20, 12),
    ]),
    _ex('ezcurl-bbic', 'EZ-Bar Curl', 'Biceps', 'Barbell', [
      _s(0, 30, 10), _s(1, 30, 10), _s(2, 30, 10),
    ]),
    _ex('cablecurl-bbic', 'Cable Curl', 'Biceps', 'Cable', [
      _s(0, 15, 12), _s(1, 15, 12), _s(2, 15, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  LEG GROWTH FOCUS — 3 rotating sessions
// ══════════════════════════════════════════════════════════
final _lgA = Routine(
  id: 'lg-a',
  name: 'Legs A — Quad Focus',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('sq-lg', 'Squat', 'Quads', 'Barbell', [
      _w(0, 70, 5),
      _s(1, 105, 6, prev: (weight: 102.5, reps: 6)),
      _s(2, 105, 6, prev: (weight: 102.5, reps: 6)),
      _s(3, 105, 6, prev: (weight: 102.5, reps: 6)),
      _s(4, 105, 6, prev: (weight: 102.5, reps: 6)),
    ]),
    _ex('legpress-lg', 'Leg Press', 'Quads', 'Machine', [
      _s(0, 145, 12), _s(1, 145, 12), _s(2, 145, 12),
    ]),
    _ex('legext-lg', 'Leg Extension', 'Quads', 'Machine', [
      _s(0, 42.5, 15), _s(1, 42.5, 15), _s(2, 42.5, 15),
    ]),
    _ex('rdl-lg', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _s(0, 80, 10), _s(1, 80, 10), _s(2, 80, 10),
    ]),
    _ex('legcurl-lg', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 42.5, 12), _s(1, 42.5, 12), _s(2, 42.5, 12),
    ]),
  ],
);

final _lgB = Routine(
  id: 'lg-b',
  name: 'Legs B — Posterior Chain',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('rdl-lgb', 'Romanian Deadlift', 'Hamstrings', 'Barbell', [
      _w(0, 60, 5),
      _s(1, 90, 8), _s(2, 90, 8), _s(3, 90, 8), _s(4, 90, 8),
    ]),
    _ex('hipthrust-lgb', 'Hip Thrust', 'Glutes', 'Barbell', [
      _s(0, 90, 10), _s(1, 90, 10), _s(2, 90, 10),
    ]),
    _ex('legcurl-lgb', 'Leg Curl', 'Hamstrings', 'Machine', [
      _s(0, 45, 12), _s(1, 45, 12), _s(2, 45, 12),
    ]),
    _ex('bulgarian-lgb', 'Bulgarian Split Squat', 'Quads', 'Dumbbell', [
      _s(0, 22, 10), _s(1, 22, 10), _s(2, 22, 10),
    ]),
    _ex('calf-lgb', 'Standing Calf Raise', 'Calves', 'Machine', [
      _s(0, 62.5, 15), _s(1, 62.5, 15), _s(2, 62.5, 15),
    ]),
  ],
);

final _lgC = Routine(
  id: 'lg-c',
  name: 'Legs C — Full Leg Day',
  colorValue: 0xFF10B981,
  exercises: [
    _ex('frontsq-lgc', 'Front Squat', 'Quads', 'Barbell', [
      _w(0, 50, 5),
      _s(1, 75, 6), _s(2, 75, 6), _s(3, 75, 6),
    ]),
    _ex('hacksq-lgc', 'Hack Squat', 'Quads', 'Machine', [
      _s(0, 80, 10), _s(1, 80, 10), _s(2, 80, 10),
    ]),
    _ex('lunge-lgc', 'Walking Lunge', 'Glutes', 'Dumbbell', [
      _s(0, 22, 12), _s(1, 22, 12), _s(2, 22, 12),
    ]),
    _ex('goodmorning-lgc', 'Good Morning', 'Hamstrings', 'Barbell', [
      _s(0, 50, 10), _s(1, 50, 10), _s(2, 50, 10),
    ]),
    _ex('seatedcalf-lgc', 'Seated Calf Raise', 'Calves', 'Machine', [
      _s(0, 42.5, 15), _s(1, 42.5, 15), _s(2, 42.5, 15),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  SHOULDER WIDTH FOCUS — 3 rotating sessions
// ══════════════════════════════════════════════════════════
final _shA = Routine(
  id: 'sh-a',
  name: 'Shoulders A — Pressing + Width',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('ohp-sha', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 35, 5),
      _s(1, 57.5, 6), _s(2, 57.5, 6), _s(3, 57.5, 6), _s(4, 57.5, 6),
    ]),
    _ex('dbohp-sha', 'DB Shoulder Press', 'Shoulders', 'Dumbbell', [
      _s(0, 24, 10), _s(1, 24, 10), _s(2, 24, 10),
    ]),
    _ex('lat-sha', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 12, 15), _s(1, 12, 15), _s(2, 12, 15), _s(3, 12, 15),
    ]),
    _ex('facepull-sha', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 25, 15), _s(1, 25, 15), _s(2, 25, 15),
    ]),
    _ex('shrug-sha', 'Barbell Shrug', 'Traps', 'Barbell', [
      _s(0, 80, 12), _s(1, 80, 12), _s(2, 80, 12),
    ]),
  ],
);

final _shB = Routine(
  id: 'sh-b',
  name: 'Shoulders B — Volume + Isolation',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('arnold-shb', 'Arnold Press', 'Shoulders', 'Dumbbell', [
      _s(0, 22, 10), _s(1, 22, 10), _s(2, 22, 10), _s(3, 22, 10),
    ]),
    _ex('cablelatl-shb', 'Cable Lateral Raise', 'Shoulders', 'Cable', [
      _s(0, 9, 15), _s(1, 9, 15), _s(2, 9, 15),
    ]),
    _ex('frontraise-shb', 'Front Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 10, 12), _s(1, 10, 12), _s(2, 10, 12),
    ]),
    _ex('uprightrow-shb', 'Upright Row', 'Shoulders', 'Barbell', [
      _s(0, 40, 12), _s(1, 40, 12), _s(2, 40, 12),
    ]),
    _ex('revpecdeck-shb', 'Reverse Pec Deck', 'Rear Delt', 'Machine', [
      _s(0, 32.5, 15), _s(1, 32.5, 15), _s(2, 32.5, 15),
    ]),
  ],
);

final _shC = Routine(
  id: 'sh-c',
  name: 'Shoulders C — Overhead Strength',
  colorValue: 0xFF8B5CF6,
  exercises: [
    _ex('ohp-shc', 'Overhead Press', 'Shoulders', 'Barbell', [
      _w(0, 35, 5),
      _s(1, 60, 8), _s(2, 60, 8), _s(3, 60, 8),
    ]),
    _ex('lat-shc', 'Lateral Raise', 'Shoulders', 'Dumbbell', [
      _s(0, 12, 15), _s(1, 12, 15), _s(2, 12, 15), _s(3, 12, 15),
    ]),
    _ex('facepull-shc', 'Face Pull', 'Rear Delt', 'Cable', [
      _s(0, 27.5, 15), _s(1, 27.5, 15), _s(2, 27.5, 15),
    ]),
    _ex('revfly-shc', 'Reverse Fly', 'Rear Delt', 'Dumbbell', [
      _s(0, 10, 15), _s(1, 10, 15), _s(2, 10, 15),
    ]),
    _ex('shrug-shc', 'Barbell Shrug', 'Traps', 'Barbell', [
      _s(0, 80, 12), _s(1, 80, 12), _s(2, 80, 12),
    ]),
  ],
);

// ══════════════════════════════════════════════════════════
//  PROGRAM CATALOGUE
// ══════════════════════════════════════════════════════════
final kPrograms = <VeltProgram>[
  VeltProgram(
    id: 'ppl',
    name: 'Push Pull Legs',
    tagline: 'Classic hypertrophy split, 6×/week',
    difficulty: 'Intermediate',
    frequency: '6×/week',
    routines: [_pplPushA, _pplPushB, _pplPullA, _pplPullB, _pplLegsA, _pplLegsB],
  ),
  VeltProgram(
    id: '5x5',
    name: 'StrongLifts 5×5',
    tagline: 'Compound strength, linear progression',
    difficulty: 'Beginner',
    frequency: '3×/week',
    routines: [_sl5x5A, _sl5x5B],
  ),
  VeltProgram(
    id: '531',
    name: '5/3/1 by Jim Wendler',
    tagline: 'Long-term strength, wave loading',
    difficulty: 'Intermediate',
    frequency: '4×/week',
    routines: [_press531, _deadlift531, _bench531, _squat531],
  ),
  VeltProgram(
    id: 'ul',
    name: 'Upper Lower',
    tagline: '4-day frequency split, balanced',
    difficulty: 'Beginner',
    frequency: '4×/week',
    routines: [_ulUpperA, _ulUpperB, _ulLowerA, _ulLowerB],
  ),
  VeltProgram(
    id: 'gzclp',
    name: 'GZCLP',
    tagline: 'Tier system for volume + strength',
    difficulty: 'Intermediate',
    frequency: '3-4×/week',
    routines: [_gzclpA, _gzclpB],
  ),
  VeltProgram(
    id: 'nsuns',
    name: 'nSuns 5/3/1',
    tagline: 'High volume powerlifting variant',
    difficulty: 'Advanced',
    frequency: '5×/week',
    routines: [_nsunsMon, _nsunsTue, _nsunsWed, _nsunsThu, _nsunsFri],
  ),
  VeltProgram(
    id: 'beg-full',
    name: 'Beginner Full Body',
    tagline: 'The safest way to start lifting',
    difficulty: 'Beginner',
    frequency: '3×/week',
    routines: [_begFullA, _begFullB],
  ),
  VeltProgram(
    id: 'ppl-3d',
    name: 'PPL 3-Day',
    tagline: 'Push Pull Legs — compact 3-day version',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_ppl3Push, _ppl3Pull, _ppl3Legs],
  ),
  VeltProgram(
    id: 'fb-hyper',
    name: 'Full Body Hypertrophy',
    tagline: 'High-frequency full body for muscle growth',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_fbhA, _fbhB, _fbhC],
  ),
  VeltProgram(
    id: 'strength-3d',
    name: 'Strength 3-Day',
    tagline: 'Pure strength, minimum fluff',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_str3A, _str3B],
  ),
  VeltProgram(
    id: 'powerbuilding',
    name: 'Powerbuilding',
    tagline: 'Strength and size — best of both worlds',
    difficulty: 'Intermediate',
    frequency: '4×/week',
    routines: [_pbPush, _pbSquat, _pbDead, _pbOhp],
  ),
  VeltProgram(
    id: 'chest-tri',
    name: 'Chest & Triceps Focus',
    tagline: 'Build a powerful pushing presence',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_ctA, _ctB, _ctC],
  ),
  VeltProgram(
    id: 'back-bi',
    name: 'Back & Biceps Focus',
    tagline: 'Build width, thickness, and arm size',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_bbiA, _bbiB, _bbiC],
  ),
  VeltProgram(
    id: 'leg-growth',
    name: 'Leg Growth Focus',
    tagline: 'Quad, hamstring, and glute development',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_lgA, _lgB, _lgC],
  ),
  VeltProgram(
    id: 'shoulders',
    name: 'Shoulder Width Focus',
    tagline: 'Build the width that defines your physique',
    difficulty: 'Intermediate',
    frequency: '3×/week',
    routines: [_shA, _shB, _shC],
  ),
];

VeltProgram? programById(String id) {
  try {
    return kPrograms.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

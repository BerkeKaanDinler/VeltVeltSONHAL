abstract final class TrainingHelpers {
  static String recommendationText(String goal, String experience) {
    switch (goal) {
      case 'Strength':
        if (experience == 'beginner') {
          return 'Your goal: Strength — Start with StrongLifts 5×5, the fastest way for beginners to get strong';
        }
        if (experience == 'advanced') {
          return 'Your goal: Strength — nSuns 5/3/1 delivers maximum weekly volume for serious strength gains';
        }
        return 'Your goal: Strength — 5/3/1 by Wendler is proven long-term progression that works for years';
      case 'Lose Fat':
        if (experience == 'beginner') {
          return 'Your goal: Lose Fat — StrongLifts 5×5 preserves muscle while you cut. Keep the weights moving';
        }
        return 'Your goal: Lose Fat — Push Pull Legs or Upper/Lower with shorter rest keeps intensity high';
      case 'Endurance':
        return 'Your goal: Endurance — GZCLP with 60s rest builds conditioning alongside strength and size';
      default: // Build Muscle
        if (experience == 'beginner') {
          return 'Your goal: Build Muscle — Upper/Lower Split trains every muscle twice per week, perfect starting point';
        }
        if (experience == 'advanced') {
          return 'Your goal: Build Muscle — Push Pull Legs or GZCLP maximise weekly volume for advanced hypertrophy';
        }
        return 'Your goal: Build Muscle — Push Pull Legs is the most proven hypertrophy program, trains each muscle 2×/week';
    }
  }

  static bool programMatchesGoal(String programGoal, String userGoal) {
    switch (userGoal) {
      case 'Build Muscle':
        return programGoal == 'Build Muscle' || programGoal == 'Strength + Size';
      case 'Strength':
        return programGoal == 'Get Strong' ||
            programGoal == 'Strength + Size' ||
            programGoal == 'Powerlifting';
      case 'Lose Fat':
        return programGoal == 'Build Muscle' || programGoal == 'Strength + Size';
      case 'Endurance':
        return programGoal == 'Strength + Size';
      default:
        return false;
    }
  }
}

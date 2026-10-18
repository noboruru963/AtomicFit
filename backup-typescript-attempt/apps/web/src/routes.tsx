// @atomfit/web/src/routes.tsx
// Central route definitions (traceability to SCR screen IDs).
export const ROUTES = {
  home: '/',
  login: '/login',
  register: '/register',
  quizPrompt: '/quiz/prompt',
  quizQuestion: (index: number) => `/quiz/question/${index}`,
  quizExplainer: '/quiz/explainer',
  quizAdjustedProgram: '/quiz/adjusted-program',
  programs: '/programs',
  activeWorkout: '/workout/active',
  workoutComplete: '/workout/complete',
  history: '/history',
  discover: '/discover',
  profile: '/profile',
  settings: '/settings',
} as const;

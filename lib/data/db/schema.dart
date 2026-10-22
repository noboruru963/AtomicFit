/// The AtomFit relational schema.
///
/// Every table is plain SQLite: user scoped rows, client generated UUIDs,
/// `created_at_utc` / `updated_at_utc` timestamps and an optional
/// `deleted_at_utc` soft delete — so a future Firebase implementation can
/// mirror the same shape without touching the UI.
library;

/// Current schema version. Bump this whenever [migrationSteps] grows.
const int kSchemaVersion = 1;

/// Name of the SQLite file inside the app's database directory.
const String kDatabaseName = 'atomfit.db';

/// The tables, in creation order.
const List<String> kTables = <String>[
  'accounts',
  'exercises',
  'programs',
  'sessions',
  'set_logs',
  'settings',
  'app_state',
];

/// `CREATE TABLE` statements for schema version 1.
const List<String> kCreateStatements = <String>[
  '''
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  email TEXT NOT NULL,
  username TEXT NOT NULL DEFAULT '',
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  gender TEXT NOT NULL DEFAULT 'Prefer not to say',
  dob_day TEXT NOT NULL DEFAULT '',
  dob_month TEXT NOT NULL DEFAULT '',
  dob_year TEXT NOT NULL DEFAULT '',
  weight_kg TEXT NOT NULL DEFAULT '',
  height_cm TEXT NOT NULL DEFAULT '',
  personal_details_complete INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT '',
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE exercises (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL,
  name_en TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  body_part TEXT NOT NULL DEFAULT '',
  body_part_label TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT '',
  exercise_category TEXT NOT NULL DEFAULT '',
  equipment TEXT NOT NULL DEFAULT '',
  difficulty TEXT NOT NULL DEFAULT '',
  primary_muscles TEXT NOT NULL DEFAULT '[]',
  secondary_muscles TEXT NOT NULL DEFAULT '[]',
  goals TEXT NOT NULL DEFAULT '[]',
  tags TEXT NOT NULL DEFAULT '[]',
  instructions TEXT NOT NULL DEFAULT '[]',
  tips TEXT NOT NULL DEFAULT '[]',
  images TEXT NOT NULL DEFAULT '{}',
  is_bodyweight INTEGER NOT NULL DEFAULT 0,
  is_unilateral INTEGER NOT NULL DEFAULT 0,
  met REAL,
  mechanic TEXT NOT NULL DEFAULT '',
  force_type TEXT NOT NULL DEFAULT '',
  variation_group TEXT NOT NULL DEFAULT '',
  default_kg REAL NOT NULL DEFAULT 0,
  default_reps INTEGER NOT NULL DEFAULT 10,
  default_sets INTEGER NOT NULL DEFAULT 3,
  is_custom INTEGER NOT NULL DEFAULT 0,
  search_index TEXT NOT NULL DEFAULT '',
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE programs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL,
  split_group TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT '',
  duration TEXT NOT NULL DEFAULT '',
  frequency TEXT NOT NULL DEFAULT '',
  difficulty TEXT NOT NULL DEFAULT '',
  active INTEGER NOT NULL DEFAULT 0,
  exercises TEXT NOT NULL DEFAULT '[]',
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT 'full',
  date_label TEXT NOT NULL DEFAULT '',
  day_of_month INTEGER NOT NULL DEFAULT 1,
  started_at_utc TEXT NOT NULL DEFAULT '',
  duration_min INTEGER NOT NULL DEFAULT 0,
  reps INTEGER NOT NULL DEFAULT 0,
  volume REAL NOT NULL DEFAULT 0,
  sets_count INTEGER NOT NULL DEFAULT 0,
  methods TEXT NOT NULL DEFAULT '[]',
  parent_id TEXT,
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE set_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  session_id TEXT,
  exercise_name TEXT NOT NULL DEFAULT '',
  set_no INTEGER NOT NULL DEFAULT 1,
  exercise_set_no INTEGER NOT NULL DEFAULT 1,
  weight_kg REAL NOT NULL DEFAULT 0,
  reps INTEGER NOT NULL DEFAULT 0,
  rest_s INTEGER NOT NULL DEFAULT 0,
  input_method TEXT NOT NULL DEFAULT 'manual',
  logged_at_utc TEXT NOT NULL DEFAULT '',
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE settings (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  sensor_auto_detect INTEGER NOT NULL DEFAULT 1,
  voice_logging INTEGER NOT NULL DEFAULT 1,
  haptic_feedback INTEGER NOT NULL DEFAULT 1,
  lockscreen_widget INTEGER NOT NULL DEFAULT 1,
  bell_sound INTEGER NOT NULL DEFAULT 1,
  rest_notifications INTEGER NOT NULL DEFAULT 1,
  is_dark_mode INTEGER NOT NULL DEFAULT 0,
  is_logged_in INTEGER NOT NULL DEFAULT 0,
  current_account_id TEXT,
  is_program_adjusted INTEGER NOT NULL DEFAULT 0,
  adjustment_factor REAL NOT NULL DEFAULT 0.9,
  created_at_utc TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL,
  deleted_at_utc TEXT
)''',
  '''
CREATE TABLE app_state (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at_utc TEXT NOT NULL
)''',
];

/// Indexes created after the tables.
const List<String> kCreateIndexes = <String>[
  'CREATE INDEX IF NOT EXISTS idx_exercises_body_part ON exercises (body_part_label)',
  'CREATE INDEX IF NOT EXISTS idx_exercises_name ON exercises (name)',
  'CREATE INDEX IF NOT EXISTS idx_exercises_custom ON exercises (is_custom)',
  'CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions (user_id)',
  'CREATE INDEX IF NOT EXISTS idx_sessions_parent ON sessions (parent_id)',
  'CREATE INDEX IF NOT EXISTS idx_set_logs_session ON set_logs (session_id)',
  'CREATE INDEX IF NOT EXISTS idx_programs_user ON programs (user_id)',
];

/// Migration steps applied when the stored schema version is older than
/// [kSchemaVersion].
///
/// Step 1 creates every table (see [kCreateStatements]).
const List<List<String>> migrationSteps = <List<String>>[
  kCreateStatements,
];

/// The schema version a freshly created database starts at.
int get initialSchemaVersion => migrationSteps.length;

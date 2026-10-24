/// The voice-log command grammar.
///
/// There is no AI and no network here: the log is matched against a fixed list
/// of instruction strings (see the synonym tables below). Anything the table
/// does not recognise is rejected with a retry hint, so a misheard command can
/// never change the set silently.
///
/// Supported instructions:
/// * `add 10 reps` — adds reps to the current set.
/// * `subtract 5 reps` — removes reps from the current set (floored at 0).
/// * `set reps to 12` — sets the current set to an exact rep count.
/// * `finished set` — saves the set through the single Save-Set path.
library;

/// Highest rep count the prototype accepts (AGENTS F-20: reps are whole 0-999).
const int kVoiceMaxReps = 999;

/// The action a recognised instruction asks for.
enum VoiceAction { addReps, subtractReps, setReps, finishSet }

/// A recognised voice-log instruction.
class VoiceCommand {
  const VoiceCommand(this.action, {this.reps = 0});

  final VoiceAction action;

  /// The rep count carried by [action]; unused by [VoiceAction.finishSet].
  final int reps;

  @override
  String toString() => 'VoiceCommand($action, reps: $reps)';
}

// ---------------------------------------------------------------- vocabulary

/// Verbs that add reps to the current set.
const List<String> kVoiceAddVerbs = <String>[
  'add',
  'adding',
  'append',
  'bump',
  'gain',
  'grow',
  'increase',
  'increment',
  'more',
  'plus',
  'push up',
  'raise',
];

/// Verbs that take reps away from the current set.
const List<String> kVoiceSubtractVerbs = <String>[
  'back off',
  'cut',
  'decrease',
  'decrement',
  'deduct',
  'drop',
  'less',
  'lower',
  'minus',
  'reduce',
  'reduction',
  'remove',
  'substract',
  'subtract',
  'subtraction',
  'take away',
  'take off',
];

/// Verbs that set an exact rep count.
const List<String> kVoiceSetVerbs = <String>[
  'adjust',
  'change',
  'make',
  'set',
  'update',
];

/// Whole phrases that finish (save) the current set.
const List<String> kVoiceFinishPhrases = <String>[
  'all done',
  'close set',
  'complete',
  'complete set',
  'completed',
  'completed set',
  'done',
  'done set',
  'end set',
  'finish',
  'finish set',
  'finished',
  'finished set',
  'next set',
  'set done',
  'set finished',
];

/// The word for repetitions, tolerated in singular and plural.
const String _repsWord = r'(?:reps?|repetitions?)';

// ------------------------------------------------------------------- parsing

/// Lowercases the text and flattens punctuation and extra spaces, so
/// `"Add  10 reps!"` and `"add 10 reps"` are the same instruction.
String normalizeVoiceText(String raw) {
  return raw
      .toLowerCase()
      .replaceAll(RegExp(r'''[.,!?;:"'`\-]'''), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _alternation(List<String> words) => words.map(RegExp.escape).join('|');

final RegExp _addPattern = RegExp(
  '^(?:${_alternation(kVoiceAddVerbs)})\\s+(\\d+)\\s*(?:more\\s+)?$_repsWord\$',
);

final RegExp _subtractPattern = RegExp(
  '^(?:${_alternation(kVoiceSubtractVerbs)})\\s+(\\d+)\\s*'
  '(?:more\\s+)?$_repsWord\$',
);

/// `set reps to 12`, `set the reps to 12`, `set 12 reps`, `change reps to 12`.
final RegExp _setRepsPattern = RegExp(
  '^(?:${_alternation(kVoiceSetVerbs)})(?:\\s+the)?'
  '(?:\\s+(?:$_repsWord|rep\\s+count))?(?:\\s+(?:to|at)|=)?\\s+(\\d+)'
  '(?:\\s*$_repsWord)?\$',
);

/// `reps to 12`, `rep count = 12`.
final RegExp _repsToPattern = RegExp(
  '^(?:$_repsWord|rep\\s+count)\\s*(?:to|=)\\s*(\\d+)\$',
);

VoiceCommand? _withReps(VoiceAction action, RegExpMatch? match) {
  if (match == null) return null;
  final int? value = int.tryParse(match.group(1) ?? '');
  if (value == null) return null;
  return VoiceCommand(action, reps: value);
}

/// Parses one voice-log line. Returns `null` when the instruction is not in
/// the table (the caller shows the retry hint and changes nothing).
VoiceCommand? parseVoiceCommand(String raw) {
  final String text = normalizeVoiceText(raw);
  if (text.isEmpty) return null;

  if (kVoiceFinishPhrases.contains(text)) {
    return const VoiceCommand(VoiceAction.finishSet);
  }

  return _withReps(VoiceAction.setReps, _setRepsPattern.firstMatch(text)) ??
      _withReps(VoiceAction.setReps, _repsToPattern.firstMatch(text)) ??
      _withReps(VoiceAction.addReps, _addPattern.firstMatch(text)) ??
      _withReps(VoiceAction.subtractReps, _subtractPattern.firstMatch(text));
}

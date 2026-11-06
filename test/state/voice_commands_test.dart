import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/state/voice_commands.dart';

/// The voice log is a fixed instruction table, so every accepted phrasing
/// belongs here explicitly (AGENTS F-18: an unparseable line changes nothing).
void main() {
  VoiceCommand? parse(String text) => parseVoiceCommand(text);

  group('add reps', () {
    test('matches the canonical instruction', () {
      final VoiceCommand? command = parse('add 10 reps');
      expect(command?.action, VoiceAction.addReps);
      expect(command?.reps, 10);
    });

    test('accepts synonyms, casing, punctuation and extra spaces', () {
      for (final String text in <String>[
        'ADD 10 REPS',
        '  add   10   reps  ',
        'Add 10 reps!',
        'plus 10 reps',
        'increase 10 repetitions',
        'increment 10 rep',
        'bump 10 reps',
        'raise 10 reps',
        'add 10 more reps',
      ]) {
        expect(
          parse(text)?.action,
          VoiceAction.addReps,
          reason: 'should add reps: "$text"',
        );
        expect(parse(text)?.reps, 10, reason: 'should read 10 from "$text"');
      }
    });
  });

  group('subtract reps', () {
    test('matches the canonical instruction and its misspelling', () {
      for (final String text in <String>[
        'subtract 10 reps',
        'substract 10 reps',
        'Subtract 10 Reps.',
        'minus 10 reps',
        'reduce 10 repetitions',
        'remove 10 reps',
        'decrease 10 reps',
        'drop 10 reps',
        'take away 10 reps',
        'take off 10 reps',
      ]) {
        expect(
          parse(text)?.action,
          VoiceAction.subtractReps,
          reason: 'should remove reps: "$text"',
        );
        expect(parse(text)?.reps, 10, reason: 'should read 10 from "$text"');
      }
    });
  });

  group('set reps', () {
    test('matches every accepted phrasing', () {
      for (final String text in <String>[
        'set reps to 12',
        'set the reps to 12',
        'set rep count to 12',
        'set 12 reps',
        'change reps to 12',
        'update reps to 12',
        'adjust reps to 12',
        'make reps 12',
        'reps to 12',
        'reps = 12',
      ]) {
        expect(
          parse(text)?.action,
          VoiceAction.setReps,
          reason: 'should set reps: "$text"',
        );
        expect(parse(text)?.reps, 12, reason: 'should read 12 from "$text"');
      }
    });

    test('reads the exact count', () {
      expect(parse('set reps to 7')?.reps, 7);
      expect(parse('reps = 0')?.reps, 0);
    });
  });

  group('finished set', () {
    test('matches the phrase and its clear variants', () {
      for (final String text in <String>[
        'finished set',
        'Finished Set!',
        'finish set',
        'complete set',
        'completed set',
        'set done',
        'set finished',
        'end set',
        'next set',
        'done',
        'finished',
        'all done',
      ]) {
        expect(
          parse(text)?.action,
          VoiceAction.finishSet,
          reason: 'should finish the set: "$text"',
        );
      }
    });
  });

  group('unknown instructions', () {
    test('are rejected instead of guessed', () {
      for (final String text in <String>[
        '',
        '   ',
        'hello there',
        'add reps',
        'add 10 kg',
        'add ten reps',
        'set reps to',
        'reps 12',
        'subtract',
      ]) {
        expect(
          parse(text),
          isNull,
          reason: 'must not be understood: "$text"',
        );
      }
    });
  });

  group('normalisation', () {
    test('flattens quotes, hyphens and spacing', () {
      expect(parse('  "Add  10 reps"  ')?.action, VoiceAction.addReps);
      expect(parse('take-away 4 reps')?.reps, 4);
      expect(normalizeVoiceText('  Add   10 REPS!  '), 'add 10 reps');
    });
  });
}

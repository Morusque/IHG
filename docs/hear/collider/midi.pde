
ArrayList<NoteEvent> noteEvents = new ArrayList<NoteEvent>();
ArrayList<TempoEvent> tempoEvents = new ArrayList<TempoEvent>();
Sequence sequence;

void readMidiFile(String path) {
  try {
    sequence = MidiSystem.getSequence(new File(path)); // Load the sequence and store it
    int resolution = sequence.getResolution(); // Ticks per beat

    // Default tempo is 120 BPM (500,000 microseconds per beat)
    int currentMicrosecondsPerBeat = 705882; 
    tempoEvents.add(new TempoEvent(0, currentMicrosecondsPerBeat)); // Add a default tempo event at the start

    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        MidiMessage message = event.getMessage();

        if (message instanceof ShortMessage) {
          ShortMessage sm = (ShortMessage) message;
          int command = sm.getCommand();
          int key = sm.getData1();

          if (command == ShortMessage.NOTE_ON && sm.getData2() > 0) {
            noteEvents.add(new NoteEvent(key, event.getTick(), true));
          } else if (command == ShortMessage.NOTE_OFF || (command == ShortMessage.NOTE_ON && sm.getData2() == 0)) {
            noteEvents.add(new NoteEvent(key, event.getTick(), false));
          }
        } else if (message instanceof MetaMessage) {
          MetaMessage mm = (MetaMessage) message;
          if (mm.getType() == 0x51 && mm.getLength() == 3) { // Tempo change event
            currentMicrosecondsPerBeat = ((mm.getData()[0] & 0xFF) << 16) | ((mm.getData()[1] & 0xFF) << 8) | (mm.getData()[2] & 0xFF);
            tempoEvents.add(new TempoEvent(event.getTick(), currentMicrosecondsPerBeat));
          }
        }
      }
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
}

int[] notesForTime(float timeInMs) {
  HashSet<Integer> activeNotes = new HashSet<>();
  long targetTick = convertTimeToTick(timeInMs);
  long lastTick = 0;
  int microsecondsPerBeat = 500000; // Default 120 BPM
  int resolution = sequence.getResolution(); // Ticks per beat

  for (TempoEvent tempoEvent : tempoEvents) {
    if (tempoEvent.tick > targetTick) {
      break;
    }
    lastTick = tempoEvent.tick;
    microsecondsPerBeat = tempoEvent.microsecondsPerBeat;
  }

  float msElapsed = (lastTick / resolution) * (microsecondsPerBeat / 1000.0f);

  for (NoteEvent noteEvent : noteEvents) {
    if (noteEvent.tick > targetTick) {
      break;
    }
    if (noteEvent.isNoteOn) {
      activeNotes.add(noteEvent.note);
    } else {
      activeNotes.remove(noteEvent.note);
    }
  }

  int[] result = new int[activeNotes.size()];
  int i = 0;
  for (Integer note : activeNotes) {
    result[i++] = note;
  }
  return result;
}

long convertTimeToTick(float timeInMs) {
  long tick = 0;
  long lastTick = 0;
  float msElapsed = 0;
  int resolution = sequence.getResolution(); // Ticks per beat
  int microsecondsPerBeat = 500000; // Default 120 BPM

  for (TempoEvent tempoEvent : tempoEvents) {
    float msPerTick = (microsecondsPerBeat / 1000.0f) / resolution;
    float msUntilNextTempoEvent = (tempoEvent.tick - lastTick) * msPerTick;

    if (msElapsed + msUntilNextTempoEvent > timeInMs) {
      break;
    }

    msElapsed += msUntilNextTempoEvent;
    lastTick = tempoEvent.tick;
    microsecondsPerBeat = tempoEvent.microsecondsPerBeat;
  }

  float msPerTick = (microsecondsPerBeat / 1000.0f) / resolution;
  tick = lastTick + (long)((timeInMs - msElapsed) / msPerTick);
  return tick;
}

class NoteEvent {
  int note;
  long tick;
  boolean isNoteOn;

  NoteEvent(int note, long tick, boolean isNoteOn) {
    this.note = note;
    this.tick = tick;
    this.isNoteOn = isNoteOn;
  }
}

class TempoEvent {
  long tick;
  int microsecondsPerBeat;

  TempoEvent(long tick, int microsecondsPerBeat) {
    this.tick = tick;
    this.microsecondsPerBeat = microsecondsPerBeat;
  }
}

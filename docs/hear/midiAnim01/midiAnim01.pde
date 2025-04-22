
import javax.sound.midi.*;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.AudioInputStream;

ArrayList<Note> notes = new ArrayList<Note>();
Clip audioClip;

ArrayList<PImage> images = new ArrayList<PImage>();

void setup() {
  size(700, 500);
  frameRate(30);
  File dir = new File(dataPath("input"));
  File[] files = dir.listFiles();
  if (files != null) {
    for (File file : files) {
      if (file.isFile()) {
        PImage img = loadImage(file.getAbsolutePath());
        if (img != null) {
          images.add(img);
        }
      }
    }
  }
  processMidiFile(new File(dataPath("files/track01.mid")));
  playAudio(dataPath("files/music.wav"));
}

void draw() {
  // update
  for (Note note : notes) note.update();
  // draw
  background(0xEF, 0xDF, 0xFF);
  for (Note note : notes) {
    imageMode(CENTER);
    image(images.get(note.index%images.size()), note.position.x, note.position.y, note.size, note.size);
  }
}

class Note {
  float time;// in ms
  int note;
  int velocity;
  PVector position = new PVector(0, 0);
  PVector direction = new PVector(0, 0);
  float size = 0;
  int index;
  boolean trigged = false;
  Note(float time, int note, int velocity, int index) {
    this.time = time;
    this.note = note;
    this.velocity = velocity;
    this.index = index;
  }
  void update() {
    if (!trigged) {
      if (millis()>time) {
        size = map(velocity, 0, 128, 10, 250);
        position = new PVector(time/50, map(note, 0, 128, height, 0));
        direction = new PVector(0, 0);
        trigged = true;
      }
    }
    position.add(direction);
    direction.y += 0.2;
    size = max(0, size-2);
  }
}

void processMidiFile(File midiFile) {
  try {
    Sequence sequence = MidiSystem.getSequence(midiFile);
    float ticksPerBeat = sequence.getResolution(); // MIDI ticks per beat
    float defaultTempoMicroseconds = 500000; // Default tempo (120 BPM)
    float tempoMicroseconds = defaultTempoMicroseconds; // Assume default tempo at first

    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        MidiMessage message = event.getMessage();
        if (message instanceof MetaMessage) {
          MetaMessage mm = (MetaMessage) message;
          if (mm.getType() == 0x51) { // Set Tempo message
            byte[] data = mm.getData();
            tempoMicroseconds = ((data[0] & 0xFF) << 16) | ((data[1] & 0xFF) << 8) | (data[2] & 0xFF);
            break; // Assuming first tempo is set for the entire track
          }
        }
      }
    }

    float beatsPerMinute = 60000000.0 / tempoMicroseconds;
    float ticksPerSecond = ticksPerBeat * beatsPerMinute / 60.0;

    int index = 0;
    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        MidiMessage message = event.getMessage();
        if (message instanceof ShortMessage) {
          ShortMessage sm = (ShortMessage) message;
          if (sm.getCommand() == ShortMessage.NOTE_ON) {
            int note = sm.getData1();
            int velocity = sm.getData2();
            if (velocity > 0) {
              float time = event.getTick() * (1000.0/ticksPerSecond);
              notes.add(new Note(time, note, velocity, index++));
            }
          }
        }
      }
    }
    for (Note note : notes) println(note.time+" : "+note.note+" : "+note.velocity);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

void playAudio(String filePath) {
  try {
    AudioInputStream audioInputStream = AudioSystem.getAudioInputStream(new File(filePath));
    audioClip = AudioSystem.getClip();
    audioClip.open(audioInputStream);
    audioClip.start();
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

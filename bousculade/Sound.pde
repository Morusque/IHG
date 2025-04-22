
// MODES
int musicMode = 0;
// 0 = silence;
// 1 = fading layers
// 2 = choice once
// 3 = full
// 4 = single

// TODO
// mettre des maxNumSprites (dans les triggers de musique)
// gérer le delay midi
// le mode fading layers : attention aux transitions pas terribles
// plus d'hysteresis sur les nombre de layers en mode fading layers
// une instruction solo pour le canard
// bruiter le passage pas visible vers visible ?
// une instruction "fin de morceau" tout le monde s'en va sauf un
// séparer bounce et appear et merge sfx ?
// ralentir les moveSpeed pour la partie nappes lente
// décharger les formes anciennes
// surveiller la ram, optimiser si besoin
// limiter le nombre de sprites si pas de musique ?

import beads.*;
import java.util.*;
import javax.sound.midi.*;

AudioContext ac;

SamplePlayer[] players = new SamplePlayer[40];
Panner[] panners = new Panner[40];
Gain[] sfxGains = new Gain[40];
int currentPlayer = 0;
Sample[][] appearSfx = new Sample[9][5];// sets alts
int currentAppearSfxIndex = -1;
Reverb sfxReverb;
float appearSfxRecentDensity = 0;
int notesSinceLastAppearSfxSwitch = 0;

int[] numberOfTrackAlts = new int[]{3, 3, 2, 3};
Sample[] bgmSample = new Sample[4];
SamplePlayer[] bgmPlayer = new SamplePlayer[4];
Gain[] bgmGains = new Gain[4];
boolean[] bgmLayerActive = new boolean[4];

Sample ambSfx;
SamplePlayer ambPlayer;
Gain ambGain;

ArrayList<NoteEvent> allowedNoteEvents = new ArrayList<NoteEvent>();
ArrayList<NoteEvent> melodyNoteEvents = new ArrayList<NoteEvent>();
ArrayList<NoteEvent> instructionsNotesEvents = new ArrayList<NoteEvent>();

float preferredAFR = 0.375;// anim frequency synced on beat

float nextSilenceTimeInMs = 0;

float anticipationMs = 100; // read allowed notes midi files n ms in advance

boolean invertPanner = false;

int melodyMode = 0;
// 0 = up down in scale
// 1 = random in scale
// 2 = stable in scale
// 3 = octaves in scale
// 4 = actual melody

void setupSound() {
  ac = new AudioContext();
  readMidiFile(dataPath("files/sfx/allowedNotes01.mid"), allowedNoteEvents);
  readMidiFile(dataPath("files/sfx/melody01.mid"), melodyNoteEvents);
  readMidiFile(dataPath("files/sfx/instructions01.mid"), instructionsNotesEvents);
  try {
    for (int i=0; i<appearSfx.length; i++) {
      for (int j=0; j<appearSfx[i].length; j++) {
        appearSfx[i][j] = new Sample(dataPath("files/sfx/appear_"+nf(i, 2)+"_"+nf(j, 2)+".wav"));
      }
    }
    sfxReverb = new Reverb(ac);
    sfxReverb.setEarlyReflectionsLevel(0.5);
    sfxReverb.setLateReverbLevel(0.5);
    for (int i=0; i<players.length; i++) {
      if (currentAppearSfxIndex==-1) players[i] = new SamplePlayer(ac, appearSfx[floor(random(appearSfx.length))][i%5]);
      else players[i] = new SamplePlayer(ac, appearSfx[currentAppearSfxIndex][i%5]);
      panners[i] = new Panner(ac);
      sfxGains[i] = new Gain(ac, 2, 1.0);
      sfxReverb.addInput(players[i]);
      panners[i].addInput(players[i]);
      sfxGains[i].addInput(panners[i]);
      ac.out.addInput(panners[i]);
      players[i].pause(true);
      players[i].setKillOnEnd(false);
    }
    ac.out.addInput(sfxReverb);
    bgmSample[0] = new Sample(dataPath("files/sfx/formesBossa01 melo"+nf(1, 2)+".wav"));
    bgmSample[1] = new Sample(dataPath("files/sfx/formesBossa01 harmo"+nf(1, 2)+".wav"));
    bgmSample[2] = new Sample(dataPath("files/sfx/formesBossa01 bass"+nf(1, 2)+".wav"));
    bgmSample[3] = new Sample(dataPath("files/sfx/formesBossa01 drums"+nf(1, 2)+".wav"));
    for (int i=0; i<bgmPlayer.length; i++) {
      bgmPlayer[i] = new SamplePlayer(ac, bgmSample[i]);
      bgmLayerActive[i] = false;
      bgmGains[i] = new Gain(ac, bgmPlayer[i].getOuts(), 0.0);
      bgmGains[i].addInput(bgmPlayer[i]);
      ac.out.addInput(bgmGains[i]);
      bgmPlayer[i].pause(true);
      bgmPlayer[i].setKillOnEnd(false);
    }
    ambSfx = new Sample(dataPath("files/sfx/amb01.wav"));
    ambPlayer = new SamplePlayer(ac, ambSfx);
    ambPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    ambGain = new Gain(ac, 2, 0.01);
    ambGain.addInput(ambPlayer);
    ac.out.addInput(ambGain);
  }
  catch(Exception e) {
    println("Error loading sample: " + e.getMessage());
  }
  ac.start();
}

void triggerBgm() {
  if (tracksRandomizationDone) {
    musicMode = floor(random(5));
    if (random(1)<0.3) musicMode = 2;
    println("trigger bgm mode "+musicMode);
    if (musicMode!=0) {
      bgmStartTime=millis();
    }
    maxNumSprites = -1;
    int chosenLayer = floor(random(4));// only for mode 4
    for (int i=0; i<bgmPlayer.length; i++) {
      bgmPlayer[i].pause(true);
      bgmPlayer[i].setSample(bgmSample[i]);
      if (musicMode==0) {// stay silent
        bgmLayerActive[i] = false;
      }
      if (musicMode==1) {// fading layers
        bgmPlayer[i].pause(false);
        bgmPlayer[i].setPosition(0);
      }
      if (musicMode==2) {// choice once
        bgmLayerActive[i] = random(1.0)<0.3; 
        if (bgmLayerActive[i]) bgmGains[i].setGain(1.0);
        else bgmGains[i].setGain(0.0);
        bgmPlayer[i].pause(false);
        bgmPlayer[i].setPosition(0);
      }
      if (musicMode==3) {// full
        bgmLayerActive[i] = true;
        bgmGains[i].setGain(1.0);
        bgmPlayer[i].pause(false);
        bgmPlayer[i].setPosition(0);
      }
      if (musicMode==4) {// solo
        maxNumSprites = floor(random(1, 10));
        bgmLayerActive[i] = (i==chosenLayer);
        if (bgmLayerActive[i]) bgmGains[i].setGain(1.0);
        else bgmGains[i].setGain(0.0);
        bgmPlayer[i].pause(false);
        bgmPlayer[i].setPosition(0);
      }
    }
    wasC3PlayingLastFrame = false;
    lastC3NoteOnTick = -1;
    wasD3PlayingLastFrame = false;
    lastD3NoteOnTick = -1;
    wasE3PlayingLastFrame = false;
    lastE3NoteOnTick = -1;
    nextSilenceTimeInMs = random(1, 7) * 60 * 1000;// between 1 and 10 minutes of silence
  }
}

boolean wasC3PlayingLastFrame = false;
long lastC3NoteOnTick = -1;
boolean wasD3PlayingLastFrame = false;
long lastD3NoteOnTick = -1;
boolean wasE3PlayingLastFrame = false;
long lastE3NoteOnTick = -1;

int targetNbLayers = 0;

float musicDuration = 320000;// in ms
long bgmStartTime = -(long)musicDuration;

boolean tracksRandomizationDone = true;

void soundUpdate() {

  appearSfxRecentDensity *= 0.9;

  /*
  if (ambPlayer.isPaused()) {
    ambPlayer.pause(false);
    ambPlayer.setPosition(0);
  }
  */

  // restart music
  double timeSinceMusic = millis() - bgmStartTime;
  if (timeSinceMusic > musicDuration) {// superior to music duration
    if (musicMode!=0) thread("randomizeTracks");
    musicMode = 0;
    maxNumSprites = -1;
    double timePastSilence = timeSinceMusic - musicDuration;
    if (timePastSilence > nextSilenceTimeInMs) {
      if (sprites.size()>0) {
        if (useSound) {
          triggerBgm();
        }
      }
    }
  }

  if (bgmStartTime>=0) {
    long currentTick = convertTimeToTick(millis() - bgmStartTime);
    boolean isNewC3NoteStarted = false;
    boolean isNewD3NoteStarted = false;
    boolean isNewE3NoteStarted = false;
    for (NoteEvent event : instructionsNotesEvents) {
      if (event.note == 60) {
        if (event.isNoteOn && event.tick > lastC3NoteOnTick && event.tick <= currentTick) {
          isNewC3NoteStarted = true;
          lastC3NoteOnTick = event.tick;
        }
      }
      if (event.note == 62) {
        if (event.isNoteOn && event.tick > lastD3NoteOnTick && event.tick <= currentTick) {
          isNewD3NoteStarted = true;
          lastD3NoteOnTick = event.tick;
        }
      }
      if (event.note == 64) {
        if (event.isNoteOn && event.tick > lastE3NoteOnTick && event.tick <= currentTick) {
          isNewE3NoteStarted = true;
          lastE3NoteOnTick = event.tick;
        }
      }
    }
    if (isNewC3NoteStarted) {
      structureTrigger();
      if (random(10)<1) {
        currentAppearSfxIndex = (currentAppearSfxIndex+1)%appearSfx.length;
        if (random(1)<0.2f) currentAppearSfxIndex = -1;
        notesSinceLastAppearSfxSwitch = 0;
        println("appear sfx index : "+currentAppearSfxIndex);
      }
      if (random(10)<3) {
        melodyMode = floor(random(5));
        println("melody mode : "+melodyMode);
      }
    }
    if (isNewD3NoteStarted) {
      melodyNotePlayed();
    }
    if (isNewE3NoteStarted) {
      danceMove();
    }

    if (musicMode==0) {// silence
    }
    if (musicMode==1) {// fading layers
      updateLayerVolumesBasedOnPopulation();
      // adjust layers envlopes
      for (int i=0; i<bgmLayerActive.length; i++) {
        if (bgmLayerActive[i]) bgmGains[i].setGain(lerp(bgmGains[i].getGain(), 1.0, 0.2));
        else bgmGains[i].setGain(lerp(bgmGains[i].getGain(), 0.0, 0.01));
      }
    }
    if (musicMode==2) {// choice once
    }
    if (musicMode==3) {// full
    }
    if (musicMode==4) {// solo
    }
  }
  int nbActiveLayers = 0;
  for (int i=0; i<bgmLayerActive.length; i++) if (bgmLayerActive[i]) nbActiveLayers++;
  ambGain.setGain(lerp(ambGain.getGain(), 0.3f/(nbActiveLayers+1) + constrain(sprites.size()*0.3/100,0,0.3), 0.003));
}

void randomizeTracks() {
  tracksRandomizationDone = false;
  try {
    bgmSample[0] = new Sample(dataPath("files/sfx/formesBossa01 melo"+nf(floor(random(numberOfTrackAlts[0])+1), 2)+".wav"));
    bgmSample[1] = new Sample(dataPath("files/sfx/formesBossa01 harmo"+nf(floor(random(numberOfTrackAlts[1])+1), 2)+".wav"));
    bgmSample[2] = new Sample(dataPath("files/sfx/formesBossa01 bass"+nf(floor(random(numberOfTrackAlts[2])+1), 2)+".wav"));
    bgmSample[3] = new Sample(dataPath("files/sfx/formesBossa01 drums"+nf(floor(random(numberOfTrackAlts[3])+1), 2)+".wav"));
  }
  catch(Exception e) {
    println(e);
  }
  tracksRandomizationDone = true;
}

void updateLayerVolumesBasedOnPopulation() {
  int nbFormes = sprites.size();
  if (targetNbLayers == 0) {
    if (nbFormes>0) targetNbLayers++;
  }
  if (targetNbLayers == 1) {
    if (nbFormes<=0) targetNbLayers--;
    if (nbFormes>30) targetNbLayers++;
  }
  if (targetNbLayers == 2) {
    if (nbFormes<20) targetNbLayers--;
    if (nbFormes>40) targetNbLayers++;
  }
  if (targetNbLayers == 3) {
    if (nbFormes<25) targetNbLayers--;
    if (nbFormes>50) targetNbLayers++;
  }
  if (targetNbLayers == 4) {
    if (nbFormes<30) targetNbLayers--;
  }
  int currentNbLayers = 0;
  for (int i=0; i<bgmLayerActive.length; i++) if (bgmLayerActive[i]) currentNbLayers++;
  while (currentNbLayers != targetNbLayers) {
    if (currentNbLayers < targetNbLayers) bgmLayerActive[floor(random(bgmPlayer.length))]=true;
    if (currentNbLayers > targetNbLayers) bgmLayerActive[floor(random(bgmPlayer.length))]=false;
    currentNbLayers = 0;
    for (int i=0; i<bgmLayerActive.length; i++) if (bgmLayerActive[i]) currentNbLayers++;
    println("currentNbLayers "+currentNbLayers);
  }
}

boolean contains(int[] array, int value) {
  for (int i = 0; i < array.length; i++) {
    if (array[i] == value) {
      return true;
    }
  }
  return false;
}

int lastNote = 50;
int notesDirection = 1;

void triggerNote(Sprite sprite) {
  if (notesSinceLastAppearSfxSwitch > 100) {
    currentAppearSfxIndex = (currentAppearSfxIndex+1)%appearSfx.length;
    if (random(1)<0.2f) currentAppearSfxIndex = -1;
    notesSinceLastAppearSfxSwitch = 0;
    nextModeScheduled = true;
    println("appear sfx index (after many notes) : "+currentAppearSfxIndex+" + next mode");
  }
  if (sprite==null) return;
  if (sprite.pos==null || sprite.anim==null) return;
  if (sprite.pos.x+sprite.anim.width/2<10 || sprite.pos.y+sprite.anim.height/2<10 || sprite.pos.x-sprite.anim.width/2>=width-10 || sprite.pos.y-sprite.anim.height/2>=height-10) return;
  boolean visible = true;
  for (Sprite s : sprites) {
    if (s!=sprite) {
      if (spritesOverlap(s, sprite, 5.0)) visible=false;
    }
  }
  if (!visible) return;
  float noteBias = random(0.5, 2);
  if (bgmStartTime!=-1) {
    int[] notesCurrentlyPlayed = notesForTime(millis()-bgmStartTime+anticipationMs, allowedNoteEvents);
    int[] melodyNotesCurrentlyPlayed = notesForTime(millis()-bgmStartTime+anticipationMs, melodyNoteEvents);
    if ((notesCurrentlyPlayed.length>0) || (melodyMode==4 && melodyNotesCurrentlyPlayed.length>0)) {
      int targetNote = lastNote;
      if (melodyMode==0) {
        targetNote+=notesDirection;
        while (!containsWithModulo(notesCurrentlyPlayed, targetNote, 12)) targetNote+=notesDirection;
        if (targetNote<45) notesDirection = 1;
        if (targetNote>85) notesDirection = -1;
      }
      if (melodyMode==1) {
        targetNote = floor(random(40, 90));
        while (!containsWithModulo(notesCurrentlyPlayed, targetNote, 12)) targetNote+=notesDirection;
      }
      if (melodyMode==2) {
        if (random(1)<0.2) targetNote += random(0, random(-12, 12));
        while (!containsWithModulo(notesCurrentlyPlayed, targetNote, 12)) targetNote+=notesDirection;
        if (targetNote<45) notesDirection = 1;
        if (targetNote>75) notesDirection = -1;
      }
      if (melodyMode==3) {
        if (random(1)<0.2) targetNote += floor(random(3)-1)*12;
        if (targetNote<45) {
          notesDirection = 1;
          targetNote+=12;
        }
        if (targetNote>75) {
          notesDirection = -1;
          targetNote-=12;
        }
        while (!containsWithModulo(notesCurrentlyPlayed, targetNote, 12)) targetNote+=notesDirection;
      }
      if (melodyMode==4) {
        targetNote = melodyNotesCurrentlyPlayed[floor(random(melodyNotesCurrentlyPlayed.length))];
      }
      lastNote = targetNote;
      noteBias = midiNoteToPitchMultiplier(60, targetNote);
    }
  }
  if (appearSfxRecentDensity < 10) {
    players[currentPlayer].pause(true);
    if (currentAppearSfxIndex==-1) players[currentPlayer].setSample(appearSfx[floor(random(appearSfx.length))][floor(random(5))]);
    else players[currentPlayer].setSample(appearSfx[currentAppearSfxIndex][floor(random(5))]);
    sfxGains[currentPlayer].setGain(1.0/(appearSfxRecentDensity*2.0+1.0));
    players[currentPlayer].setPosition(0);
    players[currentPlayer].pause(false);
    if (invertPanner) panners[currentPlayer].setPos(map(sprite.pos.x, 0, width, 0.8, -0.8));
    else panners[currentPlayer].setPos(map(sprite.pos.x, 0, width, -0.8, 0.8));
    players[currentPlayer].setPitch(new Static(noteBias));
    players[currentPlayer].reTrigger();
    currentPlayer = (currentPlayer+1)%players.length;
    appearSfxRecentDensity++;
    notesSinceLastAppearSfxSwitch++;
  }
}

boolean containsWithModulo(int[] h, int n, int m) {
  for (int i=0; i<h.length; i++)if (h[i]%m==n%m)return true;
  return false;
}

void readMidiFile(String path, ArrayList<NoteEvent> noteEventsToFill) {
  try {
    Sequence sequence = MidiSystem.getSequence(new File(path)); // Load the sequence and store it
    for (Track track : sequence.getTracks()) {
      for (int i = 0; i < track.size(); i++) {
        MidiEvent event = track.get(i);
        MidiMessage message = event.getMessage();

        if (message instanceof ShortMessage) {
          ShortMessage sm = (ShortMessage) message;
          int command = sm.getCommand();
          int key = sm.getData1();

          if (command == ShortMessage.NOTE_ON && sm.getData2() > 0) {
            noteEventsToFill.add(new NoteEvent(key, event.getTick(), true));
          } else if (command == ShortMessage.NOTE_OFF || (command == ShortMessage.NOTE_ON && sm.getData2() == 0)) {
            noteEventsToFill.add(new NoteEvent(key, event.getTick(), false));
          }
        }
      }
    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

int[] notesForTime(float timeInMs, ArrayList<NoteEvent> noteEventsToCheck) {
  HashSet<Integer> allowedNotes = new HashSet<>();
  long targetTick = convertTimeToTick(timeInMs);
  for (NoteEvent noteEvent : noteEventsToCheck) {
    if (noteEvent.tick > targetTick) break;
    if (noteEvent.isNoteOn) allowedNotes.add(noteEvent.note);
    else allowedNotes.remove(noteEvent.note);
  }
  int[] result = new int[allowedNotes.size()];
  int i = 0;
  for (Integer note : allowedNotes) result[i++] = note;
  return result;
}

long convertTimeToTick(float timeInMs) {
  long tick = 0;
  long lastTick = 0;
  float msElapsed = 0;
  int resolution = 96; // Default to 96
  int microsecondsPerBeat = 666666; // Default 90 BPM
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

float midiNoteToPitchMultiplier(int sampleMidiNote, int targetMidiNote) {
  int semitoneDifference = targetMidiNote - sampleMidiNote;
  return pow(2, semitoneDifference / 12.0);
}

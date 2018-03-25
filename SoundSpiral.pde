import themidibus.*;

PVector[] pts;
PVector[] labelpts;
int[] lit;
int len = 144;
int maxrad = 380;
int rad = int(maxrad / 100);
float spiralGrowth = 12;

MidiBus bus;

color[] colors;

void setup() {
  //size(600, 600);
  fullScreen();
  surface.setResizable(true);
  
  colors = new color[12];
  colors[0] = #f99220; // A
  colors[1] = #f2672b; // D
  colors[2] = #ef402a; // G
  colors[3] = #b0142a; // C
  colors[4] = #b61e86; // F
  colors[5] = #312b7e; // Bb
  colors[6] = #2152a5; // Eb
  colors[7] = #0270bc; // Ab
  colors[8] = #008487; // Db
  colors[9] = #01984c; // Gb
  colors[10] = #8cc53f; // B
  colors[11] = #ffda02; // E
  
  pts = new PVector[len];
  labelpts = new PVector[13];
  generatePoints();
  
  lit = new int[len];
  
  MidiBus.list();
  ArrayList<java.lang.String> ins = new ArrayList<java.lang.String>();
  ins.addAll(java.util.Arrays.asList(MidiBus.availableInputs()));
  if (ins.contains("padKONTROL 1 PORT A")) {
      bus = new MidiBus(this, "padKONTROL 1 PORT A", "padKONTROL 1 CTRL"); // Create a new MidiBus (PApplet, in_device_name, out_device_name)
      println("Listen for:  padKONTROL 1 PORT A");
  } else if (ins.contains("MIDIIN2 (padKONTROL)")) {
      bus = new MidiBus(this, "MIDIIN2 (padKONTROL)", "MIDIOUT2 (padKONTROL)"); // Create a new MidiBus (PApplet, in_device_name, out_device_name)
      println("Listen for:  padKONTROL");
  } else {
      bus = new MidiBus(this, 0, 1);
  }
}

void generatePoints() {
  // generate points
  for (int iX = 0; iX < len; iX++) {
    float f = float(iX) / len * 2 * PI * spiralGrowth;
    float x = f * cos(f) * float(rad);
    float y = f * sin(f) * float(rad);
    pts[iX] = new PVector(x, y);
  }
  for (int iX = 0; iX < 13; iX++) {
    float f = float(iX + len) / len * 2 * PI * spiralGrowth;
    float x = f * cos(f) * float(rad);
    float y = f * sin(f) * float(rad);
    labelpts[iX] = new PVector(x, y);
  }
}

int lastHeight;
void draw() {
  if (lastHeight != height) {
    maxrad = int(float(height) * .5);
    rad = int(maxrad / 100);
    generatePoints();
    lastHeight = height;
  }
  background(0);
  
  translate(width/2, height/2);
  rotate(PI/4);
  for (int iX = 0; iX < len-1; iX++) {
    stroke(colors[11-((iX+1)%12)]);
    fill(colors[11-((iX+1)%12)]);
    line(pts[iX].x, pts[iX].y, pts[iX+1].x, pts[iX+1].y);
    
    if (lit[iX] > 0) {
      PVector midpoint = new PVector((pts[iX].x + pts[iX+1].x)/2, (pts[iX].y + pts[iX+1].y)/2);
    
      ellipse(midpoint.x, midpoint.y, 8, 8);
    }
  }
  fill(#ffffff);
  for (int iX = 0; iX < 12; iX++) {
    PVector midpoint = new PVector((labelpts[iX].x + labelpts[iX+1].x)/2, (labelpts[iX].y + labelpts[iX+1].y)/2);
    text(getLabel(iX), midpoint.x, midpoint.y);
  }
}

String getLabel(int index) {
  switch(index) {
    case 9:
    return "D";
    case 10:
    return "A";
    case 11:
    return "E";
    case 0:
    return "B";
    case 1:
    return "Gb";
    case 2:
    return "Db";
    case 3:
    return "Ab";
    case 4:
    return "Eb";
    case 5:
    return "Bb";
    case 6:
    return "F";
    case 7:
    return "C";
    case 8:
    return "G";
  }
  return "";
}

// 21 -> A0 -> 143
// 33 -> A1 -> 131
// 45 -> A2 -> 119
// 47 -> C2 -> 116
// 57 -> 107
// 69 -> 95
// 81 -> 83
// 93 -> 71
// 105 -> 59

// octave = (pitch - 21) / 12 (round down)
// note = pitch % 12
// 45 % 12 = 9 -> A
// 46 % 12 = 10 -> Bb
// 47 % 12 = 11 -> B
// 48 % 12 = 0 -> C
// 49 % 12 = 1 -> Db
// 50 % 12 = 2 -> D
// 51 % 12 = 3 -> Eb
// 52 % 12 = 4 -> E
// 53 % 12 = 5 -> F
// 54 % 12 = 6 -> Gb
// 55 % 12 = 7 -> G
// 56 % 12 = 8 -> Ab
int getIndex(int octave, int pitch) {
  int note = pitch % 12;
  
  int index = 163;
  switch (note) {
    case 9: // A
    index = 143;
    break;
    case 10: // Bb
    index = 138;
    break;
    case 11: // B
    index = 133;
    break;
    case 0: // C
    index = 140;
    break;
    case 1: // Db
    index = 135;
    break;
    case 2: // D
    index = 142;
    break;
    case 3: // Eb
    index = 137;
    break;
    case 4: // E
    index = 132;
    break;
    case 5: // F
    index = 139;
    break;
    case 6: // Gb
    index = 134;
    break;
    case 7: // G
    index = 141;
    break;
    case 8: // Ab
    index = 136;
    break;
  }
  index -= 1;
  println(index);
  index -= (12 * octave);
  println(index);
  return index;
}

int getOctave(int pitch) {
  return floor((pitch - 21) / 12);
}

void noteOn(int channel, int pitch, int velocity) {
    // Receive a noteOn
    println();
    println("Note On:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    
    int octave = getOctave(pitch);
    println(octave);
    int index = getIndex(octave, pitch);
    lit[index] = velocity;
}

void noteOff(int channel, int pitch, int velocity) {
    // Receive a noteOff+6666666666666666666666666666666666
    println();
    println("Note Off:");
    println("--------");
    println("Channel:"+channel);
    println("Pitch:"+pitch);
    println("Velocity:"+velocity);
    
    int octave = getOctave(pitch);
    int index = getIndex(octave, pitch);
    lit[index] = 0;
}

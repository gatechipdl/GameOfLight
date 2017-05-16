import processing.serial.*;

//station grid variables
int GRID_X = 6;
int GRID_Y = 6;
int STATION_SEGMENT_COUNT = 5;
int[] STATION_ORDER = {
  35, 34, 33, 32, 31, 30, 
  29, 28, 27, 26, 25, 24, 
  23, 22, 21, 20, 19, 18, 
  17, 16, 15, 14, 13, 12, 
  11, 10, 9, 8, 7, 6, 
  5, 4, 3, 2, 1, 0 
};

int[] RAINBOW_ORDER = {
  0, 1, 2, 3, 4, 5, 11, 17, 23, 29, 35, 34, 33, 32, 31, 30, 24, 18, 12, 6, 7, 8, 9,
  10, 16, 22, 28, 27, 26, 25, 19, 13, 14, 15, 21, 20
};

Table STATION_STATES_TABLE;
int[][][][] STATION_SEGMENT_COLOR = new int[GRID_X][GRID_Y][STATION_SEGMENT_COUNT][3];
int[][][] STATION_SEGMENT_STATE = new int[GRID_X][GRID_Y][STATION_SEGMENT_COUNT];

//serial communication
int SEND_DELAY = 10;
int MIN_VAL = 0;
long TIME_CHECK = 0;
int STATION_PORT_INDEX = 2;
int PARTICLE_PORT_INDEX = 1;
Serial STATION_PORT;
Serial PARTICLE_PORT;
int SERIAL_BAUD = 115200;
int STATION_COUNT = 36;
int[] STATION_SEGMENT_CHANGE = new int[STATION_COUNT];
int UPDATE_ANIMATION = 2;
int STATION_LED_COUNT = 45;
int STATION_LED_SEGMENT_COUNT = 9;
int COLOR_BYTE_COUNT = 3;
int STATION_COLOR_COUNT = 180;
int STATION_BYTE_COUNT = 540; //3 bytes of color, 5 segments, 36 stations = 540
byte[] packetBytes = new byte[STATION_BYTE_COUNT];
byte[] packetBytesDiff = new byte[STATION_BYTE_COUNT];

byte[] diff64 = {
  (byte)0x65, (byte)0x14, (byte)0xe7, (byte)0xdf, (byte)0x4c, (byte)0xe0, (byte)0x6b, (byte)0xb4, 
  (byte)0x9f, (byte)0xe4, (byte)0x06, (byte)0x4d, (byte)0x2c, (byte)0x85, (byte)0x32, (byte)0xfe, 
  (byte)0xc6, (byte)0x38, (byte)0x4f, (byte)0x19, (byte)0xa7, (byte)0x78, (byte)0x29, (byte)0x3f, 
  (byte)0xf5, (byte)0x5b, (byte)0x6c, (byte)0x03, (byte)0x6a, (byte)0x8b, (byte)0x8b, (byte)0xf0, 
  (byte)0x96, (byte)0xa8, (byte)0x3d, (byte)0xad, (byte)0x3b, (byte)0x8f, (byte)0xbc, (byte)0xc0, 
  (byte)0x58, (byte)0x51, (byte)0xf7, (byte)0x66, (byte)0x26, (byte)0xbb, (byte)0x5a, (byte)0xb5, 
  (byte)0x16, (byte)0x20, (byte)0x14, (byte)0x10, (byte)0x69, (byte)0x72, (byte)0x75, (byte)0xc3, 
  (byte)0x31, (byte)0xcc, (byte)0x3b, (byte)0x01, (byte)0xb7, (byte)0x2b, (byte)0xf4, (byte)0x71
};

//GUI
int gui_X = 50;
int gui_Y = 50;
int gui_W = 80;
int gui_H = 20;
int gui_gap = 40;
boolean animate = false;

void initGame() {
  printArray(Serial.list());
  String portNameStation = Serial.list()[STATION_PORT_INDEX];
  String portNameParticle = Serial.list()[PARTICLE_PORT_INDEX];
  STATION_PORT = new Serial(this, portNameStation, SERIAL_BAUD);
  PARTICLE_PORT = new Serial(this, portNameParticle, 9600);
  for (int s=0; s<STATION_COUNT; s++) {
    STATION_SEGMENT_CHANGE[s] = STATION_SEGMENT_COUNT*UPDATE_ANIMATION;
    for (int i=0; i<STATION_SEGMENT_COUNT; i++) {
      int colorIndex = s*STATION_SEGMENT_COUNT+i;
      packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(0); //RED
      packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(0); //GREEN
      packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(0); //BLUE
      setStationColor(s, i, 0, 0, 0);
    }
  }
  STATION_STATES_TABLE = loadTable("station_states.csv");
  for (int i=0; i<STATION_ORDER.length; i++) {
    for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
      setStationState(STATION_ORDER[i], j, STATION_STATES_TABLE.getInt(STATION_ORDER[i], j));
    }
  }
}

void setGridState(int x, int y, int z, int s) {
  STATION_SEGMENT_STATE[x][y][z] = s;
  int stationIndex = y*GRID_X+x;
  STATION_STATES_TABLE.setInt(STATION_ORDER[stationIndex], z, s);
  STATION_SEGMENT_CHANGE[STATION_ORDER[stationIndex]] = STATION_SEGMENT_COUNT*UPDATE_ANIMATION;
  writeTable();
}

void setGridColor(int x, int y, int z, int r, int g, int b) {
  STATION_SEGMENT_COLOR[x][y][z][0] = r;
  STATION_SEGMENT_COLOR[x][y][z][1] = g;
  STATION_SEGMENT_COLOR[x][y][z][2] = b;
}

void setStationState(int i, int j, int s) {
  if (i>=0 && i<STATION_COUNT) {
    int stationIndex = 0;
    for (int k=0; k<STATION_ORDER.length; k++) {
      if (STATION_ORDER[k]==i) {
        stationIndex = k;
        break;
      }
    }
    int rowIndex = (stationIndex%GRID_X);
    int colIndex = (stationIndex/GRID_X);
    if (rowIndex < GRID_X && colIndex < GRID_Y) {
      STATION_SEGMENT_STATE[rowIndex][colIndex][j] = s;
    }
    STATION_SEGMENT_CHANGE[i] = STATION_SEGMENT_COUNT*UPDATE_ANIMATION;
    STATION_STATES_TABLE.setInt(i, j, s);
    writeTable();
  }
}

void setStationColor(int i, int j, int r, int g, int b) {
  if (i>=0 && i<STATION_COUNT) {
    int stationIndex = 0;
    for (int k=0; k<STATION_ORDER.length; k++) {
      if (STATION_ORDER[k]==i) {
        stationIndex = k;
        break;
      }
    }
    int rowIndex = (stationIndex%GRID_X);
    int colIndex = (stationIndex/GRID_X);
    if (rowIndex < GRID_X && colIndex < GRID_Y) {
      STATION_SEGMENT_COLOR[rowIndex][colIndex][j][0] = r;
      STATION_SEGMENT_COLOR[rowIndex][colIndex][j][1] = g;
      STATION_SEGMENT_COLOR[rowIndex][colIndex][j][2] = b;
    }
  }
}

void writeTable() {
  try {
    saveTable(STATION_STATES_TABLE, "data/station_states.csv");
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

void updatePackets() {
  for (int i=0; i<STATION_ORDER.length; i++) {
    int rowIndex = (i%GRID_X);
    int colIndex = (i/GRID_X);
    int s = STATION_ORDER[i];
    if (STATION_SEGMENT_CHANGE[s] >= 0) {
      for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
        int colorIndex = s*STATION_SEGMENT_COUNT+j;
        if (j < STATION_SEGMENT_CHANGE[s]/UPDATE_ANIMATION) {
          packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(255); //RED
          packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(255); //GREEN
          packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(255); //BLUE
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][0] = 255;
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][1] = 255;
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][2] = 255;
        } else {
          packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(MIN_VAL); //RED
          packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(MIN_VAL); //GREEN
          packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(MIN_VAL); //BLUE
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][0] = MIN_VAL;
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][1] = MIN_VAL;
          STATION_SEGMENT_COLOR[rowIndex][colIndex][j][2] = MIN_VAL;
        }
      }
      STATION_SEGMENT_CHANGE[s] = STATION_SEGMENT_CHANGE[s] - 1;
    } else {
      for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
        int colorIndex = s*STATION_SEGMENT_COUNT+j;
        packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][0]); //RED
        packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][1]); //GREEN
        packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][2]); //BLUE
        //packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(0); //GREEN
        //packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(0); //BLUE

        //float timeFactor = sin(float(millis())*TWO_PI/10000);
        //int mil = abs(int(timeFactor*255));

        //packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(mil);
        //packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(mil);
        //packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(mil);
      }
    }
  }
}

void readParticleSerial() {
  String val = "";
  if (PARTICLE_PORT.available() > 0) {
    val = PARTICLE_PORT.readStringUntil('\n');
  }
  if (val != null) {
    val = trim(val);
    String[] switchVar = split(val, ':');
    if (switchVar.length==2) {
      println("PARTICLE SEND: ", val);
      int caseVar = parseInt(switchVar[0]);
      switch(caseVar) {
      case 1:
        String[] readings = split(switchVar[1], ',');
        if (readings.length == 1+STATION_SEGMENT_COUNT) {
          int stationID = parseInt(readings[0]);
          for (int i=1; i<1+STATION_SEGMENT_COUNT; i++) {
            int state = parseInt(readings[i]);
            if (state >= 0 && state <= 3) {
              setStationState(stationID, STATION_SEGMENT_COUNT-(i-1)-1, state);
            }
          }
        }
        break;
      case 2:
        int modeState = parseInt(switchVar[1]);
        switch (modeState) {
        case 0:
          animate = !animate;
          break;
        case 1:
          refreshStates();
          break;
        case 2:
          rainbow = !rainbow;
          break;
        }
        break;
      }
    }
  }
}

void sendPackets() {
  for (int i=0; i<STATION_BYTE_COUNT; i++) {
    packetBytesDiff[i] = (byte)((byte)packetBytes[i] + (byte)diff64[i%64]);
  }
  STATION_PORT.write(packetBytesDiff);
  //println("packet sent", millis());
}

void clearPort() {
  STATION_PORT.clear();
  //println("packet sent", millis());
}

void drawGrid(int x, int y, int w, int h, int gap) {
  pushMatrix();
  translate(x, y);
  for (int i=0; i<GRID_X; i++) {
    for (int j=0; j<GRID_Y; j++) {
      int xPos = i*(w+gap);
      int yPos = j*(h*STATION_SEGMENT_COUNT+gap);
      for (int k=0; k<STATION_SEGMENT_COUNT; k++) {
        int w2 = w*STATION_SEGMENT_STATE[i][j][k]/3*19/20 + w/20;
        int xPos2 = xPos + (w-w2)/2;
        int yPos2 = yPos + (STATION_SEGMENT_COUNT-k-1)*h;
        noFill();
        stroke(255, 40);
        rect(xPos, yPos2, w, h);
        fill(STATION_SEGMENT_COLOR[i][j][k][0], STATION_SEGMENT_COLOR[i][j][k][1], STATION_SEGMENT_COLOR[i][j][k][2]);
        stroke(150);
        rect(xPos2, yPos2, w2, h);
      }
    }
  }
  popMatrix();
}

void randomize() {
  for (int i=0; i<GRID_X; i++) {
    for (int j=0; j<GRID_Y; j++) {
      for (int k=0; k<STATION_SEGMENT_COUNT; k++) {
        setGridState(i, j, k, floor(random(1, 4)));
      }
    }
  }
}

void clearState() {
  for (int s=0; s<STATION_COUNT; s++) {
    for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
      setStationState(s, j, 0);
    }
  }
}


void setup() {
  fullScreen();
  textSize(12);
  initGame();
  initObjects();
}

void draw() {
  background(0);
  readParticleSerial();
  drawGrid(gui_X, gui_Y, gui_W, gui_H, gui_gap);

  if (millis()-TIME_CHECK > SEND_DELAY) {
    if (rainbow) {
      //updateHuesAndBytes();
      doTheWave();
    } else {
      if (animate) {
        drawSim();
      }
    }
    TIME_CHECK = millis();
    updatePackets();
    sendPackets();
  } else {
    clearPort();
  }

  fill(255);
  text("[ R ] toggle rainbow", width-200, gui_Y);
  text("[ C ] clear all", width-200, gui_Y+20);
  if (animate) {
    fill(0, 255, 0);
  } else {
    fill(255, 0, 0);
  }
  text("[ S ] start / pause animation", width-200, gui_Y+40);
  fill(255);
  text("[ Q ] refresh animation", width-200, gui_Y+60);
}

void keyPressed() {
  switch(keyCode) {
  case 82: //r
    //randomize();
    //refreshStates();
    //writeTable();
    rainbow = !rainbow;
    break;
  case 67: //c
    clearState();
    refreshStates();
    writeTable();
    break;
  case 83: //s
    animate = !animate;
    break;
  case 81: //q
    refreshStates();
    break;
  }
}

void mousePressed() {
  for (int i=0; i<GRID_X; i++) {
    for (int j=0; j<GRID_Y; j++) {
      int xPos = i*(gui_W+gui_gap)+gui_X;
      int yPos = j*(gui_H*STATION_SEGMENT_COUNT+gui_gap)+gui_Y;
      for (int k=0; k<STATION_SEGMENT_COUNT; k++) {
        int yPos2 = yPos + (STATION_SEGMENT_COUNT-k-1)*gui_H;
        if (mouseX > xPos && mouseX < xPos+gui_W && mouseY > yPos2 && mouseY < yPos2+gui_H) {
          STATION_SEGMENT_STATE[i][j][k] = (STATION_SEGMENT_STATE[i][j][k]+1)%4;
          setGridState(i, j, k, STATION_SEGMENT_STATE[i][j][k]);
        }
      }
    }
  }
  writeTable();
}




/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////// GAME ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////




PVector grid = new PVector(GRID_X, GRID_Y, STATION_SEGMENT_COUNT);
Resource[][][] resource = new Resource[int(grid.x)][int(grid.y)][int(grid.z)];
int[][][][] state = new int[int(grid.x)][int(grid.y)][int(grid.z)][3];
int[][][][] oldState = new int[int(grid.x)][int(grid.y)][int(grid.z)][3];

int smallTransition = 7;
int mediumTransition = 7;
int largeTransition = 7;
int counterBW = 0;
int counter = 0;
Rule[] ruleTable1 = { //args: index, state to change if dead, state to change if alive
  new Rule(0, 0, 0), 
  new Rule(1, 0, 0), 
  new Rule(2, 0, 0), 
  new Rule(3, 0, 0), 
  new Rule(4, 0, 0), 
  new Rule(5, 0, 0), 
  new Rule(6, 0, 0), 
  new Rule(7, 0, 0), 
  new Rule(8, 1, 1), 
  new Rule(9, 1, 1), 
  new Rule(10, 1, 1), 
  new Rule(11, 0, 1), 
  new Rule(12, 0, 1), 
  new Rule(13, 0, 0), 
  new Rule(14, 0, 0), 
  new Rule(15, 0, 0), 
  new Rule(16, 0, 0), 
  new Rule(17, 0, 0), 
  new Rule(18, 0, 0), 
  new Rule(19, 0, 0), 
  new Rule(20, 0, 0), 
  new Rule(21, 0, 0), 
  new Rule(22, 0, 0), 
  new Rule(23, 0, 0), 
  new Rule(24, 0, 0), 
  new Rule(25, 0, 0), 
  new Rule(26, 0, 0)
};

Rule[] ruleTable2 = { //args: index, state to change if dead, state to change if alive
  new Rule(0, 0, 0), 
  new Rule(1, 0, 0), 
  new Rule(2, 0, 0), 
  new Rule(3, 0, 0), 
  new Rule(4, 0, 0), 
  new Rule(5, 0, 0), 
  new Rule(6, 0, 0), 
  new Rule(7, 0, 0), 
  new Rule(8, 1, 1), 
  new Rule(9, 1, 1), 
  new Rule(10, 1, 1), 
  new Rule(11, 0, 1), 
  new Rule(12, 0, 1), 
  new Rule(13, 0, 0), 
  new Rule(14, 0, 0), 
  new Rule(15, 0, 0), 
  new Rule(16, 0, 0), 
  new Rule(17, 0, 0), 
  new Rule(18, 0, 0), 
  new Rule(19, 0, 0), 
  new Rule(20, 0, 0), 
  new Rule(21, 0, 0), 
  new Rule(22, 0, 0), 
  new Rule(23, 0, 0), 
  new Rule(24, 0, 0), 
  new Rule(25, 0, 0), 
  new Rule(26, 0, 0)
};

Rule[] ruleTable3 = { //args: index, state to change if dead, state to change if alive
  new Rule(0, 0, 0), 
  new Rule(1, 0, 0), 
  new Rule(2, 0, 0), 
  new Rule(3, 1, 1), 
  new Rule(4, 1, 1), 
  new Rule(5, 1, 1), 
  new Rule(6, 1, 1), 
  new Rule(7, 0, 1), 
  new Rule(8, 0, 1), 
  new Rule(9, 0, 1), 
  new Rule(10, 0, 0), 
  new Rule(11, 0, 0), 
  new Rule(12, 0, 0), 
  new Rule(13, 0, 0), 
  new Rule(14, 0, 0), 
  new Rule(15, 0, 0), 
  new Rule(16, 0, 0), 
  new Rule(17, 0, 0), 
  new Rule(18, 0, 0), 
  new Rule(19, 0, 0), 
  new Rule(20, 0, 0), 
  new Rule(21, 0, 0), 
  new Rule(22, 0, 0), 
  new Rule(23, 0, 0), 
  new Rule(24, 0, 0), 
  new Rule(25, 0, 0), 
  new Rule(26, 0, 0)
};

int timeStamp = 0;
int oldTimeStamp = 0;

boolean rainbow = false;

void initObjects() {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        resource[i][j][k] = new Resource(i, j, k);
      }
    }
  }
}

void refreshStates() {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        switch (STATION_SEGMENT_STATE[i][j][k]) {
        case 0:
          state[i][j][k][0] = 0;
          state[i][j][k][1] = 0;
          state[i][j][k][2] = 0;
          setGridColor(i, j, k, 0, 0, 0);
          break;
        case 1:
          state[i][j][k][0] = 1;
          state[i][j][k][1] = 0;
          state[i][j][k][2] = 0;
          setGridColor(i, j, k, 255, 0, 0);
          break;
        case 2:
          state[i][j][k][0] = 0;
          state[i][j][k][1] = 1;
          state[i][j][k][2] = 0;
          setGridColor(i, j, k, 0, 0, 255);
          break;
        case 3:
          state[i][j][k][0] = 0;
          state[i][j][k][1] = 0;
          state[i][j][k][2] = 1;
          setGridColor(i, j, k, 0, 255, 0);
          break;
        }
      }
    }
  }
  counter = 0;
}

void updateOldState(int m) {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        oldState[i][j][k][m] = state[i][j][k][m];
      }
    }
  }
}

void calRule(int m) {
  int[][][] tempState = new int[int(grid.x)][int(grid.y)][int(grid.z)];
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        int n = 0;
        for (int x=-1; x<=1; x++) {
          for (int y=-1; y<=1; y++) {
            for (int z=-1; z<=1; z++) {
              if (x+y+z != 0) {
                int iX = int((grid.x+i+x)%grid.x);
                int jY = int((grid.y+j+y)%grid.y);
                int kZ = int((grid.z+k+z)%grid.z);
                n = n + state[iX][jY][kZ][m];
              }
            }
          }
        }
        switch (m) {
        case 0:
          tempState[i][j][k] = state[i][j][k][m]==0 ? ruleTable1[n].a : ruleTable1[n].b;
          break;
        case 1:
          tempState[i][j][k] = state[i][j][k][m]==0 ? ruleTable2[n].a : ruleTable2[n].b;
          break;
        case 2:
          tempState[i][j][k] = state[i][j][k][m]==0 ? ruleTable3[n].a : ruleTable3[n].b;
          break;
        }
        //tempState[i][j][k] = 1;
      }
    }
  }
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        state[i][j][k][m] = tempState[i][j][k];
      }
    }
  }
}

float returnChannel(int oldVal, int newVal, int counter, int interval) {
  float ratio = float(counter)/float(interval);
  float val = map(ratio, 0, 1, float(oldVal), float(newVal));
  //if (oldVal != newVal) {
  //  println(oldVal, newVal, ratio, val);
  //}
  return val;
}

void drawSim() {
  if (animate) {
    if (counter % smallTransition == 0) {
      updateOldState(0);
      calRule(0);
    }
    if (counter % mediumTransition == 0) {
      updateOldState(1);
      calRule(1);
    }
    if (counter % largeTransition == 0) {
      updateOldState(2);
      calRule(2);
    }
  }

  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        int red = int(returnChannel(oldState[i][j][k][0], state[i][j][k][0], counter%smallTransition, smallTransition)*255);
        int blue = int(returnChannel(oldState[i][j][k][1], state[i][j][k][1], counter%mediumTransition, mediumTransition)*255);
        int green = int(returnChannel(oldState[i][j][k][2], state[i][j][k][2], counter%largeTransition, largeTransition)*255);
        red = constrain(red, MIN_VAL, 255);
        blue = constrain(blue, MIN_VAL, 255);
        green = constrain(green, MIN_VAL, 255);
        setGridColor(i, j, k, red, green, blue);
      }
    }
  }
  if (animate) {
    counter++;
  }
}

class Resource {
  PVector loc;
  int state = 0;

  Resource(int xX, int yY, int zZ) {
    loc = new PVector(xX, yY, zZ);
  }
}

class Rule {
  int i;
  int a;
  int b;

  Rule(int I, int A, int B) {
    i = I;
    a = A;
    b = B;
  }
}

float[] hueIndices = new float[STATION_SEGMENT_COUNT];

private static final int BASE_CYCLE_MILLIS = 6000;

void updateHuesAndBytes() {
  int m = millis();
  for (int i=0; i<STATION_SEGMENT_COUNT; i++) {
    hueIndices[i] = 1f*(m%(BASE_CYCLE_MILLIS*(i+1)))/float(BASE_CYCLE_MILLIS*(i+1));
  }

  //AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB
  for (int s=0; s<STATION_COUNT; s++) {
    for (int i=0; i<STATION_SEGMENT_COUNT; i++) {
      float hueIndex = (hueIndices[0] + s/float(STATION_COUNT));
      hueIndex -= floor(hueIndex);
      colorMode(HSB, 1f);
      color c = color(hueIndex, 1f, 1f);
      colorMode(RGB, 255);
      if (s<STATION_ORDER.length) {
        setStationColor(RAINBOW_ORDER[s], i, int(red(c)), int(green(c)), int(blue(c)));
      }
    }
  }
}

float phaseOffset = TWO_PI/144;
void doTheWave() {
  for (int i=0; i<STATION_ORDER.length; i++) {
    for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
      float c = 128 + 128*sin((j*STATION_ORDER.length+i)*phaseOffset + float(millis())/700);
      c = constrain(c, 0, 255);
      float h = (float(millis())/50+(i*STATION_SEGMENT_COUNT+j))%255;
      colorMode(HSB, 255);
      color waveCol = color(h, 255, c);
      setStationColor(STATION_ORDER[i], j, (int)red(waveCol), (int)green(waveCol), (int)blue(waveCol));
      colorMode(RGB, 255);
    }
  }
}
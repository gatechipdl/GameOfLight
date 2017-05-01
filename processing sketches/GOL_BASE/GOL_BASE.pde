import processing.serial.*;

//station grid variables
int GRID_X = 4;
int GRID_Y = 4;
int STATION_SEGMENT_COUNT = 5;
int[] STATION_ORDER = {
  3, 2, 1, 0, 
  4, 5, 6, 7, 
  8, 9, 10, 11, 
  12, 13, 14, 15
};
Table STATION_STATES_TABLE;
int[][][][] STATION_SEGMENT_COLOR = new int[GRID_X][GRID_Y][STATION_SEGMENT_COUNT][3];
int[][][] STATION_SEGMENT_STATE = new int[GRID_X][GRID_Y][STATION_SEGMENT_COUNT];

//serial communication
int STATION_PORT_INDEX = 0;
int PARTICLE_PORT_INDEX = 1;
Serial STATION_PORT;
Serial PARTICLE_PORT;
int SERIAL_BAUD = 57600;
int STATION_COUNT = 36;
int STATION_LED_COUNT = 45;
int STATION_LED_SEGMENT_COUNT = 9;
int COLOR_BYTE_COUNT = 3;
int STATION_COLOR_COUNT = 180;
int STATION_BYTE_COUNT = 540; //3 bytes of color, 5 segments, 36 stations = 540
byte[] packetBytes = new byte[STATION_BYTE_COUNT];

//GUI
int gui_X = 50;
int gui_Y = 50;
int gui_W = 80;
int gui_H = 20;
int gui_gap = 50;
boolean animate = false;

void initGame() {
  printArray(Serial.list());
  String portNameStation = Serial.list()[STATION_PORT_INDEX];
  String portNameParticle = Serial.list()[PARTICLE_PORT_INDEX];
  STATION_PORT = new Serial(this, portNameStation, SERIAL_BAUD);
  PARTICLE_PORT = new Serial(this, portNameParticle, 9600);
  for (int s=0; s<STATION_COUNT; s++) {
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
    STATION_STATES_TABLE.setInt(stationIndex, j, s);
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
    for (int j=0; j<STATION_SEGMENT_COUNT; j++) {
      int colorIndex = s*STATION_SEGMENT_COUNT+j;
      packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][0]); //RED
      packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][1]); //GREEN
      packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)(STATION_SEGMENT_COLOR[rowIndex][colIndex][j][2]); //BLUE
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
      }
    }
  }
}

void sendPackets() {
  STATION_PORT.write(packetBytes);
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
}

void draw() {
  background(0);
  readParticleSerial();

  drawGrid(gui_X, gui_Y, gui_W, gui_H, gui_gap);

  updatePackets();
  sendPackets();

  fill(255);
  text("[ R ] randomize", width-200, gui_Y);
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
    randomize();
    writeTable();
    break;
  case 67: //c
    clearState();
    writeTable();
    break;
  case 83: //s
    animate = !animate;
    break;
  case 81: //q
    break;
  }
}

void mousePressed() {
  for (int i=0; i<GRID_X; i++) {
    for (int j=0; j<GRID_Y; j++) {
      int xPos = i*(gui_W+gui_gap)+gui_X;
      int yPos = j*(gui_H*STATION_SEGMENT_COUNT+gui_gap)+gui_Y;
      for (int k=0; k<STATION_SEGMENT_COUNT; k++) {
        int yPos2 = yPos + k*gui_H;
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
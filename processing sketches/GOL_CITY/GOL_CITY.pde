import processing.serial.*;

//station grid variables
int GRID_X = 6;
int GRID_Y = 6;
int STATION_SEGMENT_COUNT = 5;
int[] STATION_ORDER = {
  0, 1, 2, 3, 4, 5, 
  6, 7, 8, 9, 10, 11, 
  12, 13, 14, 15, 16, 17, 
  18, 19, 20, 21, 22, 23, 
  24, 25, 26, 27, 28, 29, 
  30, 31, 32, 33, 34, 35, 
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
      }
    }
  }
}

void sendPackets() {
  for(int i=0;i<STATION_BYTE_COUNT;i++){
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
    drawSim();
    TIME_CHECK = millis();
    updatePackets();
    sendPackets();
  } else {
    clearPort();
  }

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
    populate(humanDensity);
    writeTable();
    break;
  case 67: //c
    clearState();
    populate(humanDensity);
    writeTable();
    break;
  case 83: //s
    animate = !animate;
    break;
  case 81: //q
    populate(humanDensity);
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
float[][][] population = new float[int(grid.x)][int(grid.y)][int(grid.z)];
float maxPop = 0;
float minPop = 0;
Agent[] agent;
ArrayList<PVector> homes = new ArrayList<PVector>();
ArrayList<PVector> offices = new ArrayList<PVector>();
ArrayList<PVector> commercial = new ArrayList<PVector>();

int dayLength = 8000;
int humanDensity = 40;
float workRatio = 0.4;
float homeRatio = 0.35;
float timeBuffer = 0.3;
float leisureFactor = 0.8;

int timeStamp = 0;
int oldTimeStamp = 0;
color timeCol = #000000;

void initObjects() {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        population[i][j][k] = 0;
        resource[i][j][k] = new Resource(i, j, k);
      }
    }
  }
  populate(humanDensity);
}

void populate(int n) {
  timeStamp = millis();
  updateResource();
  if (homes.size() > 0 && offices.size() > 0) {
    agent = new Agent[n*homes.size()];
    println("population:", agent.length);
    for (int i=0; i<agent.length; i++) {
      PVector homeLoc = homes.get(int(random(homes.size())));
      PVector officeLoc = offices.get(int(random(offices.size())));
      agent[i] = new Agent(homeLoc.x, homeLoc.y, homeLoc.z, officeLoc.x, officeLoc.y, officeLoc.z, timeBuffer, leisureFactor);
    }
  }
}

void updateResource() {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        resource[i][j][k].state = STATION_SEGMENT_STATE[i][j][k];
      }
    }
  }
  homes = new ArrayList<PVector>();
  offices = new ArrayList<PVector>();
  commercial = new ArrayList<PVector>();
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        switch (resource[i][j][k].state) {
        case 1:
          homes.add(new PVector(i, j, k));
          break;
        case 2:
          offices.add(new PVector(i, j, k));
          break;
        case 3:
          commercial.add(new PVector(i, j, k));
          break;
        }
      }
    }
  }
}

void updateAgents() {
  if (agent != null) {
    int delta = millis();
    if (!animate) {
      delta = oldTimeStamp;
    }
    timeCol = returnTimeCol(float((delta-timeStamp)%dayLength)/float(dayLength));
    for (int i=0; i<agent.length; i++) {
      agent[i].update(dayLength, delta-timeStamp, homeRatio, workRatio, commercial);
    }
  }
}

void calPopulation() {
  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        population[i][j][k] = 0;
      }
    }
  }
  if (agent != null) {
    if (agent.length > 0) {
      for (int i=0; i<agent.length; i++) {
        population[int(agent[i].loc.x)][int(agent[i].loc.y)][int(agent[i].loc.z)]++;
      }
      maxPop = 0;
      minPop = agent.length;
      for (int i=0; i<grid.x; i++) {
        for (int j=0; j<grid.y; j++) {
          for (int k=0; k<grid.z; k++) {
            maxPop = maxPop < population[i][j][k] ? population[i][j][k] : maxPop;
            minPop = minPop > population[i][j][k] ? population[i][j][k] : minPop;
          }
        }
      }
    }
  }
}

void drawSim() {

  updateAgents();

  calPopulation();

  for (int i=0; i<grid.x; i++) {
    for (int j=0; j<grid.y; j++) {
      for (int k=0; k<grid.z; k++) {
        if (population[i][j][k]>0) {
          float colVal = map((population[i][j][k]), 0, (maxPop)/3, 15, 255);
          colVal = constrain(colVal, 15, 255);
          colorMode(HSB, 100);
          color fillBox = color(hue(timeCol), int(saturation(timeCol)*((255-colVal/2)/255)), int(colVal/2.55));
          colorMode(RGB, 255);
          setGridColor(i, j, k, (int)red(fillBox), (int)green(fillBox), (int)blue(fillBox));
        }
      }
    }
  }
}

color returnTimeCol(float timeRatio) {
  color colNight = #0000FF;
  color colDay = #FFFF00;
  color colSun = #FF00FF;
  float dawnStart = 0.3;
  float dawnEnd = 0.4;
  float duskStart = 0.7;
  float duskEnd = 0.8;
  colorMode(RGB, 255);
  if (timeRatio < dawnStart) {
    return colNight;
  } else if (timeRatio < dawnEnd) {
    float delta = (timeRatio - dawnStart)/(dawnEnd - dawnStart);
    if (delta < 0.5) {
      delta = delta * 2;
      float rDelta = (red(colSun) - red(colNight))*delta + red(colNight);
      float gDelta = (green(colSun) - green(colNight))*delta + green(colNight);
      float bDelta = (blue(colSun) - blue(colNight))*delta + blue(colNight);
      return color(int(rDelta), int(gDelta), int(bDelta));
    } else {
      delta = (delta-0.5) * 2;
      float rDelta = (red(colDay) - red(colSun))*delta + red(colSun);
      float gDelta = (green(colDay) - green(colSun))*delta + green(colSun);
      float bDelta = (blue(colDay) - blue(colSun))*delta + blue(colSun);
      return color(int(rDelta), int(gDelta), int(bDelta));
    }
  } else if (timeRatio < duskStart) {
    return colDay;
  } else if (timeRatio < duskEnd) {   
    float delta = (timeRatio - duskStart)/(duskEnd - duskStart);
    if (delta < 0.5) {
      delta = delta * 2;
      float rDelta = (red(colSun) - red(colDay))*delta + red(colDay);
      float gDelta = (green(colSun) - green(colDay))*delta + green(colDay);
      float bDelta = (blue(colSun) - blue(colDay))*delta + blue(colDay);
      return color(int(rDelta), int(gDelta), int(bDelta));
    } else {
      delta = (delta-0.5) * 2;
      float rDelta = (red(colNight) - red(colSun))*delta + red(colSun);
      float gDelta = (green(colNight) - green(colSun))*delta + green(colSun);
      float bDelta = (blue(colNight) - blue(colSun))*delta + blue(colSun);
      return color(int(rDelta), int(gDelta), int(bDelta));
    }
  } else {
    return colNight;
  }
}

class Resource {
  PVector loc;
  int state = 0;
  int population = 0;

  Resource(int xX, int yY, int zZ) {
    loc = new PVector(xX, yY, zZ);
  }
}


class Agent {

  PVector loc;
  PVector base;
  PVector work;
  int state = 0;
  int pState = 0;
  float bufferHome;
  float bufferWork;
  float bufferCom;
  float leisure;

  Agent(float xX, float yY, float zZ, float wX, float wY, float wZ, float tB, float lF) {
    loc = new PVector(xX, yY, zZ);
    base = new PVector(xX, yY, zZ);
    work = new PVector(wX, wY, wZ);
    bufferHome = random(-tB, tB);
    bufferWork = random(-tB, tB);
    bufferCom = random(-tB, tB);
    leisure = random(lF);
  }

  void update(int dayL, int time, float hR, float wR, ArrayList<PVector> com) {

    int t = time%dayL;

    float cP1 = hR+hR*bufferHome;
    float cP2 = wR+wR*bufferWork+cP1;
    float cP3 = 1+(1-hR-wR)*bufferCom;

    int dP1 = int(cP1 * float(dayL));
    int dP2 = int(cP2 * float(dayL));
    int dP3 = int(cP3 * float(dayL));

    if (state==2 && dP3 > dayL && t < dP1) {
      t = t+dayL;
    }

    if (t > dP1 && t <= dP2) {
      state = 1;
    } else if (t > dP2 && t <= dP3) {
      state = 2;
    } else if (t > dP3) {
      state = 0;
    }

    if (state != pState) {
      switch (state) {
      case 0:
        loc = new PVector(base.x, base.y, base.z);
        break;
      case 1:
        loc = new PVector(work.x, work.y, work.z);
        break;
      case 2:
        if (com.size() > 0 && random(1) < leisure) {
          PVector comLoc = com.get(floor(random(com.size())));
          loc = new PVector(comLoc.x, comLoc.y, comLoc.z);
        } else {
          loc = new PVector(base.x, base.y, base.z);
        }
        break;
      }
    }

    pState = state;
  }
}


//GUI OBJECTS

class Button {

  PVector pos;
  PVector size;
  Boolean toggle;
  Boolean state;
  String val;
  color passive;
  color active;
  color hover;
  //PFont font;

  Button(int x, int y, int w, int h, boolean t, boolean s, String v, color p, color a, color ho) {
    pos = new PVector(x, y);
    size = new PVector(w, h);
    toggle = t;
    state = s;
    val = v;
    passive = p;
    active = a;
    hover = ho;
    //font = loadFont("Consolas-12.vlw");
  }

  void display() {
    hint(DISABLE_DEPTH_TEST);
    noStroke();
    if (mouseX > pos.x && mouseX < pos.x+size.x && mouseY > pos.y && mouseY < pos.y+size.y) {
      fill(hover);
    } else {
      if (state) {
        fill(active);
      } else {
        fill(passive);
      }
    }
    rect(pos.x, pos.y, size.x, size.y);
    fill(0);
    textAlign(CENTER, CENTER);
    //textFont(font, 12);
    text(val, pos.x+size.x/2, pos.y+size.y/2);
    hint(ENABLE_DEPTH_TEST);
  }

  boolean inside(int x, int y) {
    if (x > pos.x && x < pos.x+size.x && y > pos.y && y < pos.y+size.y) {
      return true;
    } else {
      return false;
    }
  }
}
int gridX = 6;
int gridY = 6;
int layers = 1;
int states = 3;
int lanternForm[][][] = new int[gridX][gridY][layers];
float lanternResource[][][][] = new float[gridX][gridY][layers][3];
float diffusion = 0.05;

// interface variables
int startX = 50;
int startY = 50;
int buttonSize = 15;
int buttonGap = 10;
toggleButton animateButton = new toggleButton("ANIMATE", false, 50, 640, 80, 23);
toggleButton colorButton = new toggleButton("RGB / GRAY", false, 50, 680, 80, 23);
bangButton resetButton = new bangButton("RESET", 50, 720, 80, 23); 
bangButton randomButton = new bangButton("RANDOM", 155, 640, 80, 23); 
bangButton clearButton = new bangButton("CLEAR", 155, 680, 80, 23);

// scene variables
int lanternUnitX = 15;
int lanternUnitY = 30;
int gridBuffer = 80;
float rotX = -0.5;
float rotY = 0;
float rotIncre = 0.2;

// game variables
boolean runAnimation = false;
float healthModifier = 0.05;
float maxResource = 255;

void setup() {
  fullScreen(P3D);
  noSmooth();
  background(0);

  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        lanternForm[i][j][k] = 0;
        lanternResource[i][j][k][0] = 0;
        lanternResource[i][j][k][1] = 0;
        lanternResource[i][j][k][2] = 0;
      }
    }
  }
}

void draw() {
  hint(DISABLE_DEPTH_TEST);
  background(0);
  drawInterface();
  fill(200);
  noStroke();
  textAlign(LEFT, TOP);
  text("0/1/2/3 + click: set all to a number", 50, 580);
  hint(ENABLE_DEPTH_TEST);
  drawScene();
  if (animateButton.tog) {
    animate();
  }
}

void drawInterface() {
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        int posX = startX + i*(buttonSize + buttonGap);
        int posY = startY + j*(buttonSize*layers + buttonGap) + k*(buttonSize);
        noStroke();
        fill(100 + lanternForm[i][j][k]*50);
        rect(posX, posY, buttonSize, buttonSize);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(10);
        text(lanternForm[i][j][k], posX + buttonSize/2, posY + buttonSize/2);
      }
    }
  }
  clearButton.display();
  randomButton.display();
  animateButton.display();
  colorButton.display();
  resetButton.display();
}

void drawScene() {
  int boxW = lanternUnitX*(states*2-1) + gridBuffer;
  int boxH = lanternUnitY*layers + gridBuffer;
  int gridW = boxW * gridX;
  int gridD = boxW * gridY;
  translate(displayWidth/2, displayHeight/2, -gridD/2);
  rotateX(rotX);
  rotateY(rotY);
  noFill();
  stroke(50);
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      pushMatrix();
      translate(boxW*i-(gridW-boxW)/2, 0, boxW*j-(gridD-boxW)/2);
      box(boxW, boxH, boxW);
      popMatrix();
    }
  }

  noStroke();
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        if (lanternForm[i][j][k] != 0) {
          pushMatrix();
          translate(boxW*i-(gridW-boxW)/2, 0, boxW*j-(gridD-boxW)/2);
          translate(0, -(boxH-gridBuffer)/2 + lanternUnitY/2, 0);
          translate(0, k*lanternUnitY, 0);
          if (animateButton.tog) {
            stroke(0);
          } else {
            stroke(75);
          }

          float redC, greenC, blueC;

          if (colorButton.tog) {
            redC = sq(lanternResource[i][j][k][0]/maxResource)*maxResource;
            greenC = sq(lanternResource[i][j][k][1]/maxResource)*maxResource;
            blueC = sq(lanternResource[i][j][k][2]/maxResource)*maxResource;
          } else {
            redC = sq(((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3)/maxResource)*maxResource;
            greenC = sq(((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3)/maxResource)*maxResource;
            blueC = sq(((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3)/maxResource)*maxResource;
            //redC = ((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3);
            //greenC = ((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3);
            //blueC = ((lanternResource[i][j][k][0]+lanternResource[i][j][k][1]+lanternResource[i][j][k][2])/3);
          }
          fill(int(redC), int(blueC), int(greenC));
          box(lanternUnitX*(lanternForm[i][j][k]*2-1), lanternUnitY, lanternUnitX*(lanternForm[i][j][k]*2-1));
          popMatrix();
        }
      }
    }
  }
}

void randomForm() {
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        lanternForm[i][j][k] = floor(random(1, 4));
        for (int c=0; c<3; c++) {
          if (c==lanternForm[i][j][k]-1) {
            lanternResource[i][j][k][c] = maxResource;
          } else {
            lanternResource[i][j][k][c] = 0;
          }
        }
      }
    }
  }
}

void reset() {
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        for (int c=0; c<3; c++) {
          if (c==lanternForm[i][j][k]-1) {
            lanternResource[i][j][k][c] = maxResource;
          } else {
            lanternResource[i][j][k][c] = 0;
          }
        }
      }
    }
  }
}

void clearForm() {
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        lanternForm[i][j][k] = 0;
        lanternResource[i][j][k][0] = 0;
        lanternResource[i][j][k][1] = 0;
        lanternResource[i][j][k][2] = 0;
      }
    }
  }
}

void animate() {
  float LC[][][][] = new float[gridX][gridY][layers][3]; //sum of neighboring colors 
  float LCN[][][][] = new float[gridX][gridY][layers][3]; //sum of neighbors
  for (int k=0; k<layers; k++) {
    for (int i=0; i<gridX; i++) {
      for (int j=0; j<gridY; j++) {
        for (int c=0; c<3; c++) {
          LC[i][j][k][c] = 0;
          LCN[i][j][k][c] = 0;
        }
      }
    }
  }
  for (int k=0; k<layers; k++) {
    for (int i=0; i<gridX; i++) {
      for (int j=0; j<gridY; j++) {
        for (int c=0; c<3; c++) {
          for (int x=-1; x<=1; x++) {
            for (int y=-1; y<=1; y++) {
              if (!(x==0 && y==0)) {
                int xV = (i+x+gridX)%gridX;
                int yV = (j+y+gridY)%gridY;
                if (lanternForm[xV][yV][k] != 0) {
                  LCN[i][j][k][c]++;
                  LC[i][j][k][c] = LC[i][j][k][c] + lanternResource[xV][yV][k][c];
                }
              }
            }
          }
        }
      }
    }
  }

  for (int k=0; k<layers; k++) {
    for (int i=0; i<gridX; i++) {
      for (int j=0; j<gridY; j++) {
      }
    }
  }
  calculateDiversity();
}

float diversity[][][] = new float[gridX][gridY][layers];
void calculateDiversity() {
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      for (int k=0; k<layers; k++) {
        int count[] = new int[4];
        for (int c=0; c<4; c++) {
          count[c] = 0;
        }
        for (int x=-1; x<=1; x++) {
          for (int y=-1; y<=1; y++) {
            if (!(x==0 && y==0)) {
              int xV = (i+x+gridX)%gridX;
              int yV = (j+y+gridY)%gridY;
              count[lanternForm[xV][yV][k]]++;
            }
          }
        }
        float countDelta[] = new float[4];
        float totalCount = 0;
        for (int c=1; c<4; c++) {
          totalCount = totalCount + count[c];
        }
        for (int c=1; c<4; c++) {
          countDelta[c] = abs(totalCount/3 - count[c]);
        }
        diversity[i][j][k] = 0;
        for (int c=1; c<4; c++) {
          diversity[i][j][k] = diversity[i][j][k] + countDelta[c];
        }
      }
    }
  }
}

void mousePressed() {
  boolean breakLoop = false;
  for (int i=0; i<gridX; i++) {
    for (int j=0; j<gridY; j++) {
      if (keyPressed) {
        int minX = startX + i*(buttonSize + buttonGap);
        int maxX = startX + i*(buttonSize + buttonGap) + buttonSize;
        int minY = startY + j*(buttonSize*layers + buttonGap);
        int maxY = startY + j*(buttonSize*layers + buttonGap) + layers*(buttonSize) + buttonSize;
        if (mouseX >= minX && mouseX <=maxX && mouseY >= minY && mouseY <= maxY) {
          if (key=='0') {
            for (int k=0; k<layers; k++) {
              lanternForm[i][j][k] = 0;
              for (int c=0; c<3; c++) {
                if (c==lanternForm[i][j][k]-1) {
                  lanternResource[i][j][k][c] = maxResource;
                } else {
                  lanternResource[i][j][k][c] = 0;
                }
              }
            }
          } else if (key=='1') {
            for (int k=0; k<layers; k++) {
              lanternForm[i][j][k] = 1;
              for (int c=0; c<3; c++) {
                if (c==lanternForm[i][j][k]-1) {
                  lanternResource[i][j][k][c] = maxResource;
                } else {
                  lanternResource[i][j][k][c] = 0;
                }
              }
            }
          } else if (key=='2') {
            for (int k=0; k<layers; k++) {
              lanternForm[i][j][k] = 2;
              for (int c=0; c<3; c++) {
                if (c==lanternForm[i][j][k]-1) {
                  lanternResource[i][j][k][c] = maxResource;
                } else {
                  lanternResource[i][j][k][c] = 0;
                }
              }
            }
          } else if (key=='3') {
            for (int k=0; k<layers; k++) {
              lanternForm[i][j][k] = 3;
              for (int c=0; c<3; c++) {
                if (c==lanternForm[i][j][k]-1) {
                  lanternResource[i][j][k][c] = maxResource;
                } else {
                  lanternResource[i][j][k][c] = 0;
                }
              }
            }
          }
        }
      } else {
        for (int k=0; k<layers; k++) {
          int minX = startX + i*(buttonSize + buttonGap);
          int maxX = startX + i*(buttonSize + buttonGap) + buttonSize;
          int minY = startY + j*(buttonSize*layers + buttonGap) + k*(buttonSize);
          int maxY = startY + j*(buttonSize*layers + buttonGap) + k*(buttonSize) + buttonSize;
          if (mouseX >= minX && mouseX <=maxX && mouseY >= minY && mouseY <= maxY) {
            lanternForm[i][j][k] = (lanternForm[i][j][k] + 1) % (states+1);
            for (int c=0; c<3; c++) {
              if (c==lanternForm[i][j][k]-1) {
                lanternResource[i][j][k][c] = maxResource;
              } else {
                lanternResource[i][j][k][c] = 0;
              }
            }
            breakLoop = true;
          }
          if (breakLoop) {
            break;
          }
        }
        if (breakLoop) {
          break;
        }
      }
    }
    if (breakLoop) {
      break;
    }
  }

  if (clearButton.click(mouseX, mouseY)) {
    clearForm();
  }
  if (randomButton.click(mouseX, mouseY)) {
    randomForm();
  }
  if (resetButton.click(mouseX, mouseY)) {
    reset();
  }
  if (animateButton.click(mouseX, mouseY)) {
  }
  if (colorButton.click(mouseX, mouseY)) {
  }
}

void keyPressed() {
  //println(keyCode);
  switch(keyCode) {
  case 38: //UP
    rotX = rotX + rotIncre;
    break;
  case 40: //DOWN
    rotX = rotX - rotIncre;
    break;
  case 37: //LEFT
    rotY = rotY - rotIncre;
    break;
  case 39: //RIGHT
    rotY = rotY + rotIncre;
    break;
  case 32:
    save("screenshot"+day()+month()+year()+hour()+minute()+second()+".png");
    break;
  case 82: // r
    reset();
    break;
  case 81: // q
    randomForm();
    break;
  case 83: // s
    runAnimation = !runAnimation;
    break;
  case 67: // c
    clearForm();
    break;
  }
}

class toggleButton {

  String s;
  boolean tog;
  int x;
  int y;
  int w;
  int h;

  toggleButton(String name, boolean t, int xPos, int yPos, int wW, int hH) {
    s = name;
    tog = t;
    x = xPos;
    y = yPos;
    w = wW;
    h = hH;
  }

  void display() {
    if (!tog) {
      stroke(200);
      noFill();
      rect(x, y, w, h);
      textAlign(CENTER, CENTER);
      noStroke();
      fill(200);
      text(s, x+w/2, y+h/2);
    } else {
      noStroke();
      fill(200);
      rect(x, y, w, h);
      textAlign(CENTER, CENTER);
      noStroke();
      fill(0);
      text(s, x+w/2, y+h/2);
    }
  }

  boolean click(int cX, int cY) {
    if (cX >= x && cX <= x+w && cY >= y && cY <= y+h) {
      tog = !tog;
      return true;
    } else {
      return false;
    }
  }
}

class bangButton {

  String s;
  boolean tog = false;
  int x;
  int y;
  int w;
  int h;

  bangButton(String name, int xPos, int yPos, int wW, int hH) {
    s = name;
    x = xPos;
    y = yPos;
    w = wW;
    h = hH;
  }

  void display() {
    if (!tog) {
      stroke(200);
      noFill();
      rect(x, y, w, h);
      textAlign(CENTER, CENTER);
      noStroke();
      fill(200);
      text(s, x+w/2, y+h/2);
    } else {
      noStroke();
      fill(200);
      rect(x, y, w, h);
      textAlign(CENTER, CENTER);
      noStroke();
      fill(0);
      text(s, x+w/2, y+h/2);
      tog = false;
    }
  }

  boolean click(int cX, int cY) {
    if (cX >= x && cX <= x+w && cY >= y && cY <= y+h) {
      tog = true;
      return true;
    } else {
      return false;
    }
  }
}
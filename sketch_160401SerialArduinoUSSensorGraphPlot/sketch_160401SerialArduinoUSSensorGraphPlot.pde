/*
Arduino Processing serial communication
 processing side sample
 
 http://yoppa.org/tau_bmaw13/4770.html
 Plot graph of data from Sensors on Arduino
 */

import processing.serial.*;
int NUM = 2;
float scale = 2;
Serial myPort;

int[] sensors = new int[NUM];

color[] col = new color[6];
int colorCount = 0;

float r;
float theta;

void setup() {
//  size(800, 800);
  size(1600, 1600);

  myPort = new Serial(this, Serial.list()[0], 9600); //Serial.list()[0]
//  myPort = new Serial(this, "COM12", 9600); //Serial.list()[0]
  myPort.bufferUntil('\n');
  initGraph();
  drawAxis();
}   

void draw() {
  fill(col[colorCount]);
  float x = r * cos(radians(theta));
  float y = r * sin(radians(theta));
  float tx = (-x * scale + 0.5 * width) ;
  float ty = (y) * scale;
  ellipse(tx, ty, width / 100, height / 100);
  stroke(col[colorCount]);
  line(0.5 * width, 0, tx, ty);
  noStroke();

  fill(47);
  rect(0, height - height / 20 - 1, width, height / 20);
  fill(255);
  textAlign(RIGHT, BOTTOM);
  textSize(height/20);
  text("(r, theta) = (" + r + "," + theta + ")", width, height);
}

void initGraph() {
  background(47);
  noStroke();
  col[0] = color(255, 0, 0, 50);
  col[1] = color(0, 255, 0, 50);
  col[2] = color(0, 0, 255, 50);
  col[3] = color(255, 255, 0, 50);
  col[4] = color(0, 255, 255, 50);
  col[5] = color(255, 0, 255, 50);
}

void drawAxis() {
  stroke(255);
  noFill();
  textAlign(RIGHT, BOTTOM);
  textSize(height / 40);
  line(0.5 * width, 0, 0.5 * width, height);
  for (int i = 0; i <= height; i += 50) {
    ellipse(0.5 * width, 0, 2 * i * scale, 2 * i * scale);
    text(i, 0.5 * width, i * scale);
  }
  noStroke();
}

void serialEvent(Serial myPort) {
  String myString = myPort.readStringUntil('\n');
  myString = trim(myString);
  println(myString);
  int tmp[] = int(split(myString, ','));
  if (tmp.length > 1) {
    for (int i = 0; i < NUM; i++) {
      sensors[i] = tmp[i];
    }
  }
  if (tmp.length == 2) {
    r = sensors[0];
    theta = sensors[1];
    if (theta <= 30) {
      colorCount++;
      if (colorCount >= col.length) colorCount = 0;
    }
  }
}

void keyPressed() {
  switch(key) {
  case 'r':
    initGraph();
    drawAxis();
    break;
  case 'a':
    scale += 0.5;
    initGraph();
    drawAxis();
    break;  
  case 'A':
    scale -= 0.5;
    initGraph();
    drawAxis();
    break;
  default: 
    break;
  }
}

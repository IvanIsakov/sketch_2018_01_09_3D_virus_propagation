ArrayList<Lines> vectorField = new ArrayList<Lines>();
ArrayList<Interaction> interactionField = new ArrayList<Interaction>();
int lineSize = 72;
float interactDist = lineSize;
float boxsize = 0.1;

float VirusCoef = 0.10;
float recoveryCoeff = 0.05;

float viscosity = 0.002;
float IntCoeff = 0.01;
int w = 720;
int sphere = 500;
int h = 720;
int mousePressedInt = 0;
int mousePressedPrev = 0;
int index = 0; // counting

// emulateMouse
boolean emulate = false;
boolean mousePressedBool = false;
float emulateMouseX;
float emulateMouseY;
float pemulateMouseX;
float pemulateMouseY;

float xoff = 0;
float yoff = 0;

void setup() {
  size(720,720,P3D);
  background(255);
  for (int i = -w/lineSize; i < w/lineSize; i++) {
    //yoff += 0.01;
    for (int j = -h/lineSize; j < h/lineSize; j++) {
      for (int k = -h/lineSize; k < h/lineSize; k++) {  
      //xoff += 0.01;
      float rx = random(-width,width);
      float ry = random(-height,height);
      float rz = random(-height,height);
      //float rx = noise(xoff,yoff)*w;
      //float ry = noise(xoff+5,yoff+5)*h;
      if (sq(rx) + sq(ry) + sq(rz) < sq(sphere)) {
        Lines l = new Lines(rx,ry,rz);
        vectorField.add(l);
      }
      //yoff = 0;
    }
  }
  for (Lines l : vectorField) {
    for (Lines k : vectorField) {
      if (l.ax <= k.ax + interactDist && l.ax >= k.ax - interactDist && 
          l.ay <= k.ay + interactDist && l.ay >= k.ay - interactDist && 
          l.az <= k.az + interactDist && l.az >= k.az - interactDist) {
            Interaction a = new Interaction(l,k);    
            interactionField.add(a);
          }
      }
    }
  }
}

void draw() {
  stroke(255);
  background(90);
  lights();
  camera(800,500*index/300,0,
        0,0,0,
        0,1,0);
  emulateMouse();
  if (mousePressedBool) {
    mousePressedInt = 1;
  } else {
    mousePressedInt = 0;
  }

  for (Lines l : vectorField) {
    l.update();
    l.display();
  }
  for (Interaction I : interactionField) {
    I.update(); 
    I.display();
  }

  mousePressedPrev = mousePressedInt;
  saveFrame("virus_propagation_3D_small-####.tiff");
  index++;
  if (index > 300) index = 0;
}

class Lines {
  float ax,ay,az;
  float arot, arotspeedX,arotspeedY;
  color colorStroke = 255;
  float speedCoeff = 0.45;
  float gravity = 0.0;
  boolean mouseInteract;
  float Virus;
  float transmission;
  
  Lines(float x1, float y1, float z1) {
    ax = x1;
    ay = y1;
    az = z1;
  }
  
  void update() {
    
    //For mouse pressing the unit
    /*
    if (mousePressedInt - mousePressedPrev == 1) {  
      if (emulateMouseX < ax + lineSize/2 && emulateMouseX > ax - lineSize/2 && 
          emulateMouseY < ay + lineSize/2 && emulateMouseY > ay - lineSize/2) {        
          mouseInteract = true;
          Virus = 1;
          }
    }
    */
    // For middle one
    if (mousePressedInt - mousePressedPrev == 1) {  
      if (ax < lineSize/2 && ax > -lineSize && 
          ay < lineSize/2 && ay > -lineSize && 
          az < lineSize/2 && az > -lineSize ) {        
          mouseInteract = true;
          Virus = 1;
          }
    }
    
    if (!mousePressedBool) {
      mouseInteract = false;
    }
    /*
    if (mouseInteract) {
      ax = emulateMouseX;
      ay = emulateMouseY;
    }
    */              
   Virus += transmission - Virus*recoveryCoeff;

  }
  
  void display() {
    float colorIntens = map((abs(arotspeedX)+abs(arotspeedX)),0,5,200,0);
    //float colorIntens = map(abs(arot),0,5,200,0);
    
    //colorStroke = color(map(ax,0,width,0,255),map(ax,width,0,0,255),colorIntens,255);
    colorStroke = color(Virus*55,10,Virus*255);
    fill(colorStroke);
    //strokeWeight(5);
    noStroke();
    //stroke(0,0,colorIntens);
    pushMatrix();
    translate(ax,ay,az);
    //translate(ax,ay,dx);
    //translate(dx,dy);
    box(boxsize*lineSize);
    //rect(-boxsize*lineSize/2,-boxsize*lineSize/2,boxsize*lineSize,boxsize*lineSize);
    //ellipse(0,0,0.8*lineSize,0.8*lineSize);
    //line(-lineSize/2,0,lineSize/2,0);
    popMatrix();
  }
}



class Interaction {
  Lines l1;
  Lines l2;
  boolean transmission;

  float maxNoInteraction = lineSize/5;
  
  Interaction(Lines Line1, Lines Line2) {
    l1 = Line1;
    l2 = Line2;
  }
  
  void update() {
    if ((l1.Virus - l2.Virus) > 0.9) {   
      //l1.transmission = -VirusCoef*(l1.Virus - l2.Virus);
      l2.transmission = -VirusCoef*(l2.Virus - l1.Virus)*abs(l2.ax - l1.ax)/lineSize;
    }
    /*
    if ((l1.ax - l2.ax) > maxNoInteraction || (l1.ay - l2.ay) > maxNoInteraction) {
      
      l1.arotspeedX += IntCoeff*(l2.ax - l1.ax);
      l2.arotspeedX += IntCoeff*(l1.ax - l2.ax);
      l1.arotspeedY += IntCoeff*(l2.ay - l1.ay);
      l2.arotspeedY += IntCoeff*(l1.ay - l2.ay);
      
      //l1.arot += IntCoeff*(l2.dx - l1.dx);
      //l2.arot += IntCoeff*(l1.dx - l2.dx);
      }
      */
  }
  
  void display() {

    color colorStroke = color(l1.Virus*55,10,l1.Virus*255);
    stroke(colorStroke);
    line(l1.ax,l1.ay,l1.az,l2.ax,l2.ay,l2.az);
    //beginShape();
    //vertex(l1.ax + l1.dx,l1.dy + l1.ay);
    //vertex(l2.ax + l2.dx,l1.dy + l1.ay);
    //endShape();
  }
}

void emulateMouse() {
  
  emulateMouseX = map(mouseX,0,width,0,width);
  emulateMouseY = map(mouseY,0,height,0,height);
  pemulateMouseX = map(pmouseX,0,width,0,width);
  pemulateMouseY = map(pmouseY,0,height,0,height);
  if (mousePressed) {
    mousePressedBool = true;
  } else {
    mousePressedBool = false;
  }

}
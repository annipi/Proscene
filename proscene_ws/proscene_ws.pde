/**
 * Using PostEffects.
 * by Ivan Castellanos and Jean Pierre Charalambos.
 *
 * This example illustrates shader chaining which requires drawing the scene
 * frames into an arbitrary PGraphics (see line 116).
 *
 * Press '1' to '9' to (de)activate effect.
 */
import remixlab.proscene.*;
import remixlab.dandelion.geom.*;

PShader noiseShader, kaleidoShader, raysShader, dofShader, pixelShader, edgeShader, colorShader, horizontalShader;
PGraphics drawGraphics, dofGraphics, noiseGraphics, kaleidoGraphics, raysGraphics, pixelGraphics, edgeGraphics, graphics, colorGraphics, horizontalGraphics;
InteractiveFrame solarSystem, iSun, iPlanet, iMoon1, iMoon2;
Scene scene;
float theta = 0;
boolean bdepth, brays, bpixel, bedge, bdof, bkaleido, bnoise, bhorizontal;
PImage universe, sun, planet, moon;

void setup(){
  size(740, 463, P3D);
  
  universe = loadImage("universe.jpg"); 
  sun = loadImage("sun.jpg");  
  planet = loadImage("planet.jpg");
  moon = loadImage("moon.jpg");
  
  graphics = createGraphics(width, height, P3D); 
  scene = new Scene(this);
  scene.setAxesVisualHint(false);
  scene.setGridVisualHint(false);
  //solarSystem = new InteractiveFrame(scene, solarSystem());

  iSun = new InteractiveFrame(scene, createEllipse(500,sun));
  iPlanet = new InteractiveFrame(scene, createEllipse(250,planet));
  iPlanet.rotateAroundFrame(0, 0, 0,iSun);
  iPlanet.translate(250+150, 0);
  iMoon1 = new InteractiveFrame(scene, createEllipse(100,moon));
  iMoon1.rotateAroundFrame(0, 0, 0,iPlanet);
  iMoon1.translate(380+150+60, 0);
  iMoon2 = iMoon1 = new InteractiveFrame(scene, createEllipse(45,moon));
  iMoon2.rotateAroundFrame(0, 0, 0, iPlanet);
  iMoon2.translate(500+150+35, 0);
  
  scene.setRadius(1000);
  scene.showAll();
  
  colorShader = loadShader("colorfrag.glsl");
  colorShader.set("maxDepth", scene.radius()*2);
  colorGraphics = createGraphics(width, height, P3D);
  colorGraphics.shader(colorShader);
  
  edgeShader = loadShader("edge.glsl");
  edgeGraphics = createGraphics(width, height, P3D);
  edgeGraphics.shader(edgeShader);
  edgeShader.set("aspect", 1.0/width, 1.0/height);
  
  pixelShader = loadShader("pixelate.glsl");
  pixelGraphics = createGraphics(width, height, P3D);
  pixelGraphics.shader(pixelShader);
  pixelShader.set("xPixels", 100.0);
  pixelShader.set("yPixels", 100.0);
  
  raysShader = loadShader("raysfrag.glsl");
  raysGraphics = createGraphics(width, height, P3D);
  raysGraphics.shader(raysShader);
  raysShader.set("lightPositionOnScreen", 0.5, 0.5);
  raysShader.set("lightDirDOTviewDir", 0.7);
  
  dofShader = loadShader("dof.glsl");  
  dofGraphics = createGraphics(width, height, P3D);
  dofGraphics.shader(dofShader);
  dofShader.set("aspect", width / (float) height);
  dofShader.set("maxBlur", 0.015);  
  dofShader.set("aperture", 0.02);
  
  kaleidoShader = loadShader("kaleido.glsl");
  kaleidoGraphics = createGraphics(width, height, P3D);
  kaleidoGraphics.shader(kaleidoShader);
  kaleidoShader.set("segments", 2.0);
  
  noiseShader = loadShader("noise.glsl");
  noiseGraphics = createGraphics(width, height, P3D);
  noiseGraphics.shader(noiseShader);
  noiseShader.set("frequency", 4.0);
  noiseShader.set("amplitude", 0.1);
  noiseShader.set("speed", 0.1);
  
  horizontalShader = loadShader("horizontal.glsl");
  horizontalGraphics = createGraphics(width, height, P3D);
  horizontalGraphics.shader(horizontalShader);
  horizontalShader.set("h", 0.005);
  horizontalShader.set("r", 0.5);
   
  frameRate(100);
}

void draw() {
  PGraphics pg = graphics;

  // 1. Draw into main buffer
  //scene.beginDraw();
  background(universe);
  scene.drawFrames();
  //scene.endDraw();
 
  drawGraphics = graphics;
  
  if (bdepth){
    colorGraphics.beginDraw();
    colorGraphics.background(0);
    //Note that when drawing the frames into an arbitrary PGraphics
    //the eye position of the main PGraphics is used
    scene.drawFrames(colorGraphics);
    colorGraphics.endDraw();
    drawGraphics = colorGraphics;
  }
  if (bkaleido) {
    kaleidoGraphics.beginDraw();
    kaleidoShader.set("tex", drawGraphics);
    kaleidoGraphics.image(graphics, 0, 0);
    kaleidoGraphics.endDraw();    
    drawGraphics = kaleidoGraphics;
  }
  if (bnoise) {
    noiseGraphics.beginDraw();
    noiseShader.set("time", millis() / 1000.0);
    noiseShader.set("tex", drawGraphics);
    noiseGraphics.image(graphics, 0, 0);
    noiseGraphics.endDraw();    
    drawGraphics = noiseGraphics;
  }
  if (bpixel) {
    pixelGraphics.beginDraw();
    pixelShader.set("tex", drawGraphics);
    pixelGraphics.image(graphics, 0, 0);
    pixelGraphics.endDraw();
    drawGraphics = pixelGraphics;    
  }
  if (bdof) {  
    dofGraphics.beginDraw();
    dofShader.set("focus", map(mouseX, 0, width, -0.5f, 1.5f));    
    dofShader.set("tDepth", colorGraphics);
    dofShader.set("tex", drawGraphics);
    dofGraphics.image(graphics, 0, 0);
    dofGraphics.endDraw();    
    drawGraphics = dofGraphics;
  }
  if (bedge) {  
    edgeGraphics.beginDraw();
    edgeShader.set("tex", drawGraphics);
    edgeGraphics.image(graphics, 0, 0);
    edgeGraphics.endDraw();    
    drawGraphics = edgeGraphics;
  }
  if (bhorizontal) {
    horizontalGraphics.beginDraw();
    horizontalShader.set("tDiffuse", drawGraphics);
    horizontalGraphics.image(graphics, 0, 0);
    horizontalGraphics.endDraw();    
    drawGraphics = horizontalGraphics;
  }
  if (brays) {   
    raysGraphics.beginDraw();
    raysShader.set("otex", drawGraphics);
    raysShader.set("rtex", drawGraphics);
    raysGraphics.image(graphics, 0, 0);
    raysGraphics.endDraw();    
    drawGraphics = raysGraphics;
  }
  //scene.display(drawGraphics);
  drawText();
}

void drawText() {
  scene.beginScreenDrawing();
  text(bdepth ? "1. Depth (*)" : "1. Depth", 5, 20);
  text(bkaleido ? "2. Kaleidoscope (*)" : "2. Kaleidoscope", 5, 35);
  text(bnoise ? "3. Noise (*)" : "3. Noise", 5, 50);
  text(bpixel ? "4. Pixelate (*)" : "4. Pixelate", 5, 65);
  text(bdof ? "5. DOF (*)" : "5. DOF", 5, 80);
  text(bedge ? "6. Edge (*)" : "6. Edge", 5, 95);
  text(bhorizontal ? "7. Horizontal (*)" : "7. Horizontal", 5, 110);
  text(brays ? "8. Rays (*)" : "8. Rays", 5, 125);
  scene.endScreenDrawing();
}

PShape createEllipse(float s, PImage img){
  pushStyle();
  PShape sh = createShape(SPHERE, s/2);
  sh.setStroke(false);
  sh.setTexture(img);
  popStyle();
  return sh;
}
/*
PShape solarSystem() {
  pushStyle();
  PShape sh = createShape();
  sh.setStroke(false);
  createEllipse(500,sun);
  
  pushMatrix();
  sh.rotate(theta);
  sh.translate(150, 0);
  createEllipse(50,planet);
   
  pushMatrix();
  sh.rotate(-theta*4);
  sh.translate(60, 0);
  createEllipse(20,moon);
  popMatrix();
  
  pushMatrix();
  sh.rotate(theta*2);
  sh.htranslate(35, 0);
  createEllipse(16,moon);
  popMatrix();
  
  popMatrix();
  theta += 0.01;
  
  popStyle();
  
  return sh;
}
*/

void keyPressed() {
  if(key=='1')
    bdepth = !bdepth;
  if(key=='2')
    bkaleido = !bkaleido;
  if(key=='3')
    bnoise = !bnoise;
  if(key=='4')
    bpixel = !bpixel;
  if(key=='5')
    bdof = !bdof;  
  if(key=='6')
    bedge = !bedge;
  if(key=='7')
    bhorizontal = !bhorizontal;
  if(key=='8')
    brays = !brays;
}

/*
// Angle of rotation around sun and planets
float theta = 0;
PImage bg;
PImage sun;
PImage planet;
PImage moon;
boolean rFlag = false;

void setup() {
  size(740, 463, P3D);
  bg = loadImage("universe.jpg");
  sun = loadImage("sun.jpg");  
  planet = loadImage("planet.jpg");
  moon = loadImage("moon.jpg");
}

void draw() {
  background(bg);  
  noStroke();
  
  
  // Translate to center of window to draw the sun.
  translate(width/2, height/2);
  
  camera(0, 0, mouseY, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
  if(rFlag){
    rotateX(mouseY/100.0);
    rotateY(mouseX/100.0);
  }
  //fill(96);
  createEllipse(100,sun);

  // The earth rotates around the sun
  pushMatrix();
  rotate(theta);
  translate(150, 0);
  //fill(0,51,102,25);
  createEllipse(50,planet);

  // Moon #1 rotates around the earth
  pushMatrix(); 
  rotate(-theta*4);
  translate(60, 0);
  //fill(192);
  createEllipse(20,moon);
  popMatrix();

  // Moon #2 also rotates around the earth
  pushMatrix();
  rotate(theta*2);
  translate(35, 0);
  //fill(192);
  createEllipse(16,moon);
  popMatrix();

  popMatrix();

  theta += 0.01;
}

void createEllipse(float s, PImage img){
  PShape sh = createShape(SPHERE, s/2);
  sh.setTexture(img);
  shape(sh);
}

void keyPressed() {
  if(key == 'r' || key == 'R')
    rFlag =!rFlag;
}
*/
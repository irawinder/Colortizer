// Code that visualizes "ScanGrid" Analysis for debugging, etc
// by Ira Winder, MIT Medai Lab, July 2014

// Display Parameters
  boolean freq = false; // Toggle HSBRGB frequency GUI
  boolean showCam = false; // Toggle CornerCalibration GUI
  boolean img = false; // Toggle False Color Image Overlay
  boolean brokenFreq = false; //Detects when canvas proportions break
  boolean fullScreen = false; //Allows Higher-res display
  boolean cellOutline = false; //Outlines cell boundaries
  boolean locked = false;
  boolean dragged = false;
  boolean hover = false;
  boolean allowDrag = false;
  
  int colorMode = 0; // '0' is false color based on random hues; '1' is approximate RGBHSB color
  int baseindex = 0; // Number describing which reference color is selected.
  int scanDelay = 0; // Number of frames before restarting display.  helps to make sure other threads update before running code.
  int delay = 0;
  
  // Display Dimensions
  int marg = 60; // Frequency Graph Top and left Margin
  int margRight = 140; //Right-hand column
  int margTop = 200; //Applet Top Margin
  int margBottom = 40; //Applet Bottom Marging (since doesn't line up well)
  int margLeft = 20; // Left Margin
  int margInputs = 0;
  int margCam = 400; //Left Margin for Camera Calibration Display
  int freqWidth = 450; //Width of HSBRGB Frequency Visualization
  int tsize = 12; //base text size of title and help
  int xOffset, yOffset;
  int xClick, yClick, xDrag, yDrag;
  
  // Holds Cursor Position(s) in memory
  int tempu = 0;
  int tempv = 0;
  int tempw = 0;
  int tempx = 0;
  
  int holdu = 0;
  int holdv = 0;
  int holdw = 0;
  int holdx = 0;
  
  // Helper Dependent Variables
  int sumdif;
  PGraphics scanGraphic;
  int imgH;
  int imgW;
  float aspect;

public void setupViz() {
  
  // Holds Cursor Position(s) in memory
  tempu = floor(scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()/2)+1;
  tempv = floor(scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()/2)+1;
  tempw = 0;
  tempx = 0;
  
  holdu = floor(scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()/2);
  holdv = floor(scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()/2);
  holdw = 0;
  holdx = 0;
  
  checkTemps();
  
}

public void drawViz() {
  if (showCam) {
      // Corner Calibration Mode
      camDisplay();
    } else {
      if (scanDelay == 0) {
        // Color Grid Visualization Mode
        scanDisplay();
      } else { //Visualization is delayed to allow main thread to catch up, preventing crash
        scanDelay--;
      }
    }
}

// Displays camera feed at full size
public void camDisplay() {
  
  background(0);
  
  // Print Title and Help
  printTitle();
  printHelp2();
  
  // Print WebCam and Corner Pins
  translate(margCam,0);
  drawCamCalibration();
  translate(-margCam,0);
}

public void scanDisplay() {
  
  background(0);
  
  //Determines if frequency table will fit in given canvas proportions
  checkBrokenFreq();
  
  if (fullScreen == false) { //If full screen mode, hides top margin
    // Print Title and Help
    printTitle();
    printHelp1();
  }
  
  translate(0,-margBottom);
  
  if (!fullScreen) {
    // Checks image proportions to be displayed, makes sure they fit in window
    imgW = int((height-margTop)*(float)scanImage[imageIndex].width/scanImage[imageIndex].height);
    imgH = (height-margTop);
    aspect = imgH/(float)scanImage[imageIndex].height;
  } else {
    // Checks image proportions to be displayed, makes sure they fit in window
    imgW = int((height-margLeft-margBottom)*(float)scanImage[imageIndex].width/scanImage[imageIndex].height);
    imgH = (height-margBottom-margLeft);
    aspect = imgH/(float)scanImage[imageIndex].height;
  }
  
  // Creates Distorted Camera Image offscreen  
  scanGraphic = createGraphics(imgW, imgH);
  scanGraphic.beginDraw();
  scanGraphic.image(scanImage[imageIndex], 0, 0, imgW, imgH);
  scanGraphic.endDraw();
  
  //Draws cropped image of Scan Area
  translate(margLeft+margInputs, 0);
  image(scanGraphic.get(), 0, margTop);
  translate(-(margLeft+margInputs), 0);
  
  // Draws Frequency table and Analysis
  if (freq && brokenFreq == false) {
    translate(width-freqWidth, margTop);
    drawFreqLegend();
    drawFreqCloud();
    drawFreqAnal();
    translate(-(width-freqWidth), -margTop);
  }
  
  //Draws scanGrid visualization, overlaid on webcam image
  translate(margLeft+margInputs, margTop); 
  drawColorGrid(cellOutline);
  drawColorCursors(gridIndex); // Draw cursor boxes around hold and temp quads
  dragBox(); //If Mouse is being clicked and dragged, shows drag box
  translate(-(margLeft+margInputs), -margTop);
  
  //Labels Current Grid Number
  translate(imgW+margLeft+margInputs, margTop);
  printGridTitle(gridIndex);
  translate(-(imgW+margLeft+margInputs), -(margTop));
  
  // Draws scanGrid Reference Colors
  translate(imgW+margLeft+margInputs, margTop+marg);
  drawReferenceColors();
  translate(-(imgW+margLeft+margInputs), -(margTop+marg));
  
  // Draws status of IDs supported, gridLocked status, and UMI client state
  translate(imgW+margLeft+margInputs, margTop+imgH);
  drawVRMode();
  drawDDPMode();
  drawIDMode(scanGrid[numGAforLoop[imageIndex] + gridIndex].IDMode);
  drawGridLock();
  drawUMIStatus();
  translate(-(imgW+margLeft+margInputs), -(margTop+imgH));
  
  translate(0, margBottom);
  
  //Checks if scanGrid is being hovered over
  hoverTest();
}

public void printTitle() {
  fill(#CCCCCC);
  
  translate(margLeft, 0);
  textSize(2*tsize);
  text(version, 0, 2.5*tsize);
  textSize(tsize);
  text("Ira Winder, MIT Media Lab", 0, 4*tsize);
  text("Applet for gridded, programmable color detection", 0, 7*tsize);
  
  text("Press '`' to connect/disconnect UMI Server", 0, 9.5*tsize);
  text("Press 'g' to lock/unlock grid editing", 0, 11*tsize);
  text("Press 'r' to change ID support (0, 8, 16, or 24 IDs)", 0, 12.5*tsize);
  translate(-margLeft, 0);
}

public void printHelp1() {
  translate(400, 0);
  text("KeyCodes:", 0, 1.5*tsize);
  text("Press '0' to select camera polygon by clicking corners", 0, 3.5*tsize);
  text("Press 'f' to hide/show HSBRGB frequencies (improves framerate)", 0, 5*tsize);
  text("Press 'm' to switch between real/false color modes", 0, 6.5*tsize);
  text("Press 'i' to hide/show color grid", 0, 8*tsize);
  text("Press 'z' for zoomed display", 0, 9.5*tsize);
  text("Press 'o' to hide/show grid cell containers", 0, 11*tsize);
  text("Press 't' to change selected scanGrid", 0, 12.5*tsize);
  translate(400, 0);
  text("Press 'c/l' to save/load corner locations", 0, 2*tsize);
  text("Press '-/=' to save/load reference colors", 0, 8*tsize);
  text("Press 'b/v' to select/set reference color", 0, 6.5*tsize);
  text("Press 'a/s/d/w' or click to move reference color cursor", 0, 3.5*tsize);
  text("Press SPACEBAR to temporarily hold a cursor's HSBRGB values for comparison", 0, 5*tsize);
  text("Press 'u' to pause/unpause color detection", 0, 9.5*tsize);
  text("Press 'q/e' to save/load grid settings", 0, 11*tsize);
  text("Press 'y' to change selected plane of distortion", 0, 12.5*tsize);
  translate(-800, 0);
}

public void printHelp2() {
  translate(margLeft, 150);
  text("Corner Calibration KeyCodes:", 0, 1.5*tsize);
  text("Press '[' to select TOP LEFT corner", 0, 3.5*tsize);
  text("Press ']' to select TOP RIGHT corner", 0, 5*tsize);
  text("Press ''' to select BOTTOM RIGHT corner", 0, 6.5*tsize);
  text("Press ';' to select BOTTOM LEFT corner", 0, 8*tsize);
  text("Press arrow keys or click to set corner position", 0, 9.5*tsize);
  text("Press 'l/c' to load/save corner positions", 0, 11*tsize);
  translate(-margLeft, -150);
}

void drawCamCalibration() {
  // Print WebCam and Corner Pins
  image(camImage, 0, 0); 
  noStroke();
  fill(#FFFF00);
  ellipse(cornerSettings[imageIndex][cornerIndex].x, cornerSettings[imageIndex][cornerIndex].y, 8, 8); //Draw selected corner
  fill(#F000FF);
  for (int i=0; i<4; i++) { //Draw each corner in memory and the lines that connect them
    ellipse(cornerSettings[imageIndex][i].x, cornerSettings[imageIndex][i].y, 4, 4);
    stroke(#F000FF);
    if (i < 3) {
      line(cornerSettings[imageIndex][i].x, cornerSettings[imageIndex][i].y, cornerSettings[imageIndex][i+1].x, cornerSettings[imageIndex][i+1].y);
    } else {
      line(cornerSettings[imageIndex][i].x, cornerSettings[imageIndex][i].y, cornerSettings[imageIndex][0].x, cornerSettings[imageIndex][0].y);
    }
  }
  // Label each corner
  text("Upper Left", cornerSettings[imageIndex][1].x + 10, cornerSettings[imageIndex][1].y + 14);
  text("Upper Right", cornerSettings[imageIndex][0].x + 10, cornerSettings[imageIndex][0].y + 14);
  text("Lower Right", cornerSettings[imageIndex][3].x + 10, cornerSettings[imageIndex][3].y + 14);
  text("Lower Left", cornerSettings[imageIndex][2].x + 10, cornerSettings[imageIndex][2].y + 14);
  fill(#FFFFFF);
  stroke(#FFFFFF);
}

public void drawFreqLegend() {
  String legend[] = {"H", "S", "B", "R", "G", "B"};
  stroke(#CCCCCC, 100);
  textSize(50);
  fill(#CCCCCC, 100);
  textAlign(CENTER);
  for (int m=0; m<6; m++) {
    text(legend[m], (freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0, 50);
  }
  textSize(10);
  textAlign(LEFT);
  for (int m=0; m<52; m++) { //Draws horizontal axes
    if (m%10==0) {
      stroke(#CCCCCC, 100);
      strokeWeight(2);
      line(0,marg + m*5*((imgH-marg)/(float)255),freqWidth-marg,marg + m*5*((imgH - marg)/(float)255));
      stroke(#FFFFFF, 255);
      text(m*5, 5, marg + m*5*((imgH - marg)/(float)255)-4);
    } else {
      stroke(#CCCCCC, 50);
      strokeWeight(1);
      line(0,marg + m*5*((imgH-marg)/(float)255),freqWidth-marg,marg + m*5*((imgH - marg)/(float)255));
    }
  }
  stroke(#CCCCCC, 50);
  strokeWeight(1);
}

void drawFreqCloud() {
  //Draws frequency clouds of HSBRGB data for all quads
  for(int i=0; i<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU(); i++) {
    for( int j=0; j<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV(); j++) {            
      for (int k=0; k<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW(); k+=scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW()) { //Only shows k and l = 0
        for (int l=0; l<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX(); l+=scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX()) {        
          for (int m=0; m<6; m++) {
            fill(#999999);
            ellipse((freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0+random(-20, 20), marg + scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(i,j,k,l,m)*((imgH - marg)/(float)255),2,2);
          }
        }
      }
    }
  }        
}

void drawFreqAnal() {
  // Draw HSBRGB status and difference information for "Temp" and "Hold" Quad cursors
  sumdif = 0;
  for (int m=0; m<6; m++) {
    sumdif += sq(floor(abs(scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(tempu,tempv,tempw,tempx,m)-scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(holdu,holdv,holdw,holdx,m))));
    
    stroke(#FF0000, 100);
    fill(#FFFFFF, 255);
    strokeWeight(40);
    textAlign(CENTER);
    textSize(15);
    line((freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0, marg + scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(holdu,holdv,holdw,holdx,m)*((imgH - marg)/(float)255),
         (freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0, marg +scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(tempu,tempv,tempw,tempx,m)*((imgH - marg)/(float)255));
    text(floor(abs(scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(tempu,tempv,tempw,tempx,m)-scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(holdu,holdv,holdw,holdx,m))), 
         (freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0,marg + (scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(holdu,holdv,holdw,holdx,m)+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(tempu,tempv,tempw,tempx,m))*((imgH - marg)/(float)255)/2);
    noStroke();    
    fill(#00FFFF, 200);
    ellipse((freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0,marg + scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(holdu,holdv,holdw,holdx,m)*((imgH - marg)/(float)255), 40, 40);
    fill(#00FF00, 200);
    ellipse((freqWidth-marg)/7.0+m*(freqWidth-marg)/7.0,marg + scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadValue(tempu,tempv,tempw,tempx,m)*((imgH - marg)/(float)255), 40, 40); 
  }
  
  // Draw Sum Squares Bar
  stroke(#FF0000, 255);
  strokeWeight(4);
  textAlign(CENTER);
  translate(freqWidth-marg/2, marg);
  line(0, 0,
       0, (1/2.0)*sumdif*((imgH - marg)/(float)sq(255)));
  if ((1/2.0)*sumdif*((imgH - marg)/(float)sq(255)) < imgH - marg ) {   
    text(sumdif, 
         0, (1/2.0)*sumdif*((imgH - marg)/(float)sq(255))+15);
    textSize(10);
    text("Sum", 
         0, (1/2.0)*sumdif*((imgH - marg)/(float)sq(255))+30);
    text("Squares", 
         0, (1/2.0)*sumdif*((imgH - marg)/(float)sq(255))+45);
  } else {
    text(sumdif, 
         0, imgH - marg-40+15);
    textSize(10);
    text("Sum", 
         0, imgH - marg-40+30);
    text("Squares", 
         0, imgH - marg-40+45);
  }
  noStroke();
  translate(-(freqWidth-marg/2), -marg); 
}

void checkBrokenFreq() {
  //Determines if frequency table will fit in given canvas proportions
  if (height - margTop + margRight + margInputs + freqWidth > width) {
    brokenFreq = true;
  } else {
    brokenFreq = false;
  }
}

void drawColorGrid(boolean cellOutline) {
  for(int a=0; a<numGridAreas[imageIndex]; a++) {
    translate(aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[0], aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[1]);
    for(int i=0; i<scanGrid[numGAforLoop[imageIndex] + a].getGridU(); i++) {
      for( int j=0; j<scanGrid[numGAforLoop[imageIndex] + a].getGridV(); j++) {        
        for (int k=0; k<scanGrid[numGAforLoop[imageIndex] + a].getGridW(); k++) {
          for (int l=0; l<scanGrid[numGAforLoop[imageIndex] + a].getGridX(); l++) {
            
            stroke(#CCCCCC, 50);
            strokeWeight(1);
            if (img) { 
              noFill();
            } else {
              if (colorMode == 0) {
                colorMode(HSB);
                fill(color(scanGrid[numGAforLoop[imageIndex] + a].getHue(scanGrid[numGAforLoop[imageIndex] + a].getQuadCode(i, j, k, l)), 255, 255));
              } else {
                fill(color(scanGrid[numGAforLoop[imageIndex] + a].getCodeValue(scanGrid[numGAforLoop[imageIndex] + a].getQuadCode(i, j, k, l), 3),scanGrid[numGAforLoop[imageIndex] + a].getCodeValue(scanGrid[numGAforLoop[imageIndex] + a].getQuadCode(i, j, k, l), 4),scanGrid[numGAforLoop[imageIndex] + a].getCodeValue(scanGrid[numGAforLoop[imageIndex] + a].getQuadCode(i, j, k, l), 5)));
              }
            }
            drawQuad(a,i,j,k,l);
            colorMode(RGB);
            
            
          }
        } // End Drawing of Cell Quads   
        
        if (cellOutline) {
          // Draws Outlines of Cells
          noFill();
          strokeWeight(2);
          stroke(#FFFFFF);
          drawCell(a,i,j);   
        } //End Drawing of Cell Outlines
      }
    } //End drawing of Cell
    translate(-aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[0], -aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[1]);
  } //End Drawing of Grid
}

void drawColorCursors(int a) {
  translate(aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[0], aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[1]);
  // Draw cursor boxes around hold and temp quads
  noFill();
  strokeWeight(2);
  stroke(#00FFFF);
  //translate(margLeft,margTop);
  drawQuad(gridIndex,holdu,holdv,holdw,holdx);
  stroke(#00FF00);
  drawQuad(gridIndex,tempu,tempv,tempw,tempx);
  //translate(-margLeft,-margTop);
  translate(-aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[0], -aspect*scanGrid[numGAforLoop[imageIndex] + a].getToggle()[1]);
}

void drawQuad(int a, int i, int j, int k, int l) {
  rect(aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[2])/scanGrid[numGAforLoop[imageIndex] + a].getGridWidth())  * (scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + i*(scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + scanGrid[numGAforLoop[imageIndex] + a].getCellWidth())  + k*(scanGrid[numGAforLoop[imageIndex] + a].getQuadGap() + scanGrid[numGAforLoop[imageIndex] + a].getQuadWidth())), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[3])/scanGrid[numGAforLoop[imageIndex] + a].getGridHeight()) * (scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + j*(scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + scanGrid[numGAforLoop[imageIndex] + a].getCellHeight()) + l*(scanGrid[numGAforLoop[imageIndex] + a].getQuadGap() + scanGrid[numGAforLoop[imageIndex] + a].getQuadHeight())), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[2])/scanGrid[numGAforLoop[imageIndex] + a].getGridWidth())  * scanGrid[numGAforLoop[imageIndex] + a].getQuadWidth(), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[3])/scanGrid[numGAforLoop[imageIndex] + a].getGridHeight()) * scanGrid[numGAforLoop[imageIndex] + a].getQuadHeight());
}

void drawCell(int a, int i, int j) {
  rect(aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[2])/scanGrid[numGAforLoop[imageIndex] + a].getGridWidth())  * (scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + i*(scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + scanGrid[numGAforLoop[imageIndex] + a].getCellWidth())), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[3])/scanGrid[numGAforLoop[imageIndex] + a].getGridHeight()) * (scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + j*(scanGrid[numGAforLoop[imageIndex] + a].getCellGap() + scanGrid[numGAforLoop[imageIndex] + a].getCellHeight())), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[2])/scanGrid[numGAforLoop[imageIndex] + a].getGridWidth())  * scanGrid[numGAforLoop[imageIndex] + a].getCellWidth(), 
       aspect * ((float)(scanGrid[numGAforLoop[imageIndex] + a].getToggle()[3])/scanGrid[numGAforLoop[imageIndex] + a].getGridHeight()) * scanGrid[numGAforLoop[imageIndex] + a].getCellHeight());
}

void drawReferenceColors() {
  // Draws scanGrid Reference Colors
  stroke(#999999);
  strokeWeight(1);
  for (int i=0; i<scanGrid[numGAforLoop[imageIndex] + gridIndex].getBaseNum(); i++) {
    fill(color(scanGrid[numGAforLoop[imageIndex] + gridIndex].getCodeValue(i, 3),scanGrid[numGAforLoop[imageIndex] + gridIndex].getCodeValue(i, 4),scanGrid[numGAforLoop[imageIndex] + gridIndex].getCodeValue(i, 5)));
    rect(20, i*24, 12, 12);
    colorMode(HSB);
    fill(color(scanGrid[numGAforLoop[imageIndex] + gridIndex].getHue(i), 255, 255));
    textSize(12);
    textAlign(LEFT);
    text("Color " + (i) + " (" + colorDef[i] + ")", 24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, i*24+10);
    colorMode(RGB);
  }
  
  noFill();
  strokeWeight(2);
  stroke(#FFFF00);
  rect(20, baseindex*24, 12, 12);
}

void drawUMIStatus() {
  fill(#FFFFFF);
  textAlign(LEFT);
  text("UMI Connection = " + useUMI + ". If true, establishes server connection to UMI Client.",
  24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, -4.5*tsize);
}

void drawGridLock() {
  fill(#FFFFFF);
  textAlign(LEFT);
  text("Grid editing = " + allowDrag + ". If true, clicking and dragging to resize grid is enabled.",
  24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, -3.0*tsize);
}

void drawIDMode(int IDMode) {
  fill(#FFFFFF);
  textAlign(LEFT);
  text("Grid " + (imageIndex+1) + "." + (gridIndex+1) + " may only use Colors 0-" + (1+IDMode) + " to export up to " + (8*IDMode) + " unique IDs", 
       24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, -1.5*tsize);
  text("for 4-bit(2x2) tags only.  1-bit tags unaffected", 
       24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, 0);
}

void drawVRMode() {
  fill(#FFFFFF);
  textAlign(LEFT);
  text("Export to UDPServer (" + UDPServer_IP + " at port " +UDPServer_PORT + "): " + UDPtoServer + " [Press 'SHIFT+V' to toggle on/off]", 
       24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, -6.0*tsize);
}

/**
* DDP connection mode (Y.S 01/12/16)
*/
void drawDDPMode(){
  fill(#FFFFFF);
  textAlign(LEFT);
  text("Export to Web App ("+DDPAddress + " at port " +DDPPort + "): "+enableDDP + " [Press 'SHIFT+N' to toggle on/off]",
    24+scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadWidth()+10, -7.5*tsize);
  
}

void printGridTitle(int i) {
  //Labels Current Grid Number
  fill(#FFFFFF);
  textSize(2*tsize);
  textAlign(LEFT);
  text("Grid " + (imageIndex+1) + "." + (i+1), 20, 2*tsize);
  textSize(tsize);
}

void nudgeCorner(int i, int x, int y) {
  if (x == 1) {
    //if (cornerSettings[imageIndex][i].x < camWidth) {
      cornerSettings[imageIndex][i].x += x;
      println("corner " + cornerIndex + " += " + x);
    //}
  } else if (x == -1) {
    //if (cornerSettings[imageIndex][i].x > 0) {
      cornerSettings[imageIndex][i].x += x;
      println("corner " + cornerIndex + " += " + x);
    //}
  } else if (y == 1) {
    //if (cornerSettings[imageIndex][i].y < camHeight) {
      cornerSettings[imageIndex][i].y += y;
      println("corner " + cornerIndex + " += " + y);
    //}
  } else if (y == -1) {
    //if (cornerSettings[imageIndex][i].y > 0) {
      cornerSettings[imageIndex][i].y += y;
      println("corner " + cornerIndex + " += " + y);
    //}
  }
}

void nudgeBase(int dBase) {
  if (scanGrid[numGAforLoop[imageIndex] + gridIndex].getBaseNum() + dBase > 0 && scanGrid[numGAforLoop[imageIndex] + gridIndex].getBaseNum() + dBase <= scanGrid[numGAforLoop[imageIndex] + gridIndex].maxBase) {
    scanGrid[numGAforLoop[imageIndex] + gridIndex].updateBase(scanGrid[numGAforLoop[imageIndex] + gridIndex].getBaseNum() + dBase);
  }
}

void nudgeUV(int du, int dv) {
  if (scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU() + du > 0 && scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU() + du < scanGrid[numGAforLoop[imageIndex] + gridIndex].maxU &&
      scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV() + dv > 0 && scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV() + dv < scanGrid[numGAforLoop[imageIndex] + gridIndex].maxV) {
    
        scanGrid[numGAforLoop[imageIndex] + gridIndex].updateUV( scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU() + du, 
                                                             scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV() + dv);
  }
}

void nudgeWX(int dw, int dx) {
  if (scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW() + dw > 0 && scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW() + dw < scanGrid[numGAforLoop[imageIndex] + gridIndex].maxW &&
      scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX() + dx > 0 && scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX() + dx < scanGrid[numGAforLoop[imageIndex] + gridIndex].maxX) {
    
        scanGrid[numGAforLoop[imageIndex] + gridIndex].updateWX( scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW() + dw, 
                                                             scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX() + dx);
  }
}

void checkTemps() {
  // Makes sure that cursor values are not out of bounds
  if (tempu > scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()-1) {
      tempu = scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()-1;
  } else if (tempu < 0) {
    tempu = 0;
  }
  if (tempv > scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()-1) {
      tempv = scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()-1;
  } else if (tempv < 0) {
    tempv = 0;
  }
  if (holdu > scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()-1) {
      holdu = scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()-1;
  } else if (holdu < 0) {
    holdu = 0;
  }
  if (holdv > scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()-1) {
      holdv = scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()-1;
  } else if (holdv < 0) {
    holdv = 0;
  }
}

void keyPressed() {
  switch(key) {
    case ']': 
      cornerIndex = 0;
      println(cornerIndex + " Upper Right");
      break;
    case '[': 
      cornerIndex = 1;
      println(cornerIndex + " Upper Left");
      break;
    case ';': 
      cornerIndex = 2;
      println(cornerIndex + " Lower Left");
      break;
    case '\'': 
      cornerIndex = 3;
      println(cornerIndex + " Lower Right");
      break;
    case 'c': 
      println("c");
      saveCorners();
      break;
    case 'l': 
      println("l");
      loadCorners();
      break;
    case 'i':
      if (img) {
        img=false;
      } else {
        img=true;
      }
      break;
    case 'f':
      if (freq) {
        freq=false;
      } else {
        freq=true;
      }
      break;
    case '-':
      saveColorSettings();
      break;
    case '=':
      loadColorSettings();
      break;
    case 'w':
      if (tempx>0) {
        tempx--;
      } else if (tempx==0 && tempv>0) {
        tempx=scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX()-1;
        tempv--;
      }
      break;
    case 'd':
      if (tempw<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW()-1) {
        tempw++;
      } else if (tempw==scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW()-1 && tempu<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridU()-1) {
        tempw=0;
        tempu++;
      }
      break;
    case 'a':
      if (tempw>0) {
        tempw--;
      } else if (tempw==0 && tempu>0) {
        tempw=scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridW()-1;
        tempu--;
      }
      break;
    case 'r':
      scanGrid[numGAforLoop[imageIndex] + gridIndex].nextIDMode();
      break;
    case 's':
      if (tempx<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX()-1) {
        tempx++;
      } else if (tempx==scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridX()-1 && tempv<scanGrid[numGAforLoop[imageIndex] + gridIndex].getGridV()-1) {
        tempx=0;
        tempv++;
      }
      break;
    case ' ':
      holdu = tempu;
      holdv = tempv;
      holdw = tempw;
      holdx = tempx;
      break;
    case 'b':
      if (baseindex < scanGrid[numGAforLoop[imageIndex] + gridIndex].getBaseNum()-1) {
        baseindex++;
      } else {
        baseindex=0;
      }
      break;
    case 'v':
      scanGrid[numGAforLoop[imageIndex] + gridIndex].setBaseValue(baseindex, tempu, tempv, tempw, tempx);
      break;
    case '0':
      if (showCam) {
        showCam=false;
      } else {
        showCam=true;
      }
    break;
    case 'o':
      if (cellOutline) {
        cellOutline=false;
      } else {
        cellOutline=true;
      }
    break;
    case 'z':
      if (fullScreen) {
        fullScreen=false;
        margTop = 200;
      } else {
        fullScreen=true;
        margTop = 2*margBottom;
      }
      break;
    case 't':
      if (gridIndex < numGridAreas[imageIndex]-1) {
        gridIndex++;
      } else {
        gridIndex = 0;
      }
      println(gridIndex);
      checkTemps();
      break;
    case 'y':
      if (imageIndex < numImages-1) {
        imageIndex++;
        gridIndex = 0;
      } else {
        imageIndex = 0;
        gridIndex = 0;
      }
      checkTemps();
      break;
    case 'q':
      scanDelay = delay;
      saveGridSettings();
      saveGridLocations();
      break;
    case 'e':
      scanDelay = delay;
      loadGridSettings();
      loadGridLocations();
      break;
    case 'u':
      if (!img) {
        if (update) {
          update=false;
        } else {
          update=true;
        }
      }
      break;
    case 'm':
      if (!img) {
        if (colorMode == 0) {
          colorMode = 1;
        } else {
          colorMode = 0;
        }
      }
      break;
    case 'U':
      scanDelay = delay;
      nudgeUV(0,1);
      break;
    case 'M':
      scanDelay = delay;
      nudgeUV(0,-1);
      break;
    case 'H':
      scanDelay = delay;
      nudgeUV(-1,0);
      break;
    case 'K':
      scanDelay = delay;
      nudgeUV(1,0);
      break;
    case '<':
      scanDelay = delay;
      nudgeBase(-1);
      break;
    case '>':
      scanDelay = delay;
      nudgeBase(1);
      break;
    case 'g':
      if(allowDrag) {
        allowDrag = false;
      } else {
        allowDrag = true;
      }
      break;
    case '`':
      if(useUMI) {
        useUMI = false;
      } else {
        useUMI = true;
        initServer();
      }
      break;
    case '1':
      if (writer != null) { writer.println("resimulate"); }
      break;
    case '2':
      if (writer != null) { writer.println("save"); }
      break;
    case '3':
      if (writer != null) { writer.println("displaymode energy"); }
      break;
    case '4':
      if (writer != null) { writer.println("displaymode walkability"); }
      break;
    case '5':
      if (writer != null) { writer.println("displaymode daylighting"); }
      break;
    case '6':
      if(useUMI) {
        initServer();
      }
      break;
    case 'V':
      if (UDPtoServer) {
        UDPtoServer = false;
      } else {
        UDPtoServer = true;
      }
      break;
    case 'N':
      if (!enableDDP) {
        initDDP();
      }
      enableDDP = !enableDDP;
      break;
  }
  
  if (key == CODED) { 
    if (keyCode == LEFT) {
      nudgeCorner(cornerIndex, -1, 0);
    }  
    if (keyCode == RIGHT) {
      nudgeCorner(cornerIndex, 1, 0);
    }  
    if (keyCode == DOWN) {
      nudgeCorner(cornerIndex, 0, 1);
    }  
    if (keyCode == UP) {
      nudgeCorner(cornerIndex, 0, -1);
    }
  }
}

void clickCorner() {
  cornerSettings[imageIndex][cornerIndex].x = mouseX - margCam;
  cornerSettings[imageIndex][cornerIndex].y = mouseY;
  println("X = " + (mouseX-margCam));
  println("Y = " + mouseY);
}

public int MouseToX(int x) {
  return int((x - margLeft - margInputs)*((float)scanImage[imageIndex].width/imgW));
}

public int MouseToY(int y) {
  return int((y - margTop + margBottom)*((float)scanImage[imageIndex].height/imgH));
}

public int XToMouse(int X) {
  return int(X*imgW/(float)scanImage[imageIndex].width) + margLeft + margInputs;
}

public int YToMouse(int Y) {
  return int(Y*imgH/(float)scanImage[imageIndex].height) + margTop - margBottom;
}

void dragBox() {
  
  //If Mouse is being clicked and dragged, shows drag box
  if (dragged) {
    rect(aspect * xClick, aspect * yClick, aspect * xDrag, aspect * yDrag);
  }
}

void hoverTest() {
  // Test if the cursor is over the box 
  if (MouseToX(mouseX) > gridLocations.getInt(imageIndex, 0 + gridIndex*4) && MouseToX(mouseX) < gridLocations.getInt(imageIndex, 0 + gridIndex*4) + gridLocations.getInt(imageIndex, 2 + gridIndex*4) && 
      MouseToY(mouseY) > gridLocations.getInt(imageIndex, 1 + gridIndex*4) && MouseToY(mouseY) < gridLocations.getInt(imageIndex, 1 + gridIndex*4) + gridLocations.getInt(imageIndex, 3 + gridIndex*4)) {
    hover = true;
  } else {
    hover = false;
  }
}

void mouseClicked() {
  if (showCam) {
    clickCorner();
  }
}

void mousePressed() {
  if(allowDrag) {
    if(hover) { // If inside scanGrid area is selected, drags grid
      locked = true; 
      img = true;
      xOffset = mouseX - XToMouse(gridLocations.getInt(imageIndex, 0 + gridIndex*4)); 
      yOffset = mouseY - YToMouse(gridLocations.getInt(imageIndex, 1 + gridIndex*4));
    } else { // If outside of scanGrid is selected, resets size and location of grid according to click and drag
      dragged = true;
      xClick = MouseToX(mouseX);
      yClick = MouseToY(mouseY);
    }
  }
}

void mouseDragged() {
  if(allowDrag) {
    if(locked) {
      gridLocations.setInt(imageIndex, 0 + gridIndex*4, MouseToX(mouseX - xOffset));
      gridLocations.setInt(imageIndex, 1 + gridIndex*4, MouseToY(mouseY - yOffset));
    } else {  
      xDrag = MouseToX(mouseX) - xClick;
      yDrag = MouseToY(mouseY) - yClick; 
      if (xDrag <= 0) {
        xDrag = 1;
      }
      if (yDrag <= 0) {
        yDrag = 1;
      }  
      gridLocations.setInt(imageIndex, 0 + gridIndex*4, xClick); 
      gridLocations.setInt(imageIndex, 1 + gridIndex*4, yClick);
      gridLocations.setInt(imageIndex, 2 + gridIndex*4, xDrag); 
      gridLocations.setInt(imageIndex, 3 + gridIndex*4, yDrag);
    } 
    scanGrid[numGAforLoop[imageIndex] + gridIndex].updatePosition(getLocation(imageIndex, gridIndex));
  }
}

void mouseReleased() {
  if(allowDrag) {
    locked = false;
    dragged = false;
    img = false;
    scanGrid[numGAforLoop[imageIndex] + gridIndex].updatePosition(getLocation(imageIndex, gridIndex));
  }
}


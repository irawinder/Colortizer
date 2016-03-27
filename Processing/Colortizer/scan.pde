// Given a pixel image, this set of methods will allow a trapazoid defined by 
// 4 points within the image to be distorted into a its own square pixel images
//
// by Ira Winder, MIT Media Lab, April 2014
//
// REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:


//Library for webcam Capture
import processing.video.*;
Capture cam; // Capture object to hold webcam feed

import gab.opencv.*;
OpenCV opencv;  // Temporary image holder for use in "scanWarp()" method

int counter = 0; //Counts how many times draw() is run

// Raw WebCam Attributes
int camWidth;
int camHeight;
PImage camImage;

//Static Test Image
PImage defaultImage;
// Warped WebCam Attributes
PImage[] scanImage; // Image object to hold undistorted images as input for scanGrid

// Grids of color analysis
ScanGrid[] scanGrid;

int numImages; // Number of Warped Images created
int numGrids; // Number of "ScanGrids" created
int[] numGAforLoop;
int gridIndex = 0; //Selection of scanGrid
int cornerIndex = 0; //Selection of corner point (1 of 4)

// Do not change these values without editing TSV files.
int imgMax = 10;
int gridMax = 20;

// Tables for loadings and saving Settings
Table cornerSettingsTSV;

Table gridSettings;
int gS_numCol = 10; //Number of columns per grid in gridSettings.tsv

Table colorSettings;
Table gridLocations;
Table numGridAreasTSV;
Table exportOffsetsTSV;

int[][] exportOffsets = new int[imgMax*gridMax][2];
int[] location;

PVector[][] cornerSettings;
PVector[]   DEFAULTCORNERS;

boolean update = true;

void setupScan() {
  colorSettings = loadTable("colorSettings.tsv");
  gridSettings = loadTable("gridSettings.tsv");
  gridLocations = loadTable("gridLocations.tsv");
  numGridAreasTSV = loadTable("numGridAreas.tsv");
  exportOffsetsTSV = loadTable("exportOffsets.tsv");
  
  numGridAreas = new int[numGridAreasTSV.getColumnCount()];
  for (int i=0; i<numGridAreas.length; i++) {
    if (!enableToggles) {
      numGridAreas[i] = 1;
    } else {
      numGridAreas[i] = numGridAreasTSV.getInt(0, i);
    }
  }
  
  for(int i=0; i<exportOffsets.length; i++) {
    exportOffsets[i][0] = exportOffsetsTSV.getInt(i, 0);
    exportOffsets[i][1] = exportOffsetsTSV.getInt(i, 1);
  }
  
  numImages = numGridAreas.length;
  numGAforLoop = new int[numGridAreas.length];
  numGrids = 0;
  
  for (int i=0; i<numGridAreas.length; i++) {
    numGrids += numGridAreas[i];
    if (i==0) {
      numGAforLoop[i] = 0;
    } else {
      numGAforLoop[i] = numGAforLoop[i-1] + numGridAreas[i-1];
    }
  }
  
  //SCANNING: Initialize scanGrid objects and supporting parameters
  scanGrid = new ScanGrid[numGrids];
  
  //SCANNING: Decoder for scanGrid Objects
  initDecoders();
  
  //
  //    scanGrid[i] = new ScanGrid(U, V, UV-gapRatio, W, X, WX-gapRatio, W-pixelLength, X-pixelHeight, NumColors);
  //
  
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<numGridAreas[i]; j++) {   
      
      location = getLocation(i,j);
      
      scanGrid[numGAforLoop[i] + j]  = new ScanGrid(gridSettings.getInt( i, j*gS_numCol + 0),
                                                   gridSettings.getInt(  i, j*gS_numCol + 1),
                                                   gridSettings.getFloat(i, j*gS_numCol + 2),
                                                   gridSettings.getInt(  i, j*gS_numCol + 3),
                                                   gridSettings.getInt(  i, j*gS_numCol + 4),
                                                   gridSettings.getFloat(i, j*gS_numCol + 5),
                                                   gridSettings.getInt(  i, j*gS_numCol + 6),
                                                   gridSettings.getInt(  i, j*gS_numCol + 7),
                                                   gridSettings.getInt(  i, j*gS_numCol + 8),
                                                   gridSettings.getInt(  i, j*gS_numCol + 9),
                                                   colorSettings.getRow(i*gridMax + j),
                                                   location);
                                                   
    }
  }
  
  scanImage = new PImage[numImages];
  defaultImage = loadImage("test.jpg");
  
  initCamera();
  startUDP();
}

void initCamera() {
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + ": " + cameras[i]);
    }
    
    println("Number of Cameras: " + cameras.length);
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[camera]);
    cam.start();
  }
}

void runScan(int vizW, int vizH) {
  if (cam.available() == true && showDefaultImage == false) {
    
    cam.read();
    
    if (counter == 0) { // A unique instance for Capture input
      // These commands won't run in setup, since Processing is silly.
      // Instead, we run the commands during the first iteration of draw.
      initScan(cam);
      setupViz();
    } else if (counter == 1) {
      // Prepares "undistorted" versions of 4-sided polygons from webcam feed.
      updateScan(cam, vizW, vizH);
      drawViz();
    }
    
  } else if (showDefaultImage) { // A unique instance for PImage input
    
    if (counter == 0) {
      // These commands won't run in setup, since Processing is silly.
      // Instead, we run the commands during the first iteration of draw.
      initScan(defaultImage);
      setupViz();
    } else if (counter == 1) {
      // Prepares "undistorted" versions of 4-sided polygons from webcam feed.
      updateScan(defaultImage, vizW, vizH);
      drawViz();
    }
  }
}

void initScan(Capture cam) {
  println("Cam Width = " + cam.width);
   println("Cam Height = " + cam.height);
   initOpenCV(cam.width, cam.height);
   initCorners(camWidth, camHeight);
   counter++;
}

void initScan(PImage cam) {
  println("Cam Width = " + cam.width);
   println("Cam Height = " + cam.height);
   initOpenCV(cam.width, cam.height);
   initCorners(camWidth, camHeight);
   counter++;
}

void updateScan(Capture cam, int vizW, int vizH) {
  // Places regular Processing camera information into OpenCV image object
  loadOpenCV(cam);
  
  if (counter > 0) {
    // Creates Undistorted Grid
    for (int i=0; i<numImages; i++) {
      scanImage[i] = scanWarp(opencv, cornerSettings[i], vizW, vizH);
    }
    camImage = scanWarp(opencv, DEFAULTCORNERS, camWidth, camHeight);
  }
  
  // Creates scanGrid
  if (update) {
    for (int i=0; i<numImages; i++) {
      if (enableToggles) {
        for (int j=0; j<numGridAreas[i]; j++) { 
          scanGrid[numGAforLoop[i] + j].updatePatterns(scanImage[i]);
        }
      } else {
        // Only updates the first scan grid associated with each distorted image
        scanGrid[numGAforLoop[i]].updatePatterns(scanImage[i]);
      }
    }
  }
  
  //Decodes colors and send to local UDP
  updateDecoders();
  sendData();
  
  if(useUMI) {
    //Updates "UMIClient" Server for UMI Data
    updateServer();
  }
}

void updateScan(PImage cam, int vizW, int vizH) {
  // Places regular Processing camera information into OpenCV image object
  loadOpenCV(cam);
  
  if (counter > 0) {
    // Creates Undistorted Grid
    for (int i=0; i<numImages; i++) {
      scanImage[i] = scanWarp(opencv, cornerSettings[i], vizW, vizH);
    }
    camImage = scanWarp(opencv, DEFAULTCORNERS, camWidth, camHeight);
  }
  
  // Creates scanGrid
  if (update) {
    for (int i=0; i<numImages; i++) {
      for (int j=0; j<numGridAreas[i]; j++) { 
        scanGrid[numGAforLoop[i] + j].updatePatterns(scanImage[i]);
      }
    }
  }
  
  //Decodes colors and send to local UDP
  updateDecoders();
  sendData();
  
  if(useUMI) {
    //Updates "UMIClient" Server for UMI Data
    updateServer();
  }
}

void initOpenCV(int w, int h) {
  camWidth = w;
  camHeight = h;
  canonicalPoints[0] = new Point(0, 0);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(0, 0);
  canonicalPoints[3] = new Point(0, 0);
  opencv = new OpenCV(this, camWidth, camHeight);
  canonicalMarker = new MatOfPoint2f();
}

void loadOpenCV(Capture cam) {
  opencv.loadImage(cam);  // loads opencv object with camera feed
}

void loadOpenCV(PImage cam) {
  opencv.loadImage(cam);  // loads opencv object with camera feed with static or test PImage
}

void initCorners(int w, int h) {
  cornerSettings = new PVector[numImages][4];
  loadCorners();
  DEFAULTCORNERS = new PVector[4];
  DEFAULTCORNERS[0] = new PVector(w, 0);
  DEFAULTCORNERS[1] = new PVector(0, 0);
  DEFAULTCORNERS[2] = new PVector(0, h);
  DEFAULTCORNERS[3] = new PVector(w, h);
}

public int[] getLocation(int i, int j) {
  int[] loc = new int[4];
  for (int k=0; k<4; k++) {
    loc[k] = gridLocations.getInt(i, k + j*4);
  }
  return loc;
}

void loadCorners() {
  
  cornerSettingsTSV = loadTable("cornerSettings.tsv");
  
  for (int i=0; i<numImages; i++) {
    cornerSettings[i][0] = new PVector(cornerSettingsTSV.getInt(i,0), cornerSettingsTSV.getInt(i,1));
    cornerSettings[i][1] = new PVector(cornerSettingsTSV.getInt(i,2), cornerSettingsTSV.getInt(i,3));
    cornerSettings[i][2] = new PVector(cornerSettingsTSV.getInt(i,4), cornerSettingsTSV.getInt(i,5));
    cornerSettings[i][3] = new PVector(cornerSettingsTSV.getInt(i,6), cornerSettingsTSV.getInt(i,7));
  }
  
}

void saveCorners() {
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<cornerSettings[i].length; j++) {
      cornerSettingsTSV.setFloat(i, 2*j+0, cornerSettings[i][j].x);
      cornerSettingsTSV.setFloat(i, 2*j+1, cornerSettings[i][j].y);
    }
  }
  
  saveTable(cornerSettingsTSV, "cornerSettings.tsv");
  
}

void loadColorSettings() {
  colorSettings = loadTable("colorSettings.tsv");  
  scanGrid[gridIndex].updateColors(colorSettings.getRow(imageIndex*gridMax + gridIndex)); 
}
  
void saveColorSettings() {
  for (int i=0; i<scanGrid[gridIndex].getBaseNum(); i++) {
    for (int j=0; j<6; j++) {
      colorSettings.setFloat(imageIndex*gridMax + gridIndex, i*6 + j, scanGrid[gridIndex].getCodeValue(i,j));
    }
  }
  saveTable(colorSettings, "colorSettings.tsv");
}

void saveGridSettings() {
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<numGridAreas[i]; j++) {
      gridSettings.setInt(  i, j*gS_numCol + 0, scanGrid[numGAforLoop[i] + j].u);
      gridSettings.setInt(  i, j*gS_numCol + 1, scanGrid[numGAforLoop[i] + j].v);
      gridSettings.setFloat(i, j*gS_numCol + 2, scanGrid[numGAforLoop[i] + j].cellGapRatio);
      gridSettings.setInt(  i, j*gS_numCol + 3, scanGrid[numGAforLoop[i] + j].w);
      gridSettings.setInt(  i, j*gS_numCol + 4, scanGrid[numGAforLoop[i] + j].x);
      gridSettings.setFloat(i, j*gS_numCol + 5, scanGrid[numGAforLoop[i] + j].quadGapRatio);
      gridSettings.setInt(  i, j*gS_numCol + 6, scanGrid[numGAforLoop[i] + j].bitresW);
      gridSettings.setInt(  i, j*gS_numCol + 7, scanGrid[numGAforLoop[i] + j].bitresH);
      gridSettings.setInt(  i, j*gS_numCol + 8, scanGrid[numGAforLoop[i] + j].base);
      gridSettings.setInt(  i, j*gS_numCol + 9, scanGrid[numGAforLoop[i] + j].IDMode);
    }
  }
  saveTable(gridSettings, "gridSettings.tsv");
}

void loadGridSettings() {
  gridSettings = loadTable("gridSettings.tsv");
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<numGridAreas[i]; j++) {
      
      location = getLocation(i,j);
      
      scanGrid[numGAforLoop[i] + j].setupGrid(gridSettings.getInt(   i, j + 0),
                                               gridSettings.getInt(  i, j*gS_numCol + 1),
                                               gridSettings.getFloat(i, j*gS_numCol + 2),
                                               gridSettings.getInt(  i, j*gS_numCol + 3),
                                               gridSettings.getInt(  i, j*gS_numCol + 4),
                                               gridSettings.getFloat(i, j*gS_numCol + 5),
                                               gridSettings.getInt(  i, j*gS_numCol + 6),
                                               gridSettings.getInt(  i, j*gS_numCol + 7),
                                               gridSettings.getInt(  i, j*gS_numCol + 8),
                                               gridSettings.getInt(  i, j*gS_numCol + 9),
                                               location);
    }
  }
}

void saveGridLocations() {
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<numGridAreas[i]; j++) {
      gridLocations.setInt(i, j*4 + 0, scanGrid[numGAforLoop[i] + j].toggle[0]);
      gridLocations.setInt(i, j*4 + 1, scanGrid[numGAforLoop[i] + j].toggle[1]);
      gridLocations.setInt(i, j*4 + 2, scanGrid[numGAforLoop[i] + j].toggle[2]);
      gridLocations.setInt(i, j*4 + 3, scanGrid[numGAforLoop[i] + j].toggle[3]);
    }
  }
  saveTable(gridLocations, "gridLocations.tsv");
}

void loadGridLocations() {
  gridLocations = loadTable("gridLocations.tsv");
  for (int i=0; i<numImages; i++) {
    for (int j=0; j<numGridAreas[i]; j++) {
      scanGrid[numGAforLoop[i] + j].updatePosition(getLocation(i,j));
    }
  }
}

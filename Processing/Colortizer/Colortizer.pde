// Colortizer v4.2
String version = "Colortizer, V4.2";

// This software distorts webcam feeds into rectilinear matrices of color data.
// Run software to see key definitions
//
// By Ira Winder [jiw@mit.edu], CityScope Project, Changing Places Group, MIT Media Lab
// Copyright March, 2014

// REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:
// - March 3, 2015: Edited "scanExport" Tab to include addional column of information for rotation
// - March 3, 2015: Edited "scanGrid" Tab to have buffer condition to reduce noise of pattern reading
// - March 5, 2015: Added "UMIClient" Tab to allow TCP connection to Rhino server. Also added method calls in "Colortizer" tabl and "scan" tab
// - March 6, 2015: Coded Keys '1,' '2,' '3,' '4,' and '5' to correspond with Rhino/SDL functions in "UMIClient" tab
// - March 6, 2015: Coded '6' key to restart server connection to Rhino
// - March 14, 2015: Allowed functionalities in keys 1-6 to also be received via UDP (i.e. from Legotizer)
// - August 4, 2015: IW - Deprecated "UMIClient" Tab (formerly "gameClient" Tab)
// - August 4, 2015: IW - Add 8 More Tag Definitions, for a total of 24.
// - August 5, 2015: IW - Made Extra Tag Definitions easy to turn on/off (i.e. constrain to 8, 16 or 24 IDs only)
// - August 5, 2015: IW - Can save/load number of tag definitions to use, and displays state at bottom of screen
// - August 16, 2015:IW - Added UI for locking click-and-drag Grid edits and for turning UMI client on/off 
/*

SETUP:
Step 0: configure "int camera" to be associated with your camera and resolution of choice.  Use "Capture.list()" to explore cameras available in processing.
Step 1: Decide how many unique, distorted planes you need to scan.
Step 2: Decide how many uniqe grids of information needed for each plane
Step 3: Alter "int[] numGridAreas" accordingly
Step 4: Alter "scanExport" tab to relevant port on destination machine [i.e. udp.send( dataToSend, "localhost", 6152]
Step 5: Run application

*/

// Set this to false if you only need NxN piece grid information
// Set to true if you intend to make toggles and sliders
boolean enableToggles = false;

// Change this number to change which Area is scanned (i.e. 0, 1, or 2)
// Only used when you need feeds from multiple webcams, and each instance of colortizer is a different webcam
int imageIndex = 0; //Selection of scanImage to start

//Number of scan grids to be created on each warped image
// For example:
// {1,1,1,1} creates 4 scan grids, each on their own, separately programmed, distorted image.  The first grid on each distored image is reserved for tagDecoding.  
// {4} creates 4 scan grids, all sharing the same distorted image
// Max Spec: {20,20,20,20,20,20,20,20,20,20} <-- will probably run terribly, though
int[] numGridAreas; // loads from "numGridAreas.TSV"

// Position within array that describes available cameras
int camera = 0;

// Dimensions of surface being scanned
float vizRatio = float(16)/(16); //Must match measurements in reality, i.e. a table surface
int vizWidth = 400; //Resolution (in pixels)
int vizHeight = int(vizWidth/vizRatio);

int garbageCount = 0;

void setup() {
  size(vizWidth*2+500, vizHeight*2, P2D);
  setupScan(); //Loads all Scan Objects (coordinates, reference colors, and configuration) into memory with initial conditions and starts camera
  
  if (useUMI) {
    // Initiation of "UMIClient" Tab Items
    initServer();
  }
  
  if (enableDDP) {
    // Initialization of Yasushi's DDP Client
    initDDP();
  }
}

void draw() {
  background(0);
  runScan(vizWidth, vizHeight); //Updates and runs all scan objects
  //runViz();
  
  if (garbageCount > 300) {
    System.gc();
    garbageCount = 0;
  }
  garbageCount++;
  
  //println(frameRate);
  
}

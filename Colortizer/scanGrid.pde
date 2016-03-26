// Given an unDistored pixel image, this class subdivides the image into 
// flexibly defined subdivided cells that are then matched to a defined 
// reference color using a least squares method.  
//
// by Ira Winder, MIT Media Lab, April 2014
//
// For example, load a scanGrid with an undistorted PImage named 'image' by:
//   ScanGrid scanGrid = new ScanGrid(u, v, cellGapRatio, w, x, quadGapRatio, bitresW, bitresH, base, HSBRGB_TSV)
//   scanGrid.updatePatterns(image);
//
// Call values from the scanGrid by:
//   scanGrid.getQuadCode[u][v][w][x] <- returns an integer >=0 and <= base
//
// where:
// u = [int] number of horizontal cells
// v = [int] number of vertical cells
// cellGapRatio = [float] pixel gap between cells, as ratio of 'bitresW.'  Useful for avoiding camera noise at color junctions.
// w = [int] number of horizontal cell divisions (these are nested within cells)
// x = [int] number of vertical cell divisions (these are nested within cells)
// quadGapRatio = [float] pixel gap between cell subdivisions, as ratio of 'bitresW.' Useful for avoiding camera noise at color junctions
// bitresW = [int] smallest scan unit's pixel width (i.e. the width, in pixels, of a cell subdivision)
// bitresH = [int] smallest scan unit's pixel height (i.e. the height, in pixels, of a cell subdivision)
// base = [int] number of reference colors used to identify color
// HSBRGB_TSV = [TableRow] TableRow containing 6*maxBase columns of information that describe Hue,Saturation,Brightness,Red,Green,Blue values of potetnial reference colors 
//              (for instance, every 6th column is Blue, every 5th column is Green, etc)
//
//
// REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:
// - March 22, 2015.  Added feature that lets you send data stream only if an update to the color grid has occurred, 
// but doesn't appear to improve performance that much, and may result in bug where Legotizer doesn't update on startup.  Keep false unless experiencing servere performance issues and/or network is limited
// -
// -
// -

// Set 'sendOnUpdateOnly' to false if you want every frame of data to send via UDP, no matter what. 
// Set 'sendOnUpdateOnly' to true if you only want to send data when pattern appears to change
boolean sendOnUpdateOnly = false;
boolean updateReceived;

// Buffer reduces detection noise, but may also reduce performance
boolean hasBuffer = true;
int buffer = 2; //amount of frames to read color before confirming data to be passed on. prevents 'blips'

public class ScanGrid {
  
  protected int u, v, w, x;
  protected int base;
  protected int cellGap, quadGap;
  protected float cellGapRatio, quadGapRatio;
  protected int bitresW, bitresH;
  protected int[] toggle;
  protected PGraphics grid;
  protected PImage resized;
  
  private int gridWidth, gridHeight;
  private int cellWidth, cellHeight;
  private int quadWidth, quadHeight;
  private float[][][][][] quadValue; // Hue, Sat, Bri, Red, Green, Blue of each quadrant
  private int[][][][] quadCode, passCode, tempCode, bufferTime; // Code associated with color values of each quadrant
  private int numcolors = 6; // for 6 color parameters (H,S,B,R,G,B)
  private int maxU = 100;
  private int maxV = 100;
  private int maxW = 10;
  private int maxX = 10;
  private int maxBase = 20; // If this increases, manually add more rows to "colorSettings.tsv" file
  private float[] hue; // Array of hues distributed evenly across color spectrum
  
  // For 2x2 tags, IDMode specifies number of colors allowed to be used as a corner definition piece.
  // Each color allows for 8 additional ID tags, but may reduce reliability of detection.  (IDMode = 1 allows 8  IDS; IDMode = 2 allows 16  IDS; IDMode = 3 allows 24  IDS)
  private int IDMode = 2; // Default to two colors (i.e. red and yellow)
  private int maxIDMode = 3;
  
  private float[][] HSBRGB;
  private TableRow HSBRGB_TSV;
  
  private float[] dev; // helper variable that holds sum square value
  
  private int local;  // table index for reading every pixel in an image

  public ScanGrid(int u, int v, float cellGapRatio, int w, int x, float quadGapRatio, int bitresW, int bitresH, int base, int IDMode, TableRow HSBRGB_TSV, int[] toggle) {
    
    this.HSBRGB_TSV = HSBRGB_TSV;
    updateColors(HSBRGB_TSV);
    presetGrid(); 
    
    setupGrid(u, v , cellGapRatio, w, x, quadGapRatio, bitresW, bitresH, base, IDMode, toggle);
  }
  
  public PImage getGridImage() {
    return resized;
  }
  
  public int getGridU() {
    return u;
  }
  
  public int getGridV() {
    return v;
  }
  
  public int getGridW() {
    return w;
  }
  
  public int getGridX() {
    return x;
  }
  
  public int getBitResW() {
    return bitresW;
  }
  
  public int getBitResH() {
    return bitresH;
  }
  
  public float getCellGap() {
    return cellGap;
  }
  
  public float getQuadGap() {
    return quadGap;
  }
  
  public int getCellWidth() {
    return cellWidth;
  }
  
  public int getCellHeight() {
    return cellHeight;
  }
  
  public int getGridWidth() {
    return gridWidth;
  }
  
  public int getGridHeight() {
    return gridHeight;
  }
  
  public int getQuadWidth() {
    return quadWidth;
  }
  
  public int getQuadHeight() {
    return quadHeight;
  }
  
  public int getBaseNum() {
    return base;
  }
  
  public int[] getToggle() {
    return toggle;
  }
  
  public float getQuadValue(int u, int v, int w, int x, int c) {
    return quadValue[u][v][w][x][c];
  }
  
  public int getQuadCode(int u, int v, int w, int x) {
    if (hasBuffer) {
      return passCode[u][v][w][x];
    } else {
      return quadCode[u][v][w][x];
    }
  }
  
  public int[][][][] getQuadCode() {
    int[][][][] cleanCode = new int[u][v][w][x];
    
    //creates new array without unused cells
    for (int i=0; i<u; i++) {
      for (int j=0; j<v; j++) {
        for (int k=0; k<w; k++) {
          for (int l=0; l<x; l++) {
            if (hasBuffer) {
              cleanCode[i][j][k][l] = passCode[i][j][k][l];
            } else {
              cleanCode[i][j][k][l] = quadCode[i][j][k][l];
            }
          }  
        }
      }
    }
    
    return cleanCode;
  }
  
  public float getCodeValue(int i, int j) {
    if(i >= base) {
      return HSBRGB[base-1][j];
    } else {
      return HSBRGB[i][j];
    }
  }
  
  public void setBaseValue(int i, int u, int v, int w, int x) {
    for (int m=0; m<numcolors; m++) {
      HSBRGB[i][m] = quadValue[u][v][w][x][m];
    }
  }
  
  public void loadHues() {
    //Asigns range of hues for codes
    hue = new float[base];
    for (int i=0; i<base; i++) {
      hue[i] = (float)i/base*255.0;
    }
  }
  
  public float getHue(int i) {
    if(i >= base) {
      return hue[base-1];
    } else {
      return hue[i];
    }
  }
  
  void updateColors() {
    for (int i=0; i<base; i++) {
      for (int j=0; j<numcolors; j++) {
        HSBRGB[i][j] = HSBRGB_TSV.getFloat(i*6 + j);
      }
    }
  }
  
  void updateColors(TableRow HSBRGB_TSV) {
    for (int i=0; i<base; i++) {
      for (int j=0; j<numcolors; j++) {
        HSBRGB[i][j] = HSBRGB_TSV.getFloat(i*6 + j);
      }
    }
  }
    
  void presetGrid() {
    this.quadValue = new float[maxU][maxV][maxW][maxX][numcolors];
    this.quadCode = new int[maxU][maxV][maxW][maxX];
    this.bufferTime = new int[maxU][maxV][maxW][maxX]; //Amount of frames each pixel has "held steady"
    this.passCode = new int[maxU][maxV][maxW][maxX]; //codes that are finally passed on to decoder after buffering
    this.tempCode = new int[maxU][maxV][maxW][maxX]; //codes from previous frame
    
    
    for (int i=0; i<maxU; i++) {
      for (int j=0; j<maxV; j++) {
        for (int k=0; k<maxW; k++) {
          for (int l=0; l<maxX; l++) {
            this.quadCode[i][j][k][l] = 0;
            this.bufferTime[i][j][k][l] = 0;
            this.passCode[i][j][k][l] = 0;
            this.tempCode[i][j][k][l] = 0;
            
            for (int m=0; m<numcolors; m++) {
              this.quadValue[i][j][k][l][m] = 0;
            }
          }
        }
      }
    }
    
  }
    
  void setupGrid(int u, int v, float cellGapRatio, int w, int x, float quadGapRatio, int bitresW, int bitresH, int base, int IDMode, int[] toggle) {
    this.u = u;
    this.v = v;
    this.cellGapRatio = cellGapRatio;
    this.w = w;
    this.x = x;
    this.quadGapRatio = quadGapRatio;
    this.base = base;
    this.IDMode = IDMode;
    this.toggle = toggle;
    
    checkUV();
    checkWX();
    checkBase();
    
    this.bitresW = bitresW;
    this.bitresH = bitresH;
    this.cellGap = floor(cellGapRatio*bitresW);
    this.quadGap = floor(quadGapRatio*bitresW);
    
    // Resizes grid so that it divides evenly into Gap and Width Values
    quadWidth = bitresW;
    quadHeight = bitresH;
    
    cellWidth = w*quadWidth + (w-1)*quadGap;
    cellHeight = x*quadHeight + (x-1)*quadGap;
    
    gridWidth = u*cellWidth  + (u+1)*cellGap;
    gridHeight = v*cellHeight + (v+1)*cellGap;
    
    grid = createGraphics(toggle[2], toggle[3]);
    
    HSBRGB = new float[base][numcolors];
    dev = new float[base];
    loadHues();
    updateColors();
  }
  
  
  void updatePosition(int[] toggle) {
    for (int i=0; i < toggle.length; i++) {
      this.toggle[i] = toggle[i];
    }
    grid = createGraphics(toggle[2], toggle[3]);
  }
  
  void updateUV(int u, int v) {
    this.u = u;
    this.v = v;
    checkUV();
    gridWidth = u*cellWidth  + (u+1)*cellGap;
    gridHeight = v*cellHeight + (v+1)*cellGap;
  }
  
  void updateWX(int w, int x) {
    
    this.w = w;
    this.x = x;
    checkWX();
    cellWidth = w*quadWidth + (w-1)*quadGap;
    cellHeight = x*quadHeight + (x-1)*quadGap;
    gridWidth = u*cellWidth  + (u+1)*cellGap;
    gridHeight = v*cellHeight + (v+1)*cellGap;
  }
  
  void updateBase(int base) {
    this.base = base;
    HSBRGB = new float[base][numcolors];
    dev = new float[base];
    
    loadHues();
    updateColors();
    
    println("Base = " + base);
  }
  
  // Increments number of principal colors used of tag detection (other than black and white)
  public void nextIDMode() {
    if (IDMode < maxIDMode) {
      IDMode++;
    } else {
      IDMode = 0;
    }
    println(IDMode*8 + " ID tags now enabled");
  }
  
  void checkUV() {
    if (u > maxU) {
      println("More than " + maxU + " horizontal cells allowed.");
      this.u = maxU;
    } else if (u < 1) {
      println("Number of horizontal cells must be at least 1.");
      this.u = 1;
    }
    if (v > maxV) {
      println("More than " + maxV + " vertical cells allowed.");
      this.v = maxV;
    } else if (v < 1) {
      println("Number of vertical cells must be at least 1.");
      this.v = 1;
    }
  }
  
  void checkWX() {
    if (w > maxW) {
      println("More than " + maxW + " horizontal cell divisions allowed.");
      this.w = maxW;
    } else if (w < 1) {
      println("Number of horizontal cell divisions must be at least 1.");
      this.w = 1;
    }
    if (x > maxX) {
      println("More than " + maxW + " vertical cell divisions allowed.");
      this.x = maxX;
    } else if (x < 1) {
      println("Number of vertical cell divisions must be at least 1.");
      this.x = 1;
    }
  }
  
  void checkBase() {
    if (base > maxBase) {
      println("More than " + maxBase + " distinct reference colors not allowed.");
      this.base = maxBase;
    } else if (base < 1) {
      println("Number of reference colors must be at least 1.");
      this.base = 1;
    }
  }
  
  void updatePatterns(PImage scan) {
    
    grid.beginDraw();
    grid.image(scan, -toggle[0], -toggle[1]);
    grid.endDraw();
    resized = grid.get();
    resized.resize(gridWidth, gridHeight);
    resized.loadPixels();
    
    if (hasBuffer && sendOnUpdateOnly) {
      updateReceived = false;
    } else { //assumes updates every frame, since there is no buffer to check
      updateReceived = true; 
    }
    
    for(int i=0; i<u; i++) {
      for( int j=0; j<v; j++) {
        
        for (int k=0; k<w; k++) {
          for (int l=0; l<x; l++) {
            
            for (int m=0; m<numcolors; m++) {
              quadValue[i][j][k][l][m] = 0;
            }
            
            for (int m=0; m<quadWidth; m++) {
              for (int n=0; n<quadHeight; n++) {
                
                local =       //Skips to column column in Row
                              m + //Skips pixels within quad
                              k * (quadGap + quadWidth) + //Skips quads
                              i * (cellGap + cellWidth) + //Skips cells
                                  (cellGap)  + //Skips left margin
                              
                              //Skips to row
                              n * gridWidth + //Skips pixels within quad
                              l * gridWidth * (quadGap + quadHeight) +  //Skips quads
                              j * gridWidth * (cellGap + cellHeight) + //Skips cells
                                  gridWidth * (cellGap); //Skips Top Margin;
                
                quadValue[i][j][k][l][0] += hue(resized.pixels[local]);
                quadValue[i][j][k][l][1] += saturation(resized.pixels[local]);
                quadValue[i][j][k][l][2] += brightness(resized.pixels[local]);
                quadValue[i][j][k][l][3] += red(resized.pixels[local]);
                quadValue[i][j][k][l][4] += green(resized.pixels[local]);
                quadValue[i][j][k][l][5] += blue(resized.pixels[local]);
              }
            }
            
           
            
            for (int m=0; m<numcolors; m++) {
              quadValue[i][j][k][l][m] /= quadWidth*quadHeight;
            }
            
            for (int n=0; n<base; n++) {
                dev[n] =0;
              }
            for (int m=1; m<numcolors; m++) { //ignores hue sumdiffs at m=0
              for (int n=0; n<base; n++) {
                //calculate sum differences
                dev[n] += sq(quadValue[i][j][k][l][m]-HSBRGB[n][m]);
              }
            }
            float minDev = 1000000;
            
            for (int m=0; m<base; m++) {
              if (dev[m]<minDev) {
                minDev = dev[m];
                quadCode[i][j][k][l] = m;
              }
            }
            
            if (hasBuffer) {
              // Checks to see if color codes have held steady over set amount of "buffer" frames.  otherwise does not allow
              if (quadCode[i][j][k][l] == tempCode[i][j][k][l]) { // checks to see if current and last frames are the same color value
                if (bufferTime[i][j][k][l] == buffer) { //checks to see if color value has been constant for set amount of frames "buffer"
                  passCode[i][j][k][l] = quadCode[i][j][k][l];
                  updateReceived = true;
                  bufferTime[i][j][k][l] ++; // increments bufferTime to buffer+1
                } else if (bufferTime[i][j][k][l] < buffer) { // adds 1 frame to bufferTime counter for that pixel
                  bufferTime[i][j][k][l] ++;
                  //println(bufferTime[i][j][k][l]);
                }
              } else { // if current and last color values are different, resets bufferTime to '0'
                bufferTime[i][j][k][l] = 0;
                //println("reset!" + i + " " + j);
              }
              
              //current color reading becomes past color reading for next loop
              tempCode[i][j][k][l] = quadCode[i][j][k][l];
            }
            
          }
        } // End Cycling through Cell Quad
        
      }
    } // End Cycling through Cell
               
  } // End UpdatePatterns
  
} //End Class

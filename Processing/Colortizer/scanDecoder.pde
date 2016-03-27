// This class allows arrays color values to be translated into corresponding values informed by globally defined code definitions tab
//
// By Ira Winder, MIT Media Lab, April 2014

String[] colorDef = new String[]{
  "Lego White",
  "Lego Black",
  "Lego Red",
  "Lego Yellow",
  "Lego Blue/Green",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A",
  "N/A"
};

float[][] buildingDef = new float[][]{ 
// Tag, BLG ID;
// Tag: 0=White, 1=Black, 2=Red, 3=Yellow, 4=Blue/Green
  {2000, 0},
  {2100, 1},
  {2010, 2},
  {2001, 3},
  {2110, 4},
  {2101, 5},
  {2011, 6},
  {2111, 7},
  
  {3000, 8},
  {3100, 9},
  {3010, 10},
  {3001, 11},
  {3110, 12},
  {3101, 13},
  {3011, 14},
  {3111, 15},
  
  {4000, 16},
  {4100, 17},
  {4010, 18},
  {4001, 19},
  {4110, 20},
  {4101, 21},
  {4011, 22},
  {4111, 23}
};

int[][] rotationDef = new int[][]{
  {0, 0},
  {1, 90},
  {2, 180},
  {3, 270}
};

public class SliderDecoder {
  private float code;
  
  protected float min, max;
  protected boolean flip;
  
  public SliderDecoder(float min, float max) {
    this.min = min;
    this.max = max;
    this.flip = false;
  }
  
  public SliderDecoder(float min, float max, boolean flip) {
    this.min = min;
    this.max = max;
    this.flip = flip;
  }
  
  public void decoder(int[][][][] quadCode) {
    code = 0;
    int counter = 0;
    
    if (quadCode.length > 1) {
      for (int i=0; i<quadCode.length; i++) {
        if (quadCode[i][0][0][0] == 0) {
          code += (float)(i+1)/(quadCode.length);
          counter++;
        }
      }
    } else {
      for (int i=0; i<quadCode[0].length; i++) {
        if (quadCode[0][i][0][0] == 0) {
          code += (float)(i+1)/(quadCode[0].length);
          counter++;
        }
      }
    }
    
    if (counter == 0) {
      code = 0;
    } else {
      code /= counter;
    }
    
    if (!flip) {
      code = 1.0 - code;
    }
    
    if (code < 0.1) {
      code = 0;
    } else if (code > 0.9) {
      code = 1;
    }
    
    code = min + code*(max-min);
  }
}

public class ColorDecoder {
  private int U, V, W, X;
  private int[][] id;
  
  public ColorDecoder() {
    
  }
  
  public void decoder(int[][][][] quadCode) {
    
    //Resizes arrays if dimensions of quadcode changes.
    if (quadCode.length != U || quadCode[0].length != V) {
      U = quadCode.length;
      V = quadCode[0].length;
      W = quadCode[0][0].length;
      X = quadCode[0][0][0].length;
      id = new int[U][V];
    }
    
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) {
        id[u][v] = quadCode[u][v][0][0];
      }
    }
    
  }
}
          

public class TagDecoder {
  
  protected float[][] buildingDef;
  protected int[][] rotationDef;
  
  private int U, V, W, X;
  private int[][] rotation, id, use;
  private float[][] floors;
  
  public TagDecoder(float[][] buildingDef, int[][] rotationDef) {
    this.buildingDef = buildingDef;
    this.rotationDef = rotationDef;
  }
  
  public void decoder(int[][][][] quadCode, int IDMode) { 
  //Decodes a 4-bit code with potential values of 0, 1, 2, 3, 4, etc giving rotation and unique id
    
    //Resizes arrays if dimensions of quadcode changes.
    if (quadCode.length != U || quadCode[0].length != V) {
      
      U = quadCode.length;
      V = quadCode[0].length;
      W = quadCode[0][0].length;
      X = quadCode[0][0][0].length;
      
      rotation = new int[U][V];
      id = new int[U][V];
    }
    
    for (int u=0; u<U; u++) {
      for (int v=0; v<V; v++) { 
        
        id[u][v] = -1;
        
        for (int i=0; i<W; i++) {
          for (int j=0; j<X; j++) {
            
            //Generates code for 4-bit color, allowing for rotation based on quadCode values greater than 0 or 1 (not back or white)
            if (W == 2) { 
              
              // Checks to see if color is neither black nor white (0 or 1)
              if (quadCode[u][v][i][j] > 1) {
                
                // Checks to see if Color Tag is allowed via IDMode
                if (quadCode[u][v][i][j] <= IDMode+1) {
                  
                  id[u][v] += 1000 * quadCode[u][v][i][j]; 
                
                  if (i==0 && j==0) {
                    
                    rotation[u][v] = 0;
                    id[u][v] += 100*quadCode[u][v][1][0];
                    id[u][v] +=  10*quadCode[u][v][1][1];
                    id[u][v] +=   1+1*quadCode[u][v][0][1];
                    
                  } else if (i==1 && j==0) {
                    
                    rotation[u][v] = 1;
                    id[u][v] += 100*quadCode[u][v][1][1];
                    id[u][v] +=  10*quadCode[u][v][0][1];
                    id[u][v] +=   1+1*quadCode[u][v][0][0];
                    
                  } else if (i==1 && j==1) {
                    
                    rotation[u][v] = 2;
                    id[u][v] += 100*quadCode[u][v][0][1];
                    id[u][v] +=  10*quadCode[u][v][0][0];
                    id[u][v] +=   1+1*quadCode[u][v][1][0];
                    
                  } else if (i==0 && j==1) {
                    
                    rotation[u][v] = 3;
                    id[u][v] += 100*quadCode[u][v][0][0];
                    id[u][v] +=  10*quadCode[u][v][1][0];
                    id[u][v] +=   1+1*quadCode[u][v][1][1];
                    
                  }
                }
              }
            } else if (W == 1) { //Generates code for 1-bit color. does not allow rotation
              id[u][v] += 1 + quadCode[u][v][i][j];
            }
          }
        }
        
        if (W == 2) { //Checks to see if 2x2 tag, otherwise translates 1x1 color code directly to id
          // Match IDs to building/rotation
          boolean matched = false;
          for (int i=0; i<buildingDef.length; i++) {
            if (buildingDef[i][0] == id[u][v]) {
              matched = true;
              id[u][v] = (int)buildingDef[i][1];
              break;
            }
          }
          if (!matched) {
            id[u][v] = -1;
          }
          
          for (int i=0; i<rotationDef.length; i++) {
            if (rotationDef[i][0] == rotation[u][v]) {
              rotation[u][v] = rotationDef[i][1];
              break;
            }
          }
        }
        
        
      }
    }
  }
  
  public int getID(int u, int v) {
    return id[u][v];
  }
  
  public int getRotation(int u, int v) {
    return rotation[u][v];
  }
}

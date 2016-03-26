// If true, overrides webcam feed.  Useful for development without webcam
boolean showDefaultImage = false;

boolean decode = true;

TagDecoder[] tagDecoder;
SliderDecoder[] sliderDecoder; // Object that translates slider colors into numbers

void initDecoders() {
  
  if (decode) {
    
    tagDecoder = new TagDecoder[1];
    tagDecoder[0] = new TagDecoder(buildingDef, rotationDef); // main Patterned Scan Grid
    
    /*
    colorDecoder[1] = new ColorDecoder(); // reference color 1
    colorDecoder[2] = new ColorDecoder(); // reference color 2
    colorDecoder[3] = new ColorDecoder(); // reference color 3
    
    sliderDecoder = new SliderDecoder[10];
    sliderDecoder[0] = new SliderDecoder(0,1); // Slider 1
    sliderDecoder[1] = new SliderDecoder(0,1); // Slider 2
    sliderDecoder[2] = new SliderDecoder(0,1); // Slider 3
    sliderDecoder[3] = new SliderDecoder(0,1); // Slider 4
    sliderDecoder[4] = new SliderDecoder(0,1); // Toggle 1
    sliderDecoder[5] = new SliderDecoder(0,1); // Toggle 2
    sliderDecoder[6] = new SliderDecoder(0,1); // Toggle 3
    sliderDecoder[7] = new SliderDecoder(0,1); // Toggle 4
    sliderDecoder[8] = new SliderDecoder(0,1); // Toggle 5
    sliderDecoder[9] = new SliderDecoder(0,1); // Toggle 6
    */
  }
  
}

void updateDecoders() {
  
  int[][][][] tempCode;
  
  if (decode) {
    
    //Decodes grid that we will assign color codes
    tagDecoder[0].decoder(scanGrid[numGAforLoop[imageIndex] + gridIndex].getQuadCode(), scanGrid[numGAforLoop[imageIndex] + gridIndex].IDMode);
    
    /*
    
    //Decodes Reference Colors
    tempCode = new int[1][1][1][1];
    for (int i=0; i<scanGrid[4].getQuadCode()[0].length; i+=2) {
      tempCode[0][0][0][0] = scanGrid[4].getQuadCode()[0][i][0][0];
      colorDecoder[i/2 + 1].decoder(tempCode);
    }
    
    // Decodes Sliders
    tempCode = new int[1][scanGrid[3].getQuadCode()[0].length][1][1];
    for (int i=0; i<scanGrid[3].getQuadCode().length; i+=2) {
      for (int j=0; j<scanGrid[3].getQuadCode()[0].length; j++) {
        tempCode[0][j][0][0] = scanGrid[3].getQuadCode()[i][j][0][0];
      }
      sliderDecoder[i/2 + 0].decoder(tempCode);
    }
    
    // Row 1 Toggles
    tempCode = new int[1][scanGrid[1].getQuadCode()[0].length][1][1];
    for (int i=0; i<scanGrid[1].getQuadCode().length; i+=2) {
      for (int j=0; j<scanGrid[1].getQuadCode()[0].length; j++) {
        tempCode[0][j][0][0] = scanGrid[1].getQuadCode()[i][j][0][0];
      }
      sliderDecoder[i/2 + 4].decoder(tempCode);
    }
    
    // Row 2 Toggles
    tempCode = new int[1][scanGrid[2].getQuadCode()[0].length][1][1];
    for (int i=0; i<scanGrid[2].getQuadCode().length; i+=2) {
      for (int j=0; j<scanGrid[2].getQuadCode()[0].length; j++) {
        tempCode[0][j][0][0] = scanGrid[2].getQuadCode()[i][j][0][0];
      }
      sliderDecoder[i/2 + 4 + 3].decoder(tempCode);
    }
    */
  }
  
}

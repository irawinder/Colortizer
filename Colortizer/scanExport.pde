/*
 * Incoming Port: 6669
 * Ougoing Port:  6152
 *
 * REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:
 * - Updated to include location array "locArray" that passes x, y, width, and height values for scanGrids
 * - 2016/01/04 Yasushi Connect to a meteor app via DDP and send
 * -
 * -
 */

import com.google.gson.Gson; // you don't need this if your just using DDPclient
import ddpclient.*;


boolean busyImporting = false;
boolean viaUDP = true;
boolean karthikPrototype = false;
boolean ryanUDP = false;
int countRyanUDP = 0;

// import UDP library
import hypermedia.net.*;
UDP udp;  // define the UDP object

/**
* importing the DDP library and dependencies (2016/01/05 Y.S.)
* 
*/
boolean enableDDP = false;
String DDPAddress = "104.131.183.20";


DDPClient ddp;
Gson gson; // handy to have one gson converter...
int[][] state_data; // because this object is ment to be json-ized

void startUDP(){

  if (decode == false) {
    viaUDP = false;
  }

  if (viaUDP) {
    udp = new UDP( this, 6669 );
    //udp.log( true );     // <-- printout the connection activity
    udp.listen( true );
  }

  /**
  * DDP initiation (2016/01/04 Y.S.)
  * 
  * assuming that this function is called in init 
  * initiating will automatically connect
  */
  //ddp = new DDPClient(this,"localhost",3000);
  ddp = new DDPClient(this,DDPAddress,80);
  gson = new Gson();
  ddp.setProcessing_delay(100);

}

void sendData() {

  if (viaUDP && updateReceived) {
    String dataToSend = "";
    /**
    * state_data
    */
    state_data=new int[0][0];
    
    // Scan Grid Location (for referencing grid offset file)
    dataToSend += "gridIndex";
    dataToSend += "\t" ;
    dataToSend += numGAforLoop[imageIndex] + gridIndex;

    dataToSend += "\n" ;
    
    for (int u=0; u<tagDecoder[0].U; u++) {
      for (int v=0; v<tagDecoder[0].V; v++) {

        // Object ID
        dataToSend += tagDecoder[0].id[u][v] ;
        dataToSend += "\t" ;

//        // U Position
//        dataToSend += tagDecoder[0].U-u-1 + exportOffsets[numGAforLoop[imageIndex] + gridIndex][0];
//        dataToSend += "\t" ;
//
//        // V Position
//        dataToSend += v + exportOffsets[numGAforLoop[imageIndex] + gridIndex][1];
        
        // U Position
        dataToSend += tagDecoder[0].U-u-1;
        dataToSend += "\t" ;

        // V Position
        dataToSend += v;

        ////// BEGIN Added March 3, 2015 by Ira Winder ///////

        dataToSend += "\t" ;

        // Rotation
        dataToSend += tagDecoder[0].rotation[u][v];

        ////// END Added March 3, 2015 by Ira Winder ///////

        //if (u != tagDecoder[0].U-1 || v != tagDecoder[0].V-1) {
          dataToSend += "\n" ;
        //}

        /**
        * storing data for web (2016/01/05 Y.S.)
        * simplified the data for the sake of example
        */
        if(enableDDP){
          state_data = (int[][])append(state_data,new int[]{tagDecoder[0].id[u][v],tagDecoder[0].rotation[u][v]});
        }
      }
    }

//    // UMax and VMax Values
//    dataToSend += tagDecoder[0].U;
//    dataToSend += "\t" ;
//    dataToSend += tagDecoder[0].V;
//    dataToSend += "\t" ;

    /*
    // Slider and Toggle Values
    for (int i=0; i<sliderDecoder.length; i++) {
      dataToSend += sliderDecoder[i].code;
      if (i != sliderDecoder.length-1) {
        dataToSend += "\t";
      } else {
        dataToSend += "\n";
      }
    }


    // Slider and Toggle Locations
    for (int i=0; i<numGridAreas[0]; i++) {
      dataToSend += gridLocations.getInt(0, 0 + i*4);
      dataToSend += "\t" ;
      dataToSend += gridLocations.getInt(0, 1 + i*4);
      dataToSend += "\t" ;
      dataToSend += gridLocations.getInt(0, 2 + i*4);
      dataToSend += "\t" ;
      dataToSend += gridLocations.getInt(0, 3 + i*4);
      dataToSend += "\n";
    }


    // Slider and Toggle Canvas Dimensions
    dataToSend += vizRatio;
    dataToSend += "\t" ;
    dataToSend += vizWidth;
    dataToSend += "\n" ;
    */

    //saveStrings("data.txt", split(dataToSend, "\n"));
    //udp.send( dataToSend, "18.85.55.241", 6152 );
    udp.send( dataToSend, "localhost", 6152 );

    /**
    * sending data via DDP (2016/01/04 Y.S.)
    */
    if(enableDDP)  ddp.call("sendCapture",new Object[]{gson.toJson(state_data)});

    // Karthik's IP Address
    if(karthikPrototype) {
      if (millis() % 1000 <=150) udp.send( dataToSend, "104.131.179.31", 33333 );
    }
    
    // Ryan's IP Address
    countRyanUDP ++;
    if(ryanUDP && countRyanUDP >= 30) {
      udp.send( dataToSend, "18.85.27.198", 7004 );
      countRyanUDP = 0;
    }
    
    //println("update received");

  } else {
    //println("no update received");
  }
}

// Implemented for SDL Rhino Interface (deprecated)
void ImportData(String inputStr[]) {

  for (int i=0 ; i<inputStr.length;i++) {

    String tempS = inputStr[i];
    String[] split = split(tempS, "\t");

    // Sends commands to Rhino Server to run UMI functions
    if (split.length == 1) {

      switch(int(split[0])) {
        case 1:
          if (writer != null) { writer.println("resimulate"); }
          break;
        case 2:
          if (writer != null) { writer.println("save"); }
          break;
        case 3:
          if (writer != null) { writer.println("displaymode energy"); }
          break;
        case 4:
          if (writer != null) { writer.println("displaymode walkability"); }
          break;
        case 5:
          if (writer != null) { writer.println("displaymode daylighting"); }
          break;
        case 6:
          if(useUMI) {
            initServer();
          }
          break;
      }
      println(split[0]);
    }
  }

  busyImporting = false;
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler

  // get the "real" message =
  String message = new String( data );
  //println(message);
  saveStrings("data.txt", split(message, "\n"));
  String[] split = split(message, "\n");

  if (!busyImporting) {
    busyImporting = true;
    ImportData(split);
  }
}

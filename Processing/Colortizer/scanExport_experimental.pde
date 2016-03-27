/*
 * REPORT ALL CHANGES WITH DATE AND USER IN THIS AREA:
 * - 2016/01/04 Yasushi Connect to a meteor app via DDP and send
 * -
 * -
 */
 
// <--- BEGIN UDP to External Server --->

boolean UDPtoServer = false;

// Karthik's Machine
String UDPServer_IP = "104.131.179.31";
int UDPServer_PORT = 33333;

/*
// CityScope Machine
String UDPServer_IP = "cityscope.media.mit.edu";
int UDPServer_PORT = 9998;
*/

// <--- END UDP to External Server --->



// <--- BEGIN DDP to External Server --->
// importing the DDP library and dependencies (2016/01/05 Y.S.)

import com.google.gson.Gson; // you don't need this if your just using DDPclient
import ddpclient.*;
DDPClient ddp;
Gson gson; // handy to have one gson converter...
int[][] state_data; // because this object is ment to be json-ized
boolean enableDDP = false;
String DDPAddress = "104.131.183.20";
int DDPPort = 80;

void initDDP() {
/**
  * DDP initiation (2016/01/04 Y.S.)
  * 
  * assuming that this function is called in init 
  * initiating will automatically connect
  */
  //ddp = new DDPClient(this,"localhost",3000);
  ddp = new DDPClient(this,DDPAddress,DDPPort);
  gson = new Gson();
  ddp.setProcessing_delay(100);
}

// <--- END DDP to External Server --->

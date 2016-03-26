// Was created by Cody Rose for Riyadh Demo in April 2015.  
// Set "useUMI" to true if wanting to connect to UMI's Rhino Environment
boolean useUMI = false;


import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.Socket;

//Rigidly a 14x14 grid offset 1 from Colortizer Grid
//USE FOR UMI-RIYADH ONLY

//server-client connection var
final int port = 8001;
Socket socket;
PrintWriter writer;

String[] blockCodes;
int[][] previousCodes;
int[][] previousOrientations;

void initServer() {
   
  connectServer();

  blockCodes = new String[16];
  
  blockCodes[0] = "ST1";
  blockCodes[1] = "R1";
  blockCodes[2] = "C2";
  blockCodes[3] = "ST2";
  blockCodes[4] = "M4";
  blockCodes[5] = "M2";
  blockCodes[6] = "R2";
  blockCodes[7] = "M6";
  blockCodes[8] = "P";
  blockCodes[9] = "C3";
  blockCodes[10] = "C1";
  blockCodes[11] = "ST3";
  blockCodes[12] = "M3";
  blockCodes[13] = "M1";
  blockCodes[14] = "R3";
  blockCodes[15] = "M5";
  
  previousCodes = new int[14][14];
  previousOrientations = new int[14][14];
  for (int i = 0; i < 14; ++i) {
    for (int j = 0; j < 14; ++j) {
      previousCodes[i][j] = -1;
      previousOrientations[i][j] = 0;
    }
  }
}

void updateServer() {
  String message = "newblocks";
  
  if (tagDecoder[0].id.length >= 15 && tagDecoder[0].id[0].length >= 15) {
    for (int i = 0; i < 14; ++i) {
      for (int j = 0; j < 14; ++j) {
        int decoded = tagDecoder[0].id[i+1][j+1];
        int rotation = tagDecoder[0].rotation[i+1][j+1];
        
        if (previousCodes[i][j] == decoded && previousOrientations[i][j] == rotation) {
          continue;
        }
        
        if (decoded >= 0 && decoded <= 15) {
          message += " " + blockCodes[decoded] + ":";
          message += 14 - i - 1;
          message += ",";
          message += 14 - j - 1;
          message += ",";
          message += (rotation / 90 + 3) % 4;
        }
        else {
          message += " NULL:" + (14 - i - 1) + "," + (14 - j - 1) + ",0";
        }
        previousCodes[i][j] = decoded;
        previousOrientations[i][j] = rotation;
      }
    }
  }
  if (message != "newblocks") {
    if (writer != null) {
      writer.println(message);
      writer.println("resimulate");
    }
  }
}

void connectServer() {
  //Server Rhino Connection
   try {
        socket = new Socket("127.0.0.1", port);
        writer = new PrintWriter(socket.getOutputStream(), true);
        //writer.println("_MarkIVBuildArea");
       }
   catch (Exception e) { println(e.getMessage());}
}

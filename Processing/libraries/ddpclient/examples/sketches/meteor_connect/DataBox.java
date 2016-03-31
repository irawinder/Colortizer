/**
* DataBox.java
*
* Meteor App Connection
* written using processing 2.2.1
* 1/1/16
* 
* The MIT License (MIT)
*
* Copyright (c) 2016 Yasushi Sakai
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import processing.core.*;

public class DataBox {

  public final static int SIZE = 8;
  public final static int MARGIN = 10;
  public final static int PADDING = 2;
  private static int row = 0;
  public static int box_num = 0;

  private static PApplet parent;  
  public static void setParent(PApplet _parent){
    parent = _parent;
    
    // set row fron parent PApplet
    row = (parent.width-(MARGIN*2))/(SIZE+PADDING);
  }

  public static int getRow() {
    return row;
  }
  
  public enum BoxType {
    SERVER, BROWSER, SKETCH, UNKNOWN,
  };
  
  private BoxType type;
  private String uid; // Mongo id's are UIDs
  private int id;
  private String text;
  public boolean isFocus;

  public DataBox(String _uid, String _type, String _text) {
    //parent = _parent;
    uid = _uid;
    id = box_num;

    if (_type.equals("server")) type=BoxType.SERVER;
    else if (_type.equals("browser")) type=BoxType.BROWSER;
    else if (_type.equals("processing")) type=BoxType.SKETCH;
    else type=BoxType.UNKNOWN;

    text = _text;
    isFocus = false;

    box_num ++;
  }

  public boolean checkUID(String _uid) {
    return uid.equals(_uid);
  }

  public void draw() {
    parent.noStroke();

    if (isFocus) parent.stroke(255);
    switch(type) {
    case SERVER:
      parent.fill(255, 0, 0);
      break;
    case BROWSER:
      parent.fill(0, 0, 255);
      break;
    case SKETCH:
      parent.fill(0, 255, 0);
      break;
    case UNKNOWN:
      parent.fill(120);
      break;
    }
    parent.rect(0, 0, SIZE, SIZE);
  }

  public String toString() {
    return "<DataBox id: "+uid+", text: "+text+">";
  }
  
}


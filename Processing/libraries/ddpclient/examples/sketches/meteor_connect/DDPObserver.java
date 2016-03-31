/**
* DDPObserver.java
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

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import ddpclient.*;
import processing.core.*;
import processing.event.MouseEvent;

public class DDPObserver extends DDPListener implements Observer {

  private Map<String, Map<String, Object>> collections;
  private List<DataBox> data_boxes;

  public DDPObserver(PApplet parent) {
    super(parent);
    parent.registerMethod("mouseEvent", this);
    parent.registerMethod("dispose", this); //...deletes databoxes.

    DataBox.setParent(parent);

    collections = new HashMap<String, Map<String, Object>>();
    data_boxes = new ArrayList<DataBox>();
  }

  public void update(Observable client, Object message) {
    Map<String, Object> json = (Map<String, Object>) message;

    String message_type = (String)json.get("msg");

    if (message_type.equals("added")) {
      appendDataBox(json);
    }
    if (message_type.equals("error")) {
      dumpMap(json);
    }
    if (message_type.equals("removed")) {
      deleteDataBox(json);
    }
  }

  public void dumpMap(Map<String, Object> _json) {
    for (Entry<String, Object> entry : _json.entrySet ()) {
      String[] type = parent.split(entry.getValue().getClass().toString(), '.');
      parent.println("  key:"+entry.getKey()+", value:"+entry.getValue()+", class:"+type[type.length-1]);
    }
    parent.println();
  }

  public void appendDataBox(Map<String, Object> _json) {
    String uid = (String)_json.get("id");
    Map<String, Object> fields = (Map<String, Object>)_json.get("fields");
    String type = (String)fields.get("origin");
    String text = (String)fields.get("text");
    DataBox dbox = new DataBox(uid, type, text);
    data_boxes.add(dbox);
    draw();
  }

  public void deleteDataBox(Map<String, Object> _json) {
    String uid = (String)_json.get("id");
    for (DataBox data_box : data_boxes) {
      if (data_box.checkUID(uid)) {
        data_boxes.remove(data_box);
        break;
      }
    }
    draw();
  }

  public void draw() {

    parent.background(0);

    int i = 0;

    for (DataBox data_box : data_boxes) {
      int x = i%DataBox.getRow();
      int y = i/DataBox.getRow();

      parent.pushMatrix();
      parent.translate(DataBox.MARGIN+x*(DataBox.SIZE+DataBox.PADDING), DataBox.MARGIN+y*(DataBox.SIZE+DataBox.PADDING));
      data_box.draw();
      parent.popMatrix();

      i++;
    }

    parent.redraw();
  }

  public void mouseEvent(MouseEvent e) {

    boolean drawFlag = false;

    int i=0;
    for (DataBox data_box : data_boxes) {
      int x = DataBox.MARGIN+(i%DataBox.getRow())*(DataBox.SIZE+DataBox.PADDING);
      int y = DataBox.MARGIN+(i/DataBox.getRow())*(DataBox.SIZE+DataBox.PADDING);

      if (x<e.getX() && e.getX()<x+DataBox.SIZE && y<e.getY() && e.getY()<y+DataBox.SIZE) {
        if (!data_box.isFocus) {
          drawFlag = true;
          data_box.isFocus = true;
          parent.println(data_box.toString());
        }
      } else {
        data_box.isFocus = false;
      }
      i++;
    }
    
    if(drawFlag){
      draw();
    }
  }

  public void dispose() {
    data_boxes = null;
  }
}


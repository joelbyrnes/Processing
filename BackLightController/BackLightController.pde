import processing.serial.*;   

HScrollbar hueBar, satBar, lightBar;

Serial port; 
final String COM_PORT = "COM7"; 

void setup()
{
  size(200, 400);
  noStroke();
  hueBar = new HScrollbar(0, 40, width, 10, 3*5+1);
  satBar = new HScrollbar(0, 60, width, 10, 3*5+1);
  lightBar = new HScrollbar(0, 80, width, 10, 3*5+1);
  
  println("setup serial");
  println(Serial.list()); // List COM-ports
  port = new Serial(this, COM_PORT, 115200);   
}

void draw()
{
  background(255);
  
  fill(0, 102, 153);
  textSize(14);
  text("hue", 10, 30); 
//  fill(255);

  hueBar.update();
  satBar.update();
  lightBar.update();
  hueBar.display();
  satBar.display();
  lightBar.display();
    
  println("hue " + hueBar.getLinear() * 360 + 
      " sat " + satBar.getLinear() + 
      " light " + lightBar.getLinear());
  
  port.write(byte(hueBar.getLinear() * 256)); 
  port.write(byte(satBar.getLinear() * 256)); 
  port.write(byte(lightBar.getLinear() * 256)); 
}


class HScrollbar
{
  int swidth, sheight;    // width and height of bar
  int xpos, ypos;         // x and y position of bar
  float spos, newspos;    // x position of slider
  int sposMin, sposMax;   // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  color barColor = color(200);

  HScrollbar (int xp, int yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if(over()) {
      over = true;
    } else {
      over = false;
    }
    if(mousePressed && over) {
      locked = true;
    }
    if(!mousePressed) {
      locked = false;
    }
    if(locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  int constrain(int val, int minv, int maxv) {
    return min(max(val, minv), maxv);
  }

  boolean over() {
    if(mouseX > xpos && mouseX < xpos+swidth &&
    mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    fill(barColor);
    rect(xpos, ypos, swidth, sheight);
    if(over || locked) {
      fill(153, 102, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
  
  float getLinear() {
    return spos / swidth;
  }
}

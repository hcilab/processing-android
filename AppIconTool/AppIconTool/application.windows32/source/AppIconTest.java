import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AppIconTest extends PApplet {

public void setup() {
   
 
   
   noStroke();
   fill(255);
   rectMode(CENTER);     //This sets all rectangles to draw from the center point
};
 
public void draw() {
   background(0xffFF9900);
   rect(width/2, height/2, 150, 150);
};
  public void settings() {  size(480,800);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AppIconTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

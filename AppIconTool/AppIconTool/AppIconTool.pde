//Vars
private boolean COLOR_SWITCH = true;
private int SELECT_TYPE = 1;
private int SIZE = 30;
private int SPACE = 30;
private int X_MARGIN = 10;
private int Y_MARGIN = 10;
private int MAX_ZOOM = 2;
private float ZOOM_SPEED = 0.075;
private int rows;
private int cols;
private int total;
private float selectedX;
private float selectedY;
private float currentX;
private float currentY;
private float diffX;
private float diffY;
private float originX;
private float originY;
private float zoomScale;
private boolean click;
private boolean redraw;
private boolean zoom;
private boolean zoomStart;
private boolean zoomState;
private String colorList[] = {"FFFF00","008744","FFC0CB","8B4513","0057e7","d62d20","ffa700","00FFFF","808000","00FF00","008080","000080","FF00FF","800080","FFD700","0000FF","FF1493","FF8C00","5F9EA0","800000"};
private AppRectangle rects[];

//Setup
void setup() {
  //Set to draw main on first draw loop 
  redraw = true;
  
  //Start unzoomed
  zoom = false;
  zoomStart = false;
  zoomState = false;
  
  //Set window origin
  currentX = 0;
  currentY = 0;
  diffX = 0;
  diffY = 0;
  originX = 0;
  originY = 0;
  zoomScale = 1;
  
  //Set window settings and calculate number of app tiles to generate
  size(480,800);
  int xSpace = SIZE + SPACE;
  int ySpace = SIZE + SPACE;
  rows = ((height + SPACE - (SIZE+(Y_MARGIN*2)))/(ySpace));
  cols = ((width + SPACE - (SIZE+(X_MARGIN*2)))/(xSpace));
  total = (rows*cols);
  if((rows*cols) > 94){
    total = 94; 
  };
  int xOffset = (width + SPACE + (X_MARGIN*2) - (cols*(xSpace) + (X_MARGIN*2)))/2;
  int yOffset = (height + SPACE + (Y_MARGIN*2) - (rows*(ySpace) + (Y_MARGIN*2)))/2;
  rects = new AppRectangle[rows*cols];
  smooth();
  background(255);
  
  //Create app rectangles
  int count = 0;
  long temp = 33; //33 start of unicode characters for icons 
  for(float i = 0; i < cols; i++){
    for(float j = 0; j < rows; j++){
      rects[count] = new AppRectangle(
        count,
        (float)(i * xSpace) + xOffset,
        (float)(j * ySpace) + yOffset,
        SIZE,
        colorList[count%20],
        Long.toHexString(temp),
        colorList[(count+1)%20]
      );
      count++;
      temp++;
    }//endFor(j rows)
  }//endFor(i cols)
}; //end setup()

//Draw loop
//Elements in draw loop will draw at the end of each iteration
void draw(){
  if(click && SELECT_TYPE == 0){
    checkClick();
    click = false;
  }
  if(click && SELECT_TYPE == 1){
    if(!zoomState){
       setOrigin();
    }
    else{
      originX = 0;
      originY = 0;
      checkClick();
    }
    zoom = true;
    click = false;
    redraw = true;
    zoomStart = true;
  }
  if(redraw){
    if(zoomStart){
      zoomSetup();
      zoomStart = false;
    }  
    redraw = false;
    background(255);
    if(SELECT_TYPE == 1){
      if(zoom){
        zoom();
        if((zoomScale < MAX_ZOOM && !zoomState) || (zoomScale > 1 && zoomState)){   
          redraw = true;
          if(!zoomState){
            zoomScale += ZOOM_SPEED;
            currentX -= diffX*2;
            currentY -= diffY*2;
          }
          else{
            zoomScale -= ZOOM_SPEED;
            currentX += diffX*2;
            currentY += diffY*2;
          }   
        }
        else{
          zoom = false;
          zoomState = !zoomState;
        }
      }
    }
    drawMain();
  }
}//end draw()

//Draw main
private void drawMain(){
  //Loop through all rectangles
  for(int i = 0; i < total; i++){
    fill(200);
    if(COLOR_SWITCH){
      String c = rects[i].getBgColor();
      fill(getRed(c),getGreen(c),getBlue(c));
    }
    if(rects[i].getSelected()){
      fill(0);
    }
    float x = rects[i].getXOffset();
    float y = rects[i].getYOffset();
    if(x == 0 && y == 0){
      x = rects[i].getX();
      y = rects[i].getY();
    }
    float s = rects[i].getSizeOffset();
    pushMatrix();
    rect(x, y, s, s, 4);
    popMatrix();
    fill(255);
    if(COLOR_SWITCH){
      String c = rects[i].getIconColor();
      fill(getRed(c),getGreen(c),getBlue(c));
    }
    s = s*0.75;
    textSize((float)Math.ceil(s));
    String str = "\\u"+rects[i].getIcon();
    Integer code = Integer.parseInt(str.substring(2), 16);
    char ch = Character.toChars(code)[0];
    text(ch, x + s/4, y + s);
  }//end for(i rectangles) 
}//end drawMain()

private void zoom(){
  //println(currentX + " " + currentY);
  for(int i = 0; i < total; i++){
    float x = rects[i].getX();
    float y = rects[i].getY();
    float s = rects[i].getSize();
    x = (x-currentX)*zoomScale;
    y = (y-currentY)*zoomScale;
    rects[i].setXOffset((int)x);
    rects[i].setYOffset((int)y);
    rects[i].setSizeOffset(s*zoomScale);
  }//end for(i rectangles) 
}

//Check for a clicked rect
private void checkClick() {
  //Loop all rects
  for(int i = 0; i < total; i++){
    boolean check = overRect(rects[i].getX(), rects[i].getY(), rects[i].getSize(), rects[i].getSize());
    if(SELECT_TYPE == 1){
      check = overRect(rects[i].getXOffset(), rects[i].getYOffset(), rects[i].getSize()*MAX_ZOOM, rects[i].getSize()*MAX_ZOOM);
    }
    if(check){
      rects[i].setSelected(!rects[i].getSelected());
      redraw = true;
    }
    if(!check && rects[i].getSelected()){
      rects[i].setSelected(false);
      redraw = true;
    }
  }//end for(i rects)
}

//Set origin
private void setOrigin(){
  originX = selectedX - width/4;
  originY = selectedY - height/4;
  diffX = (currentX - originX)/(MAX_ZOOM/ZOOM_SPEED);
  diffY = (currentY - originY)/(MAX_ZOOM/ZOOM_SPEED);
}

//Calculate new rect positions
private void zoomSetup(){
  int count = 0;
  for(float i = 0; i < cols; i++){
    for(float j = 0; j < rows; j++){
      float x = rects[count].getX();
      float y = rects[count].getY();
      if(!zoomState){
        x = ((x-currentX)*MAX_ZOOM) + (SPACE*i) + X_MARGIN;
        y = ((y-currentY)*MAX_ZOOM) + (SPACE*j) + Y_MARGIN;
      }
      count++;
    }//endFor(j rows)
  }//endFor(i cols)
}

//Update 'cursor' location on click 
void mousePressed() {
  if(!zoom){
    selectedX = mouseX;
    selectedY = mouseY;
    click = true;
  }
}

//Return true if the 'cursor' is over a given rectangle
private boolean overRect(float x, float y, float w, float h)  {
  if(SELECT_TYPE == 0){
   if (selectedX >= x && selectedX <= x+w &&
      selectedY >= y && selectedY <= y+h) {
      return true;
   } 
  }
  if(SELECT_TYPE == 1){
   if (selectedX >= x && selectedX <= x+w &&
      selectedY >= y && selectedY <= y+h) {
      return true;
   } 
  }
  return false;
}

private int getRed(String s){
  return Integer.valueOf( s.substring( 0, 2 ), 16 );
}
private int getGreen(String s){
  return Integer.valueOf( s.substring( 2, 4 ), 16 );
}
private int getBlue(String s){
  return Integer.valueOf( s.substring( 4, 6 ), 16 );
}
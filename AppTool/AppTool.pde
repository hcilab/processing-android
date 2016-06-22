private Scene scene;
private boolean COLOR_SWITCH = true;
private int SIZE = 30;
private int SPACE = 30;
private int X_MARGIN = 10;
private int Y_MARGIN = 10;
private int MAX_ZOOM = 2;
private float ZOOM_SPEED = 10;
private int rows;
private int cols;
private int total;
private int zoom;
private float selectedX;
private float selectedY;
private float cursorX;
private float cursorY;
private boolean click;
private boolean redraw;
private boolean zoomState;
private float xPan;
private float yPan;
private String colorList[] = {"FFFF00","008744","FFC0CB","8B4513","0057e7","d62d20","ffa700","00FFFF","808000","00FF00","FF8080","2277DD","FF00FF","800080","FFD700","0000FF","FF1493","FF8C00","5F9EA0","800000"};
private Sprite rects[];
void setup() {
  //Set window settings and calculate number of app tiles to generate
  size(480,800,P3D);
  scene = new Scene();
  redraw = true;
  int xSpace = SIZE + SPACE;
  int ySpace = SIZE + SPACE;
  rows = ((height + SPACE - (SIZE+(Y_MARGIN*2)))/(ySpace));
  cols = ((width + SPACE - (SIZE+(X_MARGIN*2)))/(xSpace));
  total = (rows*cols);
  int xOffset = (width + SPACE + (X_MARGIN*2) - (cols*(xSpace) + (X_MARGIN*2)))/2;
  int yOffset = (height + SPACE + (Y_MARGIN*2) - (rows*(ySpace) + (Y_MARGIN*2)))/2;
  rects = new Sprite[rows*cols];
  smooth();
  background(255);
  
  //Create app rectangles
  int count = 0;
  int temp = 33;
  for(float i = 0; i < cols; i++){
    for(float j = 0; j < rows; j++){
      Sprite s = new Sprite(Integer.toString(count));
      s.setSize(SIZE);
      s.setTranslation(new PVector(((float)(i * xSpace) + xOffset) - (width/2 + X_MARGIN), ((float)(j * ySpace) + yOffset) - (height/2 + Y_MARGIN), 100.0f));
      s.setBGColor(color(200)); 
      if(COLOR_SWITCH){
        String c = colorList[count%20];
        s.setBGColor(color(getRed(c),getGreen(c),getBlue(c))); 
        c = colorList[(count+1)%20];
        s.setIconColor(color(getRed(c),getGreen(c),getBlue(c))); 
      }
      s.setIcon(Long.toHexString(temp));
      scene.addSprite(s);
      rects[count] = s;
      count++;
      temp++;
      if(temp - 33 > 93){
        temp = 33;
      }
    }//endFor(j rows)
  }//endFor(i cols)
  scene.getOrthographicCamera().setNear(-1000f);
}

boolean flip = false;

void draw() {
   if(click){
    if(!zoomState){
      xPan = (selectedX - width/2)/((width/4)/ZOOM_SPEED);
      yPan = (selectedY - height/2)/((width/4)/ZOOM_SPEED);
      zoom = 1;
      click = false;
      redraw = true;
    }
    if(zoomState){
      zoom = -1;
      click = false;
      redraw = true;
      checkClick();
    }
   }
  
  if(redraw){
    IOrthographicCamera cam = scene.getOrthographicCamera();
    background(255);
    if(zoom == 1){
      if((((cam.getRight() - cam.getLeft())/width)) < (float)1/MAX_ZOOM){
        zoom = 0;
        zoomState = true;
        redraw = false;
      }
      else{
        cam.setRight((cam.getRight() - ZOOM_SPEED) + xPan);
        cam.setLeft(cam.getLeft() + ZOOM_SPEED + xPan);
        cam.setTop((cam.getTop() - (float)(ZOOM_SPEED*height)/width) - yPan);
        cam.setBottom((cam.getBottom() + (float)(ZOOM_SPEED*height)/width) - yPan);
      }
    }
    if(zoom == -1){
      if((cam.getRight() - cam.getLeft())/width > 1){
        zoom = 0;
        zoomState = false;
        redraw = false;
      }
      else{
        cam.setRight((cam.getRight() + ZOOM_SPEED) - xPan);
        cam.setLeft((cam.getLeft() - ZOOM_SPEED) - xPan);
        cam.setTop((cam.getTop() + (float)(ZOOM_SPEED*height)/width) + yPan);
        cam.setBottom((cam.getBottom() - (float)(ZOOM_SPEED*height)/width) + yPan);
      }
    }
    scene.render(); 
  }
}

void mousePressed() {
  if(zoom == 0){
    selectedX = mouseX;
    selectedY = mouseY;
    click = true;
  }
}

//Check for a clicked rect
private void checkClick() {
  setCursor(); //<>//
  for(int i = 0; i < total; i++){
    if((cursorX)  > (rects[i].getTranslation().x) 
    && (cursorX)  < (rects[i].getTranslation().x + ((SIZE))) 
    && (cursorY)  > (rects[i].getTranslation().y)
    && (cursorY)  < (rects[i].getTranslation().y + ((SIZE))))
    {
      rects[i].setSelected(true);
    }
    else{
      rects[i].setSelected(false);
    }
  }//end for(i rects)
}

private void setCursor(){
  IOrthographicCamera cam = scene.getOrthographicCamera();
  cursorX = ((selectedX/width)*(cam.getRight() - cam.getLeft()) + cam.getLeft());
  cursorY = -((selectedY/height)*(cam.getBottom() - cam.getTop()) + cam.getTop());
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
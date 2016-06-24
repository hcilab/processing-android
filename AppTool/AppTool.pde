//Custom variables
private int SELECT_TYPE = 2; // 0: Standard Select,  1: Zoom Select,  2: Grid Select 
private boolean COLOR_SWITCH = true; //True: Colored tiles,  false: Grey tiles
private int SIZE = 30; //Desired pixel width and height of square tiles
private int SPACE = 30; //Desired pixel spacing between tiles
private int X_MARGIN = 10; //Desired minimum pixel space from edge of window (X axis)
private int Y_MARGIN = 10; //Desired minimum pixel space from edge of window (Y axis)
private int MAX_ZOOM = 2; //Desired zoom magnification for zoom selection type (2 = x2 zoom) Can be unstable if selecting other values.
private float ZOOM_SPEED = 10; //Desired speed for zoom select function. This is a coefficient that contributes to zoom calculations on each frame of a zoom. Can be unstable if selected other (mostly large). 
/*
Note: Zooming unstability comes from my poor implementation of the zoom function. It currently finds the desired "end result" for the camera position, then shifts incrementally toward it each frame. 
Ideally, the camera should snap to this "destination frame" when it is less than a frame increment away, but it just stops instead. 
I avoided this because I ran into issues with snapping to an end destination being too perceptible, but there may be a way to decrease the increment-per-frame amount near the end of the zoom to have a smooth transition instead of an abrupt snap.
*/

//Hardcoded array of aribitrary hexadecimal color values that contrast fairly well. I didn't spend too much time making these perfect.
private String colorList[] = {"AAAA44","008744","FFC0FF","8B4513","0057e7","36A0A4","F73799","00FFFF","8080F0","00FF00","FF8080","2277DD","FF00FF","800080","FFD700","0000FF","BB3493","FF8C00","6FC4A0","800000"};

//Other variables
private Scene scene; //David's brilliant Scene object
private Sprite rects[]; //An array of Sprite objects to hold data related to each tile
private int rows; //Number of rows
private int cols; //Number of columns
private int total; //Total number of tiles
private int zoom; //Zoom flag to indicate if: 0: Not zooming,  1: Zooming in,  -1: Zooming out
private float selectedX; //X coordinate of the mouse cursor upon click (relative to application window)
private float selectedY; //Y coordinate of the mouse cursor upon click (relative to application window)
private float cursorX; //X coordinate of the mouse cursor upon click (relative to game world)
private float cursorY; //Y coordinate of the mouse cursor upon click (relative to game world)
private boolean click; //Click flag to indicate when a click has occurred
private boolean redraw; //Flag to indicate when world should be redrawn
private boolean zoomState; //Flag to indicate the current zoom state: true: Zoomed,  false: Unzoomed
private float xPan; //Variable used to pan camera toward a selected area. Amount to be incremented on the X axis
private float yPan; //Variable used to pan camera toward a selected area. Amount to be incremented on the Y axis

//Setup method
void setup() {
  //Set window settings
  size(480,800,P3D);
  smooth();
  background(255);
  
  //Instantiate Scene and set camera settings
  scene = new Scene();
  scene.getOrthographicCamera().setNear(-1000f);
  
  //Redraw on start
  redraw = true;
 
  //Calculate number of tiles to generate, spacing, sizing, layout, etc.
  int xSpace = SIZE + SPACE;
  int ySpace = SIZE + SPACE;
  rows = ((height + SPACE - (SIZE+(Y_MARGIN*2)))/(ySpace));
  cols = ((width + SPACE - (SIZE+(X_MARGIN*2)))/(xSpace));
  total = (rows*cols);
  int xOffset = (width + SPACE + (X_MARGIN*2) - (cols*(xSpace) + (X_MARGIN*2)))/2;
  int yOffset = (height + SPACE + (Y_MARGIN*2) - (rows*(ySpace) + (Y_MARGIN*2)))/2;
  rects = new Sprite[rows*cols];

  //Create app rectangles
  int count = 0; //Index variable
  int temp = 33; //Hardcoded first usable unicode icon index
  
  //Set appropriate amount, size, positions of tiles and store info about each into a new Sprite object
  for(float i = 0; i < cols; i++){
    for(float j = 0; j < rows; j++){
      
      Sprite s = new Sprite(Integer.toString(count));
      
      s.setSize(SIZE);
      s.setTranslation(new PVector(((float)(i * xSpace) + xOffset) - (width/2 + X_MARGIN), ((float)(j * ySpace) + yOffset) - (height/2 + Y_MARGIN), 100.0f));
      s.setIcon(Long.toHexString(temp));
      
      s.setBGColor(color(200)); //Default grey BG color (default icon color is white and already set in Scenes)
      
      //Set colors if enabled
      if(COLOR_SWITCH){
        String c = colorList[count%20];
        s.setBGColor(color(getRed(c),getGreen(c),getBlue(c))); 
        c = colorList[(count+1)%20];
        s.setIconColor(color(getRed(c),getGreen(c),getBlue(c))); 
      }
      
      scene.addSprite(s);
      rects[count] = s;
      
      count++;
      temp++;
      
      //Recycle icons if end of icons reached (Hardcoded values)
      if(temp - 33 > 93){
        temp = 33;
      }
    }//endFor(j rows)
  }//endFor(i cols)
}//end setup()

//Draw method
void draw() {
  //Code to run on a click event
  if(click){ //<>//
    click = false;
    redraw = true;
    
    //Standard selection type 
     if(SELECT_TYPE == 0){
        checkClick();
     }
     
     //Zoom selection type
     else  
     if(SELECT_TYPE == 1){
       
         //Not zoomed, set up zoom and start zooming
         if(!zoomState){
          xPan = (selectedX - width/2)/((width/4)/ZOOM_SPEED);
          yPan = (selectedY - height/2)/((width/4)/ZOOM_SPEED);
          zoom = 1;
        }
        
        //Zoomed, set up unzoom and start unzooming
        else{
          checkClick();
          zoom = -1;
        }
      }
      
     //Grid selection type (Active grid display will be synonymous with "zoom" in terms of zoom states)
     else 
     if(SELECT_TYPE == 2){
       
       //Not zoomed, set up zoom and start zooming
       if(!zoomState){
         findGrid();
         setGrid();
         resetSelect();
       }
       
       //Zoomed, set up unzoom and start unzooming
       else{
         checkClick();
         resetGrid();  
       }
       zoomState = !zoomState;
     }
   }
  
  //Code to run on a redraw event
  if(redraw){
    redraw = false;
    IOrthographicCamera cam = scene.getOrthographicCamera();
    background(255);
    
    //Zoom selection type
    if(SELECT_TYPE == 1){
      
      //Run while zooming in
      if(zoom == 1){
        
        //If zoom-in complete (Currently not perfect on "completeness")
        if((((cam.getRight() - cam.getLeft())/width)) < (float)1/MAX_ZOOM){
          zoom = 0;
          zoomState = true;
        }
        
        //Else zoom in more
        else{
          redraw = true;
          cam.setRight((cam.getRight() - ZOOM_SPEED) + xPan);
          cam.setLeft(cam.getLeft() + ZOOM_SPEED + xPan);
          cam.setTop((cam.getTop() - (float)(ZOOM_SPEED*height)/width) - yPan);
          cam.setBottom((cam.getBottom() + (float)(ZOOM_SPEED*height)/width) - yPan);
        }
      }
      //Run while zooming out
      if(zoom == -1){
        
        //If zoom-out complete (Currently not perfect on "completeness")
        if((cam.getRight() - cam.getLeft())/width > 1){
          zoom = 0;
          zoomState = false;
        }
        
        //Else zoom out more
        else{
          redraw = true;
          cam.setRight((cam.getRight() + ZOOM_SPEED) - xPan);
          cam.setLeft((cam.getLeft() - ZOOM_SPEED) - xPan);
          cam.setTop((cam.getTop() + (float)(ZOOM_SPEED*height)/width) + yPan);
          cam.setBottom((cam.getBottom() - (float)(ZOOM_SPEED*height)/width) + yPan);
        }
      }
    }
    //Render sprites based on camera position
    scene.render(); 
  }
}

//Set click variables when a click occurs
void mousePressed() {
  if(zoom == 0 || SELECT_TYPE == 2){
    selectedX = mouseX;
    selectedY = mouseY;
    click = true;
  }
}

//Check for a clicked tile
private void checkClick() {
  setCursor();
  
  //For each tile, check if the cursor is over it
  //If it is, set the tile to "selected"
  //"Selected" tiles are set to be black and white (can be changed in Sprite code in Scenes) 
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

//Deselects all tiles
private void resetSelect(){ 
  for(int i = 0; i < total; i++){
     rects[i].setSelected(false);
  }//end for(i rects)
}

//Selects a grid of tiles based on click location
private void findGrid(){
  setCursor();
  int center = 0; //Index of the calculated "center of grid" tile
  int centerI = 0; //Column number of center tile
  int centerJ = 0; //Row number of center tile
  int count = 0; //Index counter variable
  
  //Increment through all rows and columns
  //Use Pythagorean Theorem to determine which sprite is the closest to the selection point
  for(int i = 0; i < cols; i++){
    for(int j = 0; j < rows; j++){
      float diffX = (float)Math.pow((rects[count].getTranslation().x + SIZE/2)- cursorX, 2); //Distance between cursor and sprite on the x axis
      float diffY = (float)Math.pow((rects[count].getTranslation().y + SIZE/2) - cursorY, 2); //Distance between cursor and sprite on the y axis
      float minDiffX = (float)Math.pow((rects[center].getTranslation().x + SIZE/2) - cursorX, 2); //Distance between cursor and current closest sprite on the x axis 
      float minDiffY = (float)Math.pow((rects[center].getTranslation().y + SIZE/2) - cursorY, 2); //Distance between cursor and current closest sprite on the y axis
      if(Math.sqrt(diffX + diffY) < Math.sqrt(minDiffX + minDiffY)){
        centerI = i;
        centerJ = j;
        center = count;
      }
      count++;
    }//endFor(j rows)
  }//endFor(i cols)
  count = 0; //Reset index counter
  //Iterate through all tiles again and set closest tile and surrounding tiles to "in grid"
  for(float i = 0; i < cols; i++){
    for(float j = 0; j < rows; j++){
      if(i >= centerI - 1 && i <= centerI + 1 && j >= centerJ - 1 && j <= centerJ + 1){
        rects[count].setInGrid(true); 
      }
      count++;
    }//endFor(j rows)
  }//endFor(i cols)
  
  //Set pan variables for new camera position
  xPan = (rects[center].getTranslation().x + SIZE/2);
  yPan = (rects[center].getTranslation().y + SIZE/2);
}

//Sets camera for a grid select
//Whites out sprites not within grid and centers camera on grid
private void setGrid(){
  
  //Shift camera
  IOrthographicCamera cam = scene.getOrthographicCamera();
  cam.setLeft(cam.getLeft() + xPan + 100000/height);
  cam.setRight(cam.getRight() + xPan - 100000/height);
  cam.setTop(cam.getTop() - yPan - 100000/width);
  cam.setBottom(cam.getBottom() - yPan + 100000/width);
  
  //White out sprites
  for(int i = 0; i < total; i++){
    if(!rects[i].getInGrid()){
      rects[i].setBGColor(color(255));
      rects[i].setIconColor(color(255));
      rects[i].getSquare().setStroke(false);
    }
    else{
      rects[i].setInGrid(false); 
    }
  }//end for(i rects)
}

//Resets camera after a grid select
//Resets sprites not within grid and resets camera position
private void resetGrid(){
  
  //Reset camera position
  IOrthographicCamera cam = scene.getOrthographicCamera();
  cam.setLeft(cam.getLeft() - xPan - 100000/height);
  cam.setRight(cam.getRight() - xPan + 100000/height);
  cam.setTop(cam.getTop() + yPan + 100000/width);
  cam.setBottom(cam.getBottom() + yPan - 100000/width);
  
  //Reset sprite colors
  for(int i = 0; i < total; i++){
    if(!rects[i].getInGrid()){
      rects[i].setBGColor(color(200)); 
      if(COLOR_SWITCH){
        String c = colorList[i%20];
        rects[i].setBGColor(color(getRed(c),getGreen(c),getBlue(c))); 
        c = colorList[(i+1)%20];
        rects[i].setIconColor(color(getRed(c),getGreen(c),getBlue(c))); 
      }
      rects[i].getSquare().setStroke(true);
    }
  }//end for(i rects)
}

//Translates cursor coordinates into "game world"
private void setCursor(){
  IOrthographicCamera cam = scene.getOrthographicCamera();
  cursorX = ((selectedX/width)*(cam.getRight() - cam.getLeft()) + cam.getLeft());
  cursorY = -((selectedY/height)*(cam.getBottom() - cam.getTop()) + cam.getTop());
}


//Color hex string parsing methods
private int getRed(String s){
  return Integer.valueOf( s.substring( 0, 2 ), 16 );
}
private int getGreen(String s){
  return Integer.valueOf( s.substring( 2, 4 ), 16 );
}
private int getBlue(String s){
  return Integer.valueOf( s.substring( 4, 6 ), 16 );
}
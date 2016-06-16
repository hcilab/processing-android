class AppRectangle{
  //Vars
  private int id;
  private float x;
  private float y;
  private float size;
  private float xOffset;
  private float yOffset;
  private float sizeOffset;
  private String bgColor;
  private String icon;
  private String iconColor;
  private boolean selected;
  
  //Construct
  public AppRectangle(int idIn, float xIn, float yIn, float sizeIn, String bgColorIn, String iconIn, String iconColorIn){
    id = idIn; 
    x = xIn;
    y = yIn;
    size = sizeIn;
    xOffset = 0;
    yOffset = 0;
    sizeOffset = size;
    bgColor = bgColorIn;
    icon = iconIn;
    iconColor = iconColorIn;
    selected = false;
  }
  
  //Get
  public float getID(){
    return id;
  }  
  public float getX(){
    return x;
  }  
  public float getY(){
    return y;
  }
  public float getSize(){
    return size;
  }
  public float getXOffset(){
    return xOffset;
  }  
  public float getYOffset(){
    return yOffset;
  }
  public float getSizeOffset(){
    return sizeOffset;
  }
  public String getBgColor(){
    return bgColor;
  }
  public String getIcon(){
    return icon;
  }
  public String getIconColor(){
    return iconColor;
  }
  public boolean getSelected(){
    return selected;
  }
  
  //Set
  public void setXOffset(int xIn){
    xOffset = xIn;
  }
  public void setYOffset(int yIn){
    yOffset = yIn;
  }  
  public void setSizeOffset(float sizeIn){
    sizeOffset = sizeIn;
  }   
  public void setBgColor(String bgColorIn){
    bgColor = bgColorIn;
  }
  public void setIcon(String iconIn){
    icon = iconIn;
  }
  public void setIconColor(String iconColorIn){
    iconColor = iconColorIn;
  }  
  public void setSelected(boolean selectedIn){
    selected = selectedIn;
  }
}
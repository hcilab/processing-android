//======================================================================================================
// Author: David Hanna (Sprite section edited by Alex Kienzle)
//
// An module responsible for rendering a collection of objects to the screen.
//======================================================================================================

import java.util.Map;

//------------------------------------------------------------------------------------------------------
// INTERFACE
//------------------------------------------------------------------------------------------------------

public interface ICamera
{
  public PVector getPosition();
  public PVector getTarget();
  public PVector getUp();
  
  public void setPosition(PVector position);
  public void setTarget(PVector target);
  public void setUp(PVector up);
  
  public void setToDefaults();
  
  public void apply();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonCamera);
}

public interface IPerspectiveCamera extends ICamera
{
  public float getFieldOfView();
  public float getAspectRatio();
  public float getNear();
  public float getFar();
  
  public void setFieldOfView(float fieldOfView);
  public void setAspectRatio(float aspectRatio);
  public void setNear(float near);
  public void setFar(float far);
}

public interface IOrthographicCamera extends ICamera
{
  public float getLeft();
  public float getRight();
  public float getBottom();
  public float getTop();
  public float getNear();
  public float getFar();
  
  public void setLeft(float left);
  public void setRight(float right);
  public void setBottom(float bottom);
  public void setTop(float top);
  public void setNear(float near);
  public void setFar(float far);
}

public interface ISprite
{
  public String getName();
  
  public PVector getTranslation();
  public float getRotation();
  public PVector getScale();
  
  public float getSize();
  public color getBGColor();
  public boolean getSelected();
  
  public void setTranslation(PVector translation);
  public void setRotation(float rotation);
  public void setScale(PVector scale);
  
  public void setSize(float size);
  public void setBGColor(color bgColor);
  public void setSelected(boolean selected);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonSprite);
}

public interface IModel
{
  public void fromOBJ(String objFileName);
  
  public String getName();
  
  public PVector getTranslation();
  public PVector getRotation();
  public PVector getScale();
  
  public float getSize();
  public color getBGColor();
  public boolean getSelected();
  
  public void setTranslation(PVector translation);
  public void setRotation(PVector rotation);
  public void setScale(PVector scale);
  
  public void setSize(float size);
  public void setBGColor(color bgColor);
  public void setSelected(boolean selected);
  
  public void render();
  
  public JSONObject serialize();
  public void deserialize(JSONObject jsonModel);
}

public interface IScene
{
  public IOrthographicCamera getOrthographicCamera();
  public void setOrthographicCamera(IOrthographicCamera orthographicCamera);
  
  public IPerspectiveCamera getPerspectiveCamera();
  public void setPerspectiveCamera(IPerspectiveCamera perspectiveCamera);
  
  public void addSprite(ISprite sprite);
  public ISprite getSprite(String name);
  public void removeSprite(String name);
  
  public void addModel(IModel model);
  public IModel getModel(String name);
  public void removeModel(String name);
  
  public void render();
}

//------------------------------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------------------------------

public abstract class Camera implements ICamera
{
  private PVector position;
  private PVector target;
  private PVector up;
  
  public Camera()
  {
    setToDefaults();
  }
  
  public PVector getPosition()
  {
    return position;
  }
  
  public PVector getTarget()
  {
    return target;
  }
  
  public PVector getUp()
  {
    return up;
  }
  
  public void setPosition(PVector _position)
  {
    position = _position;
  }
  
  public void setTarget(PVector _target)
  {
    target = _target;
  }
  
  public void setUp(PVector _up)
  {
    up = _up;
  }
  
  public void setToDefaults()
  {
    position = new PVector(0.0f, 0.0f, 0.0f);
    target = new PVector(0.0f, 0.0f, -1.0f);
    up = new PVector(0.0f, 1.0f, 0.0f);
  }
  
  public void apply()
  {
    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
  }
  
  public JSONObject serialize()
  {
    JSONObject jsonPosition = new JSONObject();
    jsonPosition.setFloat("x", position.x);
    jsonPosition.setFloat("y", position.y);
    jsonPosition.setFloat("z", position.z);
    
    JSONObject jsonTarget = new JSONObject();
    jsonTarget.setFloat("x", target.x);
    jsonTarget.setFloat("y", target.y);
    jsonTarget.setFloat("z", target.z);
    
    JSONObject jsonUp = new JSONObject();
    jsonUp.setFloat("x", up.x);
    jsonUp.setFloat("y", up.y);
    jsonUp.setFloat("z", up.z);
    
    JSONObject jsonCamera = new JSONObject();
    jsonCamera.setJSONObject("position", jsonPosition);
    jsonCamera.setJSONObject("target", jsonTarget);
    jsonCamera.setJSONObject("up", jsonUp);
    
    return jsonCamera;
  }
  
  public void deserialize(JSONObject jsonCamera)
  {
    JSONObject jsonPosition = jsonCamera.getJSONObject("position");
    JSONObject jsonTarget = jsonCamera.getJSONObject("target");
    JSONObject jsonUp = jsonCamera.getJSONObject("up");
    
    position.x = jsonPosition.getFloat("x");
    position.y = jsonPosition.getFloat("y");
    position.z = jsonPosition.getFloat("z");
    
    target.x = jsonTarget.getFloat("x");
    target.y = jsonTarget.getFloat("y");
    target.z = jsonTarget.getFloat("z");
    
    up.x = jsonUp.getFloat("x");
    up.y = jsonUp.getFloat("y");
    up.z = jsonUp.getFloat("z");
  }
}

public class PerspectiveCamera extends Camera implements IPerspectiveCamera
{
  private float fieldOfView;
  private float aspectRatio;
  private float near;
  private float far;
  
  public PerspectiveCamera()
  {
    setToDefaults();
  }
  
  public float getFieldOfView()
  {
    return fieldOfView;
  }
  
  public float getAspectRatio()
  {
    return aspectRatio;
  }
  
  public float getNear()
  {
    return near;
  }
  
  public float getFar()
  {
    return far;
  }
  
  public void setFieldOfView(float _fieldOfView)
  {
    fieldOfView = _fieldOfView;
  }
  
  public void setAspectRatio(float _aspectRatio)
  {
    aspectRatio = _aspectRatio;
  }
  
  public void setNear(float _near)
  {
    near = _near;
  }
  
  public void setFar(float _far)
  {
    far = _far;
  }
  
  public void setToDefaults()
  {
    super.setToDefaults();
    
    fieldOfView = PI / 3.0f;
    aspectRatio = 4.0f / 3.0f;
    near = 0.1f;
    far = 1000.0f;
  }
  
  public void apply()
  {
    super.apply();
    
    perspective(fieldOfView, aspectRatio, near, far);
  }
  
  public JSONObject serialize()
  {
    JSONObject jsonPerspectiveCamera = super.serialize();
    
    jsonPerspectiveCamera.setFloat("fieldOfView", fieldOfView);
    jsonPerspectiveCamera.setFloat("aspectRatio", aspectRatio);
    jsonPerspectiveCamera.setFloat("near", near);
    jsonPerspectiveCamera.setFloat("far", far);
    
    return jsonPerspectiveCamera;
  }
  
  public void deserialize(JSONObject jsonPerspectiveCamera)
  {
    super.deserialize(jsonPerspectiveCamera);
    
    fieldOfView = jsonPerspectiveCamera.getFloat("fieldOfView");
    aspectRatio = jsonPerspectiveCamera.getFloat("aspectRatio");
    near = jsonPerspectiveCamera.getFloat("near");
    far = jsonPerspectiveCamera.getFloat("far");
  }
}

public class OrthographicCamera extends Camera implements IOrthographicCamera
{
  private float left;
  private float right;
  private float bottom;
  private float top;
  private float near;
  private float far;
  
  public OrthographicCamera()
  {
    setToDefaults();
  }
  
  public float getLeft()
  {
    return left;
  }
  
  public float getRight()
  {
    return right;
  }
  
  public float getBottom()
  {
    return bottom;
  }
  
  public float getTop()
  {
    return top;
  }
  
  public float getNear()
  {
    return near;
  }
  
  public float getFar()
  {
    return far;
  }
  
  public void setLeft(float _left)
  {
    left = _left;
  }
  
  public void setRight(float _right)
  {
    right = _right;
  }
  
  public void setBottom(float _bottom)
  {
    bottom = _bottom;
  }
  
  public void setTop(float _top)
  {
    top = _top;
  }
  
  public void setNear(float _near)
  {
    near = _near;
  }
  
  public void setFar(float _far)
  {
    far = _far;
  }
  
  public void setToDefaults()
  {
    super.setToDefaults();
    
    left = -width / 2.0f;
    right = width / 2.0f;
    bottom = -height / 2.0f;
    top = height / 2.0f;
    float cameraZ = ((height / 2.0f) / tan(PI * 60.0f / 360.0f));
    near = cameraZ / 10.0f;
    far = cameraZ * 10.0f;
  }
  
  public void apply()
  {
    super.apply();
    ortho(left, right, bottom, top, near, far);
  }
  
  public JSONObject serialize()
  {
    JSONObject jsonOrthographicCamera = super.serialize();
    
    jsonOrthographicCamera.setFloat("left", left);
    jsonOrthographicCamera.setFloat("right", right);
    jsonOrthographicCamera.setFloat("bottom", bottom);
    jsonOrthographicCamera.setFloat("top", top);
    jsonOrthographicCamera.setFloat("near", near);
    jsonOrthographicCamera.setFloat("far", far);
    
    return jsonOrthographicCamera;
  }
  
  public void deserialize(JSONObject jsonOrthographicCamera)
  {
    super.deserialize(jsonOrthographicCamera);
    
    left = jsonOrthographicCamera.getFloat("left");
    right = jsonOrthographicCamera.getFloat("right");
    bottom = jsonOrthographicCamera.getFloat("bottom");
    top = jsonOrthographicCamera.getFloat("top");
    near = jsonOrthographicCamera.getFloat("near");
    far = jsonOrthographicCamera.getFloat("far");
  }
}

public class Sprite implements ISprite
{
  private String name;
  
  private PShape square = createShape(RECT, 0, 0, 1, 1);;
  
  private PVector translation;
  private float rotation;
  private PVector scale;
  
  private float size;
  private color bgColor;
  private boolean selected; 
  private String icon;
  private color iconColor;
  private boolean inGrid;
  
  public Sprite(String _name)
  {
    name = _name;  //<>// //<>// //<>//
    
    translation = new PVector();
    rotation = 0.0f;
    scale = new PVector(1.0f, 1.0f);
    
    size = 0.0;
    bgColor = color(255, 255, 255);
    selected = false;
    icon = "";
    iconColor = color(255, 255, 255);
    square.setStroke(color(0));
    square.setStrokeWeight(0.002);
    inGrid = false;
  }
  
  public Sprite(JSONObject jsonSprite)
  {
    deserialize(jsonSprite);
  }
  
  public String getName()
  {
    return name;
  }
  
  public PShape getSquare()
  {
    return square;
  }
  
  public PVector getTranslation()
  {
    return translation;
  }
  
  public float getRotation()
  {
    return rotation;
  }
  
  public PVector getScale()
  {
    return scale;
  }
  
  public float getSize()
  {
    return size;
  }
  
  public color getBGColor()
  {
    return bgColor;
  }
  
  public boolean getSelected()
  {
    return selected;
  }
  
  public String getIcon()
  {
    return icon;
  }
  
  public color getIconColor()
  {
    return iconColor;
  }
  
  public boolean getInGrid()
  {
    return inGrid;
  }
  
  public void setTranslation(PVector _translation)
  {
    translation = _translation;
  }
  
  public void setRotation(float _rotation)
  {
    rotation = _rotation;
  }
  
  public void setScale(PVector _scale)
  {
    scale = _scale;
  }
  
  public void setSize(float _size)
  {
    size = _size;
    square.scale(size);
  }
  
  public void setBGColor(color _bgColor)
  {
    bgColor = _bgColor;
  }
  
  public void setSelected(boolean _selected)
  {
    selected = _selected;
  }  
  public void setIcon(String _icon)
  {
    icon = _icon;
  }
  
  public void setIconColor(color _iconColor)
  {
    iconColor = _iconColor;
  }
  
  public void setInGrid(boolean _inGrid)
  {
    inGrid = _inGrid;
  }
  
  public void render()
  {
    pushMatrix();
    translate(translation.x, translation.y, translation.z);
    rotateZ(rotation);
    scale(scale.x, scale.y, scale.z);
    square.setFill(bgColor);
    if(selected){
      square.setFill(color(0));
    }
    shape(square, 0, 0);
    float s = size*0.75;
    textSize((float)Math.ceil(s));
    String str = "\\u"+ icon;
    Integer code = Integer.parseInt(str.substring(2), 16);
    char ch = Character.toChars(code)[0];
    fill(iconColor);
    if(selected){
      fill(255);
    }
    text(ch, translation.x/(2*(size + 100)) + size/4, translation.y/(2*(size+100)) + size - size/4);
    popMatrix();
  }
  
  public JSONObject serialize()
  {
    return new JSONObject();
  }
  
  public void deserialize(JSONObject jsonSprite)
  {
    name = jsonSprite.getString("name");
  }
}



public class Scene implements IScene
{
  private IOrthographicCamera orthographicCamera;
  private IPerspectiveCamera perspectiveCamera;
  private HashMap<String, ISprite> sprites;
  private HashMap<String, IModel> models;
  
  public Scene()
  {
    orthographicCamera = new OrthographicCamera();
    perspectiveCamera = new PerspectiveCamera();
    sprites = new HashMap<String, ISprite>();
    models = new HashMap<String, IModel>();
  }
  
  public IOrthographicCamera getOrthographicCamera()
  {
    return orthographicCamera;
  }
  
  public void setOrthographicCamera(IOrthographicCamera _orthographicCamera)
  {
    orthographicCamera = _orthographicCamera;
  }
  
  public IPerspectiveCamera getPerspectiveCamera()
  {
    return perspectiveCamera;
  }
  
  public void setPerspectiveCamera(IPerspectiveCamera _perspectiveCamera)
  {
    perspectiveCamera = _perspectiveCamera;
  }
  
  public void addSprite(ISprite sprite)
  {
    sprites.put(sprite.getName(), sprite);
  }
  
  public ISprite getSprite(String name)
  {
    return sprites.get(name);
  }
  
  public void removeSprite(String name)
  {
    sprites.remove(name);
  }
  
  public void addModel(IModel model)
  {
    models.put(model.getName(), model);
  }
  
  public IModel getModel(String name)
  {
    return models.get(name);
  }
  
  public void removeModel(String name)
  {
    models.remove(name);
  }
  
  public void render()
  {
    orthographicCamera.apply();
    
    for (Map.Entry entry : sprites.entrySet())
    {
      ((ISprite)entry.getValue()).render();
    }
  }
}
//TODO - 
import java.util.*;

final float TURN_RIGHT = 0.07;
final float TURN_LEFT = -0.07;
SpaceShip ss;
Vector <Enemy> swarm;
Vector <Bullet> bullets;
float hiveMind = 0;
int counter = 0;
PFont thisFont;
boolean game = true;
int lives = 3;
boolean godMode = false;

public void setup() 
{
  size(750,600);
  frameRate(120);
  init();
}

public void init()
{
  ss = new SpaceShip();
  swarm = new Vector <Enemy> ();
  bullets = new Vector <Bullet> ();
  thisFont = createFont("Arial",16,true);
  counter = 0;
  lives = 3;
  godMode = false;
  game = true;
}
  
public void draw() 
{
	if (!game)
    return;
  if (lives <= 0)
  {
    background(0);
    textFont(thisFont,16);
    fill(255,0,0);
    textAlign(CENTER);
    textSize(100);
    text("GAME OVER",350,300);
    return;
  }
  background(128);
  fill(0,0,0);
  rect(0,500,750,100);
  if (frameCount%60==0)
  {
    hiveMind = (float)(Math.random()*(2*Math.PI));
    swarm.addElement(new Enemy());
  }
  for (int i = 0; i < swarm.size(); i++)
  {
    swarm.elementAt(i).changeDir(hiveMind);
    swarm.elementAt(i).draw_me(255,0,0);
  }
  for (int i = 0; i < bullets.size(); i++)
    bullets.elementAt(i).draw_me(0,0,255);
	ss.draw_me(0,255,0);
  for (int i = 0; i < swarm.size(); i++)
  {
    if (swarm.elementAt(i).rect_overlap(swarm.elementAt(i).X,swarm.elementAt(i).Y,20,ss.X,ss.Y,20) && !godMode)
    {
      swarm.remove(i);
      lives--;
      if (i > 0)
        i--;
    }
    for (int j = 0; j < bullets.size(); j++)
    {
      if (bullets.elementAt(j).alive)
      {
        if (swarm.elementAt(i).rect_overlap(swarm.elementAt(i).X,swarm.elementAt(i).Y,20,bullets.elementAt(j).X,bullets.elementAt(j).Y,10))
        {
          swarm.remove(i);
          bullets.remove(j);
          j = bullets.size();
          counter++;
        }
        else if (bullets.elementAt(j).rect_overlap(ss.X,ss.Y,20,bullets.elementAt(j).X,bullets.elementAt(j).Y,10) && godMode)
        {
          //bullets.remove(j);
          //lives--;
        }
      }
    }
  }
  textFont(thisFont,16);
    fill(255);
    textAlign(CENTER);
    textSize(50);
    text("Kills: " + counter + " Lives: " + lives,350,550);
}

class Bullet extends Floater2
{
  public Bullet ()
  {
    super ("Bullet", 8, (int)(ss.X+20*Math.cos(ss.degrees)),(int)((ss.Y+20*Math.sin(ss.degrees))),10);
  }
}

class Enemy extends Floater2
{
	public Enemy ()
	{
		super ("Enemy", 4, (int)(Math.random()*750),(int)(Math.random()*500),1);
	}

  protected void changeDir (float f)
  {
    degrees = f;
  }
}

class SpaceShip extends Floater2
{   
	public SpaceShip ()
	{
		super("SpaceShip", 3, 375, 250, 0);
	}

	protected void accelerate(int a)
	{
		velocity += a;
	}
}

void keyPressed()
{
	if (keyCode == LEFT)
		ss.steer(TURN_LEFT);
	else if (keyCode == RIGHT)
		ss.steer(TURN_RIGHT);
	else if (keyCode == UP)
		ss.accelerate(2);
	else if (keyCode == DOWN)
	{
		if (ss.velocity > 1)
			ss.accelerate(-2);
	}
  else if (key == 32)
    bullets.add(new Bullet());
  else if (key == 104)
  {
    ss.X = 375;
    ss.Y = 250;
    ss.velocity = 0;
  }
  else if (key == 112)
  {
    if (game)
      game = false;
    else
      game = true;
  }
  else if (key == 114)
    init();
  else if (key == 103)
  {
    if (godMode)
      godMode = false;
    else
      godMode = true;
  }
}

class Floater2
{
	protected boolean alive;
  protected String m_type;
	protected double degrees;
	protected int corner_num,velocity,X,Y;
	public Floater2(String s, int c_m, int x, int y, int v)
	{
		alive = true;
    m_type = s;
    if (s.equals("Bullet"))
      degrees  = ss.degrees;
		else
      degrees = 0;
		corner_num = c_m;
		X = x;
		Y = y;
		velocity = v;
	}
	protected void steer(float s)
	{
		degrees += s;
	}
  protected void die()
  {
    alive = false;
  }
	protected void draw_me(int r, int g, int b)
	{
		if (!alive)
      return;
    fill(r,g,b);
    if (!m_type.equals("Bullet") || godMode)
    {
      if (X <= 0 || X >= 750)
        X = 750-X;
      if (Y <= 0 || Y >= 500)
        Y = 500 -Y;
    }
    else
    {
      if (X <= 0 || X >= 750)
        die();
      if (Y <= 0 || Y >= 500)
        die();
    }
		X+=velocity*Math.cos(degrees);
		Y+=velocity*Math.sin(degrees);
    int m_radius;
    if (m_type.equals("Bullet"))
      m_radius = 10;
    else
      m_radius = 20;
		beginShape();
		for (int i = 0; i < corner_num; i++)
		{
			float increment = (float)(2*i*Math.PI/corner_num);
			vertex((float)(X+m_radius*Math.cos(degrees+increment)),(float)(Y+m_radius*Math.sin(degrees+increment)));
		}
		endShape(CLOSE);
    if (m_type.equals("SpaceShip"))
      ellipse((float)(X+20*Math.cos(degrees)),(float)((Y+20*Math.sin(degrees))),20,20);
	}
  public boolean rect_overlap(int x1, int y1, int size1, int x2, int y2, int size2)
  {
    //see if any of the corners_2 are contained in the first bounds
    //start with top left corner and go clockwise
    if (x2 > x1 && x2 < x1+size1)
      if (y2 > y1 && y2 < y1+size1)
        return true;
    if (x2+size2 > x1 && x2+size2 < x1+size1)
      if (y2 > y1 && y2 < y1+size1)
        return true;
    if (x2+size2 > x1 && x2+size2 < x1+size1)
      if (y2+size2 > y1 && y2+size2 < y1+size1)
        return true;
    if (x2 > x1 && x2 < x1+size1)
      if (y2+size2 > y1 && y2+size2 < y1+size1)
        return true;
    return false;
  }
}

abstract class Floater //Do NOT modify the Floater class! Make changes in the SpaceShip class 
{   
  protected int corners;  //the number of corners, a triangular floater has 3   
  protected int[] xCorners;   
  protected int[] yCorners;   
  protected int myColor;   
  protected double myCenterX, myCenterY; //holds center coordinates   
  protected double myDirectionX, myDirectionY; //holds x and y coordinates of the vector for direction of travel   
  protected double myPointDirection; //holds current direction the ship is pointing in degrees    
  abstract public void setX(int x);  
  abstract public int getX();   
  abstract public void setY(int y);   
  abstract public int getY();   
  abstract public void setDirectionX(double x);   
  abstract public double getDirectionX();   
  abstract public void setDirectionY(double y);   
  abstract public double getDirectionY();   
  abstract public void setPointDirection(int degrees);   
  abstract public double getPointDirection(); 

  //Accelerates the floater in the direction it is pointing (myPointDirection)   
  public void accelerate (double dAmount)   
  {          
    //convert the current direction the floater is pointing to radians    
    double dRadians =myPointDirection*(Math.PI/180);     
    //change coordinates of direction of travel    
    myDirectionX += ((dAmount) * Math.cos(dRadians));    
    myDirectionY += ((dAmount) * Math.sin(dRadians));       
  }   
  public void rotate (int nDegreesOfRotation)   
  {     
    //rotates the floater by a given number of degrees    
    myPointDirection+=nDegreesOfRotation;   
  }   
  public void move ()   //move the floater in the current direction of travel
  {      
    //change the x and y coordinates by myDirectionX and myDirectionY       
    myCenterX += myDirectionX;    
    myCenterY += myDirectionY;     

    //wrap around screen    
    if(myCenterX >width)
    {     
      myCenterX = 0;    
    }    
    else if (myCenterX<0)
    {     
      myCenterX = width;    
    }    
    if(myCenterY >height)
    {    
      myCenterY = 0;    
    }   
    else if (myCenterY < 0)
    {     
      myCenterY = height;    
    }   
  }   
  public void show ()  //Draws the floater at the current position  
  {             
    fill(myColor);   
    stroke(myColor);    
    //convert degrees to radians for sin and cos         
    double dRadians = myPointDirection*(Math.PI/180);                 
    int xRotatedTranslated, yRotatedTranslated;    
    beginShape();         
    for(int nI = 0; nI < corners; nI++)    
    {     
      //rotate and translate the coordinates of the floater using current direction 
      xRotatedTranslated = (int)((xCorners[nI]* Math.cos(dRadians)) - (yCorners[nI] * Math.sin(dRadians))+myCenterX);     
      yRotatedTranslated = (int)((xCorners[nI]* Math.sin(dRadians)) + (yCorners[nI] * Math.cos(dRadians))+myCenterY);      
      vertex(xRotatedTranslated,yRotatedTranslated);    
    }   
    endShape(CLOSE);  
  }   
}
import processing.serial.*;
import processing.sound.*;

float y_i = 265;
int y_d = 265;
float x_ball;
float y_ball;
final int PADDLE_SPEED = 8;
final int BALL_SPEED = 8;
final int BALL_SIZE = 20;
float ball_speed_x, ball_speed_y;
boolean pressed_up = false, pressed_down = false, pressed_w = false, pressed_s = false;
boolean partida_comenzada = false;

SoundFile reflect_sound, fail_sound;
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port


int tantos_i = 0, tantos_d = 0;
void setup()
{
    size(1000, 600);
    background(0);
    
    x_ball = 500;
    y_ball = 290;
    resetBall();
    
    reflect_sound = new SoundFile(this, "reflect.wav");
    fail_sound = new SoundFile(this, "fail.wav");
    
    String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
    myPort = new Serial(this, portName, 9600);
}
void resetBall()
{
    double angle = random(25, 155);
    ball_speed_x = (float) (BALL_SPEED *  Math.sin(Math.toRadians(angle)));
    if (random(2) > 1)
      ball_speed_x = -ball_speed_x;
    ball_speed_y = (float) (BALL_SPEED *  Math.cos(Math.toRadians(180 - angle)));
}
void draw() 
{
  //fill(0);
  background(0);
  
  // Texto
  textSize(32);
  textAlign(CENTER);
  text(String.format(tantos_i + " | " + tantos_d), 500, 30);
  
  if (!partida_comenzada)
  {
    textSize(32);
    fill(0, 255, 0);
    textAlign(CENTER);
    text("Apreta cualquiera tecla para empezar a jugar", 500, 200);
  }
  
  strokeCap(PROJECT);
  fill(255);
  stroke(0, 255, 255);
  strokeWeight(10);
  line(0, 50, 1000, 50);
  line(0, 580, 1000, 580);
  
  for (int i = 0; i < 11; ++i)
  {
    
    line(500, 55 + i * 50, 500, 55+i*50 + 20);
  }
    
  if (keyPressed == true && partida_comenzada)
  {
     if (pressed_up && y_d - PADDLE_SPEED >= 55)
       y_d -= PADDLE_SPEED;
     else if (pressed_down && y_d + PADDLE_SPEED <= 500)
       y_d += PADDLE_SPEED;
       
     
  }
  
  /*if (pressed_w && y_i - PADDLE_SPEED >= 55)
       y_i -= PADDLE_SPEED;
       
  else if (pressed_s && y_i + PADDLE_SPEED <= 500)
       y_i += PADDLE_SPEED;*/
       
  noStroke();

  if (myPort.available() > 0) 
         val = myPort.readStringUntil('\n');         // read it and store it in val
         
  if (val != null)
  {
          try
          {
                  Float dist = Float.parseFloat(val);
                  if (dist < 15)
                          dist = 15.f;
                  else if (dist > 40)
                          dist = 40.f;
                  y_i = 500 - map(dist, 15, 40, 5, 445);
                  println("" + dist + " cm");
          }
          catch (Exception e)
          {
              println(e);
          }
          
  }
  rect(50, y_i, 20, 80);
  rect(930, (int) y_d, 20, 80);

  
  ball_movement();
}
void ball_movement()
{ 
  if (partida_comenzada) {
  if (x_ball + BALL_SIZE/2 >= 930)
    if (y_ball <= y_d + 80 && y_ball >= y_d)
    {
        if (40 - Math.abs(y_d + 40 - y_ball) > x_ball + BALL_SIZE/2 - 930)
        {
          //ball_speed_x = -ball_speed_x;

          double angle = 180 - ((y_ball - y_d) / 80 * 130 + 25);
          ball_speed_y = (float) (BALL_SPEED *  Math.cos(Math.toRadians(angle)));
          ball_speed_x = -(float) (BALL_SPEED *  Math.sin(Math.toRadians(180 - angle)));
        }
        else
          ball_speed_y = -ball_speed_y;
        reflect_sound.play();
    } 
  if (x_ball - BALL_SIZE/2 <= 70)
    if (y_ball <= y_i + 80 && y_ball >= y_i)
    {
      if (40 - Math.abs(y_i + 40 - y_ball) > 50 - x_ball + BALL_SIZE/2) 
      {
          //ball_speed_x = -ball_speed_x;

          double angle = 180 - ((y_ball - y_i) / 80 * 130 + 25);
          ball_speed_y = (float) (BALL_SPEED *  Math.cos(Math.toRadians(angle)));
          ball_speed_x = (float) (BALL_SPEED *  Math.sin(Math.toRadians(180 - angle)));
      }
        else
          ball_speed_y = -ball_speed_y;
        reflect_sound.play();
    }
  if (x_ball + BALL_SIZE/2 >= 1000)
  {
    fail_sound.play();
    ++tantos_i;
    partida_comenzada = false;
    x_ball = 500;
    y_ball = 290;
    resetBall();
  }
  else if (x_ball - BALL_SIZE/2 <= 0)
  {
    fail_sound.play();
    ++tantos_d;
    partida_comenzada = false;
    x_ball = 500;
    y_ball = 290;
    resetBall();
  }
  if (y_ball + BALL_SIZE/2 >= 575 || y_ball - BALL_SIZE/2 <= 55)
  {
    ball_speed_y = -ball_speed_y;
    reflect_sound.play();
  }
  
  if (partida_comenzada) {
  x_ball += ball_speed_x;
  y_ball += ball_speed_y; }}
  
  noStroke();
  fill(255, 255, 0);
  ellipse(x_ball, y_ball, BALL_SIZE, BALL_SIZE);
  fill(color(255, 255, 255));
}
void keyPressed()
{
  partida_comenzada = true;
  if (key == CODED)
  {
    if (keyCode == UP)
    {
      pressed_up = true;
      pressed_down = false;
    }
    else if (keyCode == DOWN)
    {
      pressed_down = true;
      pressed_up = false;
    }
  }
  if (key == 'w' || key == 'W')
  {
    pressed_w = true;
    pressed_s = false;
  }
  else if (key == 's' || key == 'S')
  {
    pressed_s = true;
    pressed_w = false;
  }
}
void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == UP)
      pressed_up = false;
      
    else if (keyCode == DOWN)
      pressed_down = false;
  }
  if (key == 'w' || key == 'W')
    pressed_w = false;
  else if (key == 's' || key == 'S')
    pressed_s = false;
}

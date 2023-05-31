//****************************************************************************** //<>//
//  Author: Scott Crooks
//
//  Usage: Helper class, stores transform information.
//         E.g. Position and Size of transform (for collision)
//******************************************************************************
public class Transform {

  private PVector position; // Position of this transform
  private float width;      // Width of this transform
  private float height;     // Height of this transform

  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public Transform() {
    position = new PVector(0, 0);
    this.width = 0;
    this.height = 0;
  }

  //****************************************************************************
  //  Summary: Constructor
  //  Params: position - Position of this transform
  //          size - Size of transform
  //****************************************************************************
  public Transform(PVector position, PVector size) {
    this.position = position;
    this.width = size.x;
    this.height = size.y;
  }

  //****************************************************************************
  //  Summary: Constructor
  //  Params: position - Position of this transform
  //          width - Width of this transform
  //          height - Height of this transform
  //****************************************************************************
  public Transform(PVector position, float width, float height) {
    this.position = position;
    this.width = width;
    this.height = height;
  }

  //****************************************************************************
  //  Summary: Check if a collision has occured between this transform and
  //           specified transform
  //  Params: transform - Transform we are checking for collision with
  //  Return: Boolean - True if a collision has occured
  //****************************************************************************
  public boolean hasCollisionOccured(Transform transform) {
    return Collision.boxCollision(this, transform);
  }

  //****************************************************************************
  //  Summary: Finds the center of this transform
  //  Return: PVector - The position at the center of this transform
  //****************************************************************************
  public PVector getCenter() {
    return new PVector(this.width/2, this.height/2).add(position);
  }

  //****************************************************************************
  //  Summary: Getter for transform position
  //  Return: PVector - The position of this transform
  //****************************************************************************
  public PVector getPosition() {
    return this.position;
  }

  //****************************************************************************
  //  Summary: Setter for transform position
  //  Params: position - New position for transform
  //****************************************************************************
  public void setPosition(PVector position) {
    this.position = position;
  }

  //****************************************************************************
  //  Summary: Getter for transform width
  //  Return: float - Width of this transform
  //****************************************************************************
  public float getWidth() {
    return this.width;
  }

  //****************************************************************************
  //  Summary: Getter for transform height
  //  Return: float - Height of this transform
  //****************************************************************************
  public float getHeight() {
    return this.height;
  }
  
  //****************************************************************************
  //  Summary: Get width and height of transform as PVector
  //  Return: PVector - size of this transform
  //****************************************************************************
  public PVector getSize() {
    return new PVector(this.width, this.height);
  }
}


//******************************************************************************
//  Author: Scott Crooks, Andrew McKenzie, Robert Preston
//
//  Usage: Static Helper class, used for checking collisions between Transforms
//******************************************************************************
public static class Collision {

  //****************************************************************************
  //  Summary: Performs a box collision check between two Transforms
  //  Params: transformOne - First transform for collision
  //          transformTwo - Secondary transform for collision
  //  Return: boolean - Has a collision occured between provided transform
  //****************************************************************************
  public static boolean boxCollision(Transform transformOne, Transform transformTwo) {
    // Cache data
    PVector posOne = transformOne.position;
    PVector posTwo = transformTwo.position;

    // Check if colliding starting from top left of box
    if (posOne.x > posTwo.x
      && posOne.x < posTwo.x + transformTwo.width
      && posOne.y > posTwo.y
      && posOne.y < posTwo.y + transformTwo.height) {
      return true;
    }

    return false;
  }

  //****************************************************************************
  //  Summary: Performs a circle collision check between two Transforms
  //  Params: transformOne - First transform for collision
  //          transformTwo - Secondary transform for collision
  //  Return: boolean - Has a collision occured between provided transform
  //****************************************************************************
  public static boolean circleCollision(Transform colOne, Transform colTwo) {
    // Cache data
    PVector posOne =  colOne.getCenter();
    PVector posTwo = colTwo.getCenter();

    // Get the average of the width and the height for a rough radius.
    float radiusOne = (colOne.width / 2 + colOne.height / 2) / 2;
    float radiusTwo = (colTwo.width / 2 + colTwo.height / 2) / 2;

    // Get the distance between the two radii
    float distance = posOne.dist(posTwo);

    // Check for the actual collision by comparing the distance between
    // the two transforms and the sizes of the radii
    if (distance < (radiusOne + radiusTwo))
      return true;

    // If a collision hasn't occured return false
    return false;
  }

  //****************************************************************************
  //  Summary: Checks if a collision has occured between a circle and an
  //           axis-aligned rectangle.
  //  Params: position - The position of the circle
  //          radius - The radius of the circle
  //          transform - The rectangle for the calculation
  //  Return: boolean - Has a collision occured between the circle and square?
  //****************************************************************************
  public static boolean circleSquareCollision(PVector position, float radius, Transform transform) {
    // Get the absolute distance between the center of the circle and the center of the rect
    PVector circleDist = new PVector(abs(position.x - transform.getCenter().x),
      abs(position.y - transform.getCenter().y));

    // If the distance between the circle and the square is than sum
    // of their parts there is no need to go further and we can return false.
    if (circleDist.x > (transform.getWidth() / 2 + radius))
      return false;
    if (circleDist.y > (transform.getHeight() / 2 + radius))
      return false;

    // Is the cirle close enough to the rect that a collision is guaranteed?
    if (circleDist.x <= (transform.getWidth() / 2))
      return true;
    if (circleDist.y <= (transform.getHeight() / 2))
      return true;

    // Compute the distance from the corner to the circle
    float cornerDistanceSq = (float)(Math.pow((circleDist.x - transform.getWidth() / 2), 2)
      + Math.pow((circleDist.y - transform.getHeight() / 2), 2));

    // is the distance from the corner less then the radius of the circle?
    return cornerDistanceSq <= Math.pow(radius, 2);
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Helper class for handling time and deltaTime
//
//  Info: DeltaTime is the time in miliseconds since the last frame. Useful for
//        disconnecting time based logic from fps (Frames per second).
//        E.g. Movement or timers
//******************************************************************************
public class Time {
  private int deltaTime; // Time since last frame (milliseconds)
  private int lastTime;  // Total time in milliseconds since the program started

  private float timeMultiplier; // Used for speeding up/slowning down game
  private float defaultSpeed;   // Default speed
  private float minSpeed;       // Minimum game speed
  private float maxSpeed;       // Maximum game speed

  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public Time() {
    // Set times to zero
    deltaTime = 0;
    lastTime = 0;

    // Set default speed multiplier settings
    defaultSpeed = 1;
    timeMultiplier = 1;
    minSpeed = 0.2;
    maxSpeed = 5;
  }

  //****************************************************************************
  //  Summary: MUST run once every frame to calculate time since last frame
  //           Calculates the deltaTime,
  //           E.g. time since this function was last called (once a frame)
  //****************************************************************************
  public void calcDeltaTime() {
    // Calculate the deltaTime by subtracting the total time last frame from
    // the total time in milliseconds this frame
    deltaTime = millis() - lastTime;

    // Set last time to the result of millis
    lastTime = millis();

    // Multiply deltaTime by time multiplier
    deltaTime *= timeMultiplier;
  }

  //****************************************************************************
  //  Summary: Getter for deltaTime
  //  Return: int - Time in milliseconds since last frame
  //****************************************************************************
  public int getDeltaTime() {
    return this.deltaTime;
  }

  //****************************************************************************
  //  Summary: Getter for deltaTime in seconds
  //  Return: float - Time in seconds since last frame
  //****************************************************************************
  public float getDeltaTimeSeconds() {
    return (float)deltaTime / 1000;
  }

  //****************************************************************************
  //  Summary: Increase the time multiplier
  //  Params: increase - what to increase the speed multiplier by
  //****************************************************************************
  public void increaseSpeed(float increase) {
    // If increase isn't positive return
    if (increase < 0) return;

    // If the speed increase + time multiplier is greater then the allowed
    // maximum speed set the speed to maxSpeed. Otherwise increase the
    // speed multiplier by the requested increase.
    if (timeMultiplier + increase < maxSpeed)
      timeMultiplier += increase;
    else
      timeMultiplier = maxSpeed;
  }

  //****************************************************************************
  //  Summary: decrease the time multiplier
  //  Params: decrease - what to decrease the speed multiplier by
  //****************************************************************************
  public void decreaseSpeed(float decrease) {
    // If increase isn't positive return
    if (decrease < 0) return;

    // If the speed decrease - time multiplier is smaller then minSpeed, set the
    // speed multiplier to minSpeed. Otherwise decrease the time multiplier by
    // requested cecrease.
    if (timeMultiplier - decrease > minSpeed)
      timeMultiplier -= decrease;
    else
      timeMultiplier = minSpeed;
  }

  //****************************************************************************
  //  Summary: set the speed multiplier to requested speed
  //  Params: speed - what to set the speed multiplier to
  //****************************************************************************
  public void setSpeedMultiplier(float speed) {

    // Clamp speed to maxSpeed and minSpeed.
    if (speed > maxSpeed)
      timeMultiplier = maxSpeed;
    else if (speed < minSpeed)
      timeMultiplier = minSpeed;
    else
      timeMultiplier = speed;
  }

  //****************************************************************************
  //  Summary: Reset speed multiplier to default speed
  //****************************************************************************
  public void resetSpeedMultiplier() {
    timeMultiplier = defaultSpeed;
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Utility class for handling blinking text
//******************************************************************************
public class BlinkingText {

  float onInterval;      // Blink on interval
  float offInterval;     // Blink off interval
  float currentInterval; // Current blink seconds elapsed
  boolean visible;       // Currently visible?
  String text;           // Text to display
  float fontSize;        // Font size
  PVector position;      // Position

  //****************************************************************************
  //  Summary: Constructor
  //  Params: interval - The blinking delay
  //          text - Text to display
  //          fontSize - Font size of text
  //          position - Position of blinking text
  //****************************************************************************
  public BlinkingText(float interval, String text, float fontSize, PVector position) {
    this.onInterval = interval;
    this.offInterval = interval;
    this.text = text;
    this.fontSize = fontSize;
    this.currentInterval = 0;
    this.visible = true;
    this.position = position;
  }

  //****************************************************************************
  //  Summary: Alternate Constructor for non-even blinking.
  //           E.g. OnInterval may be longer than OffInterval
  //  Params: onInterval - The blinking delay while on
  //          offInterval - The blinking delay while off
  //          text - Text to display
  //          fontSize - Font size of text
  //          position - Position of blinking text
  //****************************************************************************
  public BlinkingText(float onInterval, float offInterval, String text, float fontSize, PVector position) {
    this.onInterval = onInterval;
    this.offInterval = offInterval;
    this.text = text;
    this.fontSize = fontSize;
    this.currentInterval = 0;
    this.visible = true;
    this.position = position;
  }

  //****************************************************************************
  //  Summary: Every frame draw the text to screen and calculate blink interval
  //****************************************************************************
  public void draw() {
    // Increase the interval by the time in seconds since the last fame
    currentInterval += time.getDeltaTimeSeconds();

    // If the test is visible track on interval, otherwise track off interval
    if (visible) {
      if (currentInterval > onInterval) {
        currentInterval = 0;
        visible = false;
      }
    } else {
      if (currentInterval > offInterval) {
        currentInterval = 0;
        visible = true;
      }
    }

    // If text is visible display the text
    if (visible) {
      textSize(fontSize);
      text(text, position.x, position.y);
    }
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Highscore display, displays highscores, saves highscores
//         and reads highscores
//******************************************************************************
public class HighscoreLeaderboard {

  // Variables
  PVector position;  // Position of highscore display

  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public HighscoreLeaderboard() {
    position = new PVector(0, 0);
  }

  //****************************************************************************
  //  Summary: Draws highscore to screen
  //****************************************************************************
  public void display() {
    // Title
    textSize(content.fontSizeSubtitle);
    text("HIGHSCORES:", position.x + 60, position.y);

    // Subtitle
    textSize(content.fontSizeSubtitle);
    text("USER", position.x + 30, content.fontSizeSubtitle + position.y);
    text("SCORE", position.x + 190, content.fontSizeSubtitle + position.y);

    // Reset position offset
    float scoreOffsetY = 55;

    // Draw scores to screen
    textSize(content.fontSizeSubtitle);
    for (Score score : content.getHighscores()) {
      // Draw User and respective score to screen
      text(score.name, position.x + 30, position.y + scoreOffsetY);
      text(String.valueOf(score.score), position.x + 190, position.y + scoreOffsetY);

      // Increase score offset so following score doesn't draw over existing score
      scoreOffsetY += 20;
    }
  }

  //****************************************************************************
  // Summary: Checks if score is greater than an existing highscore.
  // Params: score - Score to compare against highscore list.
  // Return: Boolean - Is the score a new highscore
  //****************************************************************************
  public boolean newHighscore(int score) {
    for (Score highscore : content.getHighscores()) {
      if (score > highscore.score)
        return true;
    }

    return false;
  }

  //****************************************************************************
  // Summary: Adds a new highscore to the highscore list
  // Params: score - Score of new highscorer
  //         name - Username of new highscorer
  //****************************************************************************
  public void addHighscore(int score, String name) {
    // Create copy of highscore list
    List<Score> highscores = content.getHighscores();

    // Clean name
    name.trim();

    // Add new highscore to list
    highscores.add(new Score(name, score));

    // Insert new highscore into list at correct position
    for (int i = highscores.size() - 1; i > 0; i--) {
      if (highscores.get(i).score > highscores.get(i - 1).score) {
        Collections.swap(highscores, i, i - 1);
      }
    }

    // Send new highscore list to content class
    content.setHighscores(highscores);
  }

  //****************************************************************************
  // Summary: setter for display position
  // Params: position - Where to display highscore leaderboard
  //****************************************************************************
  public void setPosition(PVector position) {
    this.position = position;
  }
}

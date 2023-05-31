//******************************************************************************
//  Authors: Andrew McKenzie
//
//  Usage: Draws cannon and gets the cannon to follow the reticle
//  Also controls the amount of ammo the player has remaining
//******************************************************************************
public class Cannon {

  private final PVector position; // The position of the cannon base

  private int ammo;       // The total ammo available to the player
  private PVector endPos; // XY position at the tip of the cannon
  private int[] rgb;      // Colour of the cannon

  //******************************************************************************
  //  Summary: Constructor setting the center point on x-axis and initilizing 
  //         the bases
  //******************************************************************************
  public Cannon() {
    // Base x and y values for the cannon
    this.position = new PVector(width/2, height-55);
    this.endPos = new PVector();
    this.rgb = new int[3];
    this.rgb[0] = 183;
    this.rgb[1] = 165;
    this.rgb[2] = 120;
  }

  //******************************************************************************
  //  Summary: Draws the cannon using the current reticle position
  //           mapped to the cannon size
  //******************************************************************************
  public void drawCannon() {

    // Taking the reticle PVector position and storing the x and y values
    PVector reticlePos = reticle.getReticlePos();
    float reticleXPos = reticlePos.x + reticle.transform.width / 2;
    float reticleYPos = height - reticlePos.y;

    // Mapping the distance between the cannon and
    // reticle to an appropriate cannon size
    endPos.x = map(reticleXPos, 0, width, position.x-30, position.x+30);
    endPos.y = map(reticleYPos, 0, height-30, position.y, height-65);

    strokeWeight(10);
    stroke(rgb[0], rgb[1], rgb[2]);

    // Draws the cannon
    line(position.x, position.y, endPos.x, endPos.y);

    noStroke();
  }
  
  //******************************************************************************
  //  Summary: Fires the cannon
  //******************************************************************************
  public void fireCannon() {
    if (isAmmoRemaining()) {
      gameController.defenceMissiles.add(new DefenceMissile());
      content.playSound("CannonFire");
      removeAmmo(1);
    }
  }

  //******************************************************************************
  //  Summary: Getter for the end of the cannons position
  //  Return: x coordinate for the end of the cannon
  //******************************************************************************
  public PVector getEndPosition() {
    return endPos;
  }

  //******************************************************************************
  //  Summary: To add ammuntion for the player
  //  Params: ammo: Amount of ammo to add
  //******************************************************************************
  public void addAmmo(int ammo) {
    ammo += ammo;
  }
  
  //******************************************************************************
  //  Summary: Removes requested amount of ammo
  //  Params: ammo: Amount of ammo to remove
  //******************************************************************************
  public void removeAmmo(int ammo) {
    if (this.ammo - ammo < 0)
      this.ammo = 0;
    else
      this.ammo-= ammo;
  }

  //******************************************************************************
  //  Summary: Getter for ammo
  //  Return: int representing the number of ammo left
  //******************************************************************************
  public int getAmmo() {
    return ammo;
  }

  //******************************************************************************
  //  Summary: Setter for ammo
  //  Params: numAmmo: what to set ammo to
  //******************************************************************************
  public void setAmmo(int numAmmo) {
    ammo = numAmmo;
  }
  
  //******************************************************************************
  //  Summary: Is there any ammo remaining/available
  //  Return: boolean
  //******************************************************************************
  public boolean isAmmoRemaining() {
    return (ammo > 0);
  }
  
  //******************************************************************************
  //  Summary: Setter for the cannon rgb
  //******************************************************************************
  public void setRGB(int[] rgb) {
    this.rgb = rgb;
  }
}


//********************************************************************************
//  Authors: Andrew McKenzie
//  (Modified form of Scott Crooks Enemies class)
//
//  Usage: Defence missile launching
//********************************************************************************
public class DefenceMissile {

  public Transform transform; // Physical missile shape

  private float speed; // Controls the speed of the missile
  private int colour; // Colour for the defense missile

  private PVector launchPos; // Cannon position when the missile was launched
  private PVector targetPos; // Reticle position when the missile was launched
  private PVector path; // Path for the missile to travel

  private float targetX; // Adjust reticle x position for center of reticle
  private float targetY; // Y position of reticle at time of missile launch

  private Trail trail; // Even the defence missiles have trails
  private int trailCounter; // I'll just do a simple one.

  //******************************************************************************
  //  Summary: Constructor for the defence missile
  //  Params: None
  //******************************************************************************
  public DefenceMissile() {

    // PVector for the launch position adjusted for size of rectangle
    launchPos = new PVector(cannon.getEndPosition().x-5,
      cannon.getEndPosition().y-5);

    // Target position of reticle at time of launching
    targetPos = reticle.getReticlePos();
    targetY = targetPos.y;
    targetX = targetPos.x + reticle.transform.width / 2;

    // Creating Transform
    transform = new Transform(launchPos, new PVector(5, 5));

    // PVector for the path between both points
    path = new PVector(targetX - launchPos.x, targetY - launchPos.y);

    trail = gameController.NewTrail();

    speed = 200;
    colour = 255;
  }

  //******************************************************************************
  //  Summary: Draws the missile
  //******************************************************************************
  public void draw() {
    fill(colour);
    rect(transform.position.x, transform.position.y,
      transform.width, transform.height);
  }

  //******************************************************************************
  //  Summary: Updates the position of the missile along the path to its target
  //******************************************************************************
  public void run() {
    // Calculate path of missile
    path.normalize();
    path.mult(speed);
    transform.position.x += path.x * time.getDeltaTimeSeconds();
    transform.position.y += path.y * time.getDeltaTimeSeconds();

    // Calculate trail
    trailCounter++;
    if (trailCounter > 2) {

      PVector ps = new PVector(transform.position.x + transform.width / 2, transform.position.y + transform.height / 2);
      trail.addSegment(ps);
      trailCounter = 0;
    }
  }

  //******************************************************************************
  //  Summary: call this when you destroy the defence missile.
  //******************************************************************************
  public void destroy() {
    trail.destroyed = true;
  }

  //******************************************************************************
  //  Summary: Method to check if the missile has reach it's target
  //  Return: boolean - true if missile has reached target otherwise false
  //******************************************************************************
  public boolean onTarget() {
    float reticleTargetX = abs(transform.position.x - targetX);
    float reticleTargetY = abs(transform.position.y - targetY);
    boolean onTarget = ((reticleTargetY <= 5) && (reticleTargetX <= 4));
    return onTarget;
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Controls and display for player reticle
//******************************************************************************
public class Reticle {

  private Transform transform; // Reticle transform
  private float reticleSpeed;  // Reticle movement speed
  private PVector constraints; // Screen constraints
  private int[] rgb;           // Reticle colour in rgb
  
  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public Reticle() {
    PVector size = new PVector(40, 8);
    PVector position = new PVector(width /2 - size.x / 2, height /2 - size.y - 2);
    this.transform = new Transform(position, size);
    this.reticleSpeed = 40;
    this.rgb = new int[3];
    this.rgb[0] = 255;
    this.rgb[1] = 255;
    this.rgb[2] = 255;
    
    // Set constraints and account for reticle size
    this.constraints = new PVector(width - size.x, height - size.y * 2); 
  }
  
  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public void draw() {
    noStroke();
    fill(rgb[0], rgb[1], rgb[2]);
    rect(transform.position.x, transform.position.y, transform.width, transform.height);
  }
  
  //****************************************************************************
  //  Summary: Reset reticle position to center of screen
  //****************************************************************************
  public void resetPosition() {
    transform.position = new PVector(width /2 - transform.width / 2, height /2 - transform.height - 2);
  }
  
  //****************************************************************************
  //  Summary: Move reticle up
  //****************************************************************************
  public void moveUp() {
    move(new PVector(0, -1));
  }
  
  //****************************************************************************
  //  Summary: Move reticle down
  //****************************************************************************
  public void moveDown() {
    move(new PVector(0, 1));
  }
  
  //****************************************************************************
  //  Summary: Move reticle left
  //****************************************************************************
  public void moveLeft() {
    move(new PVector(-1, 0));
  }
  
  //****************************************************************************
  //  Summary: Move reticle right
  //****************************************************************************
  public void moveRight() {
    move(new PVector(1, 0));
  }
  
  //****************************************************************************
  //  Summary: Move the reticle based upon the vector provided
  //  Params: movement - Movement vector for reticle. i.e. How far to move.
  //****************************************************************************
  public void move(PVector movement) {
    // Play reticle moving sound
    content.playSound("ReticleMove");
    
    // Checks to ensure reticle does not move outside of the screen/constraints set
    if (movement.x > 0) {
      if (transform.position.x + movement.x < constraints.x) 
        transform.position.x += movement.x * (reticleSpeed + time.getDeltaTimeSeconds());
    }
    
    if (movement.x < 0) {
      if (transform.position.x + movement.x > 0) 
        transform.position.x += movement.x * (reticleSpeed + time.getDeltaTimeSeconds());
    }
    
    if (movement.y > 0) {
      if (transform.position.y + movement.y < constraints.y) 
        transform.position.y += movement.y * (reticleSpeed + time.getDeltaTimeSeconds());
    }
    
    if (movement.y < 0) {
      if (transform.position.y + movement.y > 0) 
        transform.position.y += movement.y * (reticleSpeed + time.getDeltaTimeSeconds());
    }
  }
  
  //****************************************************************************
  //  Summary: Getter for reticle position
  //  Return: PVector reticle position
  //****************************************************************************
  public PVector getReticlePos(){
    return this.transform.position; 
  }
  
  //****************************************************************************
  //  Summary: Setter for reticle rgb
  //  Params: rgb - int array of rgb channels
  //****************************************************************************
  public void setRGB(int[] rgb) {
    this.rgb[0] = rgb[0];
    this.rgb[1] = rgb[1];
    this.rgb[2] = rgb[2];
  }
}

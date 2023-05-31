//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Enum for all spawnable missiles in game. Used in spawning missiles
//******************************************************************************
public enum MissileTypes {
    BASICMISSILE,
    FASTMISSILE,
    SMARTMISSILE,
    DUMBMISSILE,
    TESTMISSILE,
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Base missile class, stores all data and methods related to
//         missile logic.
//******************************************************************************
public class Missile {

  private MissileSpawner spawner; // Missile spawner that this missile belongs to
  private IMissileBrain brain;    // Missile AI Brain

  // Missile coorinates
  protected Transform transform; // Missile position and size
  protected PVector launchPos;   // PVector for the missiles origin

  // Missile properties
  protected float speed;             // Missie speed
  protected int colour;              // Missile colour
  protected float explosionDiameter; // Size of the explosions diameter

  // Trail visuals
  private final float trailDelay = 0.1f; // Delay for spawning trail segments
  private float trailDelayCounter;       // Counter for spawning trail segments
  private Trail trail;                   // Missile trail
  private boolean destroyed;             // Is the missile destroyed?

  //****************************************************************************
  //  Summary: Constructor
  //  Params: spawner - The missile spawner that created this missile
  //          brain - The AI Brain for this missile
  //****************************************************************************
  public Missile(MissileSpawner spawner, IMissileBrain brain) {
    this.spawner = spawner;
    this.brain = brain;

    // Spawn missile and set launch position
    this.transform = new Transform(spawner.randomSpawnPosition(),
      new PVector(15, 15));
    this.launchPos = transform.position;

    // Set base missile properties
    this.speed = 0;
    this.colour = 0;
    this.explosionDiameter = 80;

    // Setup visuals
    this.trailDelayCounter = 0;
    this.trail = gameController.NewTrail();
    this.destroyed = false;

    // initialize missile brain
    brain.initialize(this);
  }

  //****************************************************************************
  //  Summary: Called every frame while game is controller is
  //           running. Every frame we calculate the position of
  //           the missile and the path it's taking. We also must
  //           check if the missile has collided with a base.
  //****************************************************************************
  public void run() {

    // Destroy the missile of true
    if (destroyed)
     forceDestroy();
    
    // Run AI Brain to calculate positions
    brain.calculate();
    
    // Missile has hit the ground, self-destruct
    if (transform.position.y >= height - 40) {
      // Check for collision against living bases
      for (Base base : environment.getAliveBases()) {
        // If 
        if (Collision.circleSquareCollision(this.transform.position,
              this.explosionDiameter / 2, base.baseTransform)) {
          environment.destroyBase(base.getID());
          content.playSound("BaseCollapse");
        }
      }

      destroy();
    }

    // Check if this missile has collided with a living base.
    // If the missile is above the bases in the sky there is no need to
    // check if the missile has hit a base
    if (transform.position.y >= height - 60) {
      // Get alive bases
      List<Base> aliveBases = environment.getAliveBases();
      // Search for a collision against any living base
      for (Base base : aliveBases) {
        // Perform box collision
        if (transform.hasCollisionOccured(base.baseTransform)) {
          // Destroy base and missile
          environment.destroyBase(base.getID());
          content.playSound("BaseCollapse");
          destroy();
        }
      }
    }

    // Trail logic
    trailDelayCounter += time.getDeltaTimeSeconds();

    // Every trailDelay seconds add a new segment to the trail
    if (trailDelayCounter > trailDelay) {
      trailDelayCounter = 0;
      PVector ps = new PVector(transform.position.x + transform.width / 2,
        transform.position.y + transform.height / 2);
      trail.addSegment(ps);
    }
  }

  //****************************************************************************
  //  Summary: Called every frame while game is running.
  //           When called draw the physical missile to the screen
  //****************************************************************************
  public void draw() {
    // Set Colour
    fill(colour);

    // Draw the missile
    rect(transform.position.x, transform.position.y,
      transform.width, transform.height);
  }

  //****************************************************************************
  //  Summary: Causes missile to explode and destroys missile object
  //****************************************************************************
  private void destroy() {
    // Play explosion sound
    content.playSound("flakExplosion");

    // Create a new missile explosion
    // Get explosion position
    PVector pos = this.transform.getCenter();
    // Add explosion to list
    gameController.addMissileExplosion(new Explosion(pos, explosionDiameter, false));

    // Start despawning trail
    trail.destroyed = true; //should probably start to use destructors.

    // Destroy missile in spawner
    spawner.destroyMissile(this);
  }
  
  //****************************************************************************
  //  Summary: Destroy the missile without exploding
  //****************************************************************************
  private void forceDestroy() {
    // Start despawning trail
    trail.destroyed = true; //should probably start to use destructors.
    
    // Destroy missile in spawner
    spawner.destroyMissile(this);
  }

  //****************************************************************************
  //  Summary: Setter for destroyed
  //****************************************************************************
  public void setDestroyed(boolean destroyed) {
    this.destroyed = destroyed;
  }
}

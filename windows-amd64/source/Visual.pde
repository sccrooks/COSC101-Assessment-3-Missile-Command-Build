//******************************************************************************
//  Visual
//
//  [Original] Author: Robert Preston
//
//  Usage: Reusable Visual code
//
//  Changelog:
//    * 18 May -- Created Visual
//******************************************************************************
public class Trail {

  private ArrayList<PVector> segmentPositions; // An array to store the positions of trail segments.
  private int alpha = 200;          // Trail alpha, used for fading out the trail
  public Boolean destroyed = false; // Is the trail destroyed?

  //****************************************************************************
  //  Summary: Trail constructor
  //****************************************************************************
  public Trail() {
    segmentPositions = new ArrayList<PVector>();
  }

  //****************************************************************************
  //  Summary: Add a new segnment to the trail
  //  Params: position - PVector of the new segment
  //****************************************************************************
  public void addSegment(PVector position) {
    segmentPositions.add(position);
  }

  //****************************************************************************
  //  Summary: Draw the trail to the screen
  //****************************************************************************
  public void draw() {

    // If the missile is destroyed start fading out the trail
    if (destroyed)
      alpha -= 5;

    // If the trail alpha is less then 0 we can destroy the trail
    if (alpha < 0)
      gameController.trails.remove(this);

    // Begin drawing trail
    strokeWeight(1);
    noFill();
    stroke(255, alpha);
    beginShape();
    
    for (int i = 0; i < segmentPositions.size(); i++)
      // For each segment position create a vertex at point
      curveVertex(segmentPositions.get(i).x, segmentPositions.get(i).y);

    // Finish trail
    endShape();
  }
}

//********************************************************************************
//  Authors: Robert Preston
//
//  Usage: Creates a missile explosion and controls graphics
//********************************************************************************
public class Explosion {
  
  public final boolean friendly; // Is this a friendly explosion?
  public final float radius;     // Explosion radius
  public final float diameter;   // Explosion diameter
  public final PVector center;   // position of explosion
  public int lifespan = 255;     // Duration of explosion vfx
  public boolean exploded;       // Should we continue to destroy enemies in explosion
  
  //******************************************************************************
  //  Summary: Constructor for the MissileExplosion
  //  Params: center - PVector for the center of the explosion
  //          diameter - Float for the diameter of the explosion
  //          friendly - Is this a friendly explosion?
  //******************************************************************************
  public Explosion(PVector center, float diameter, boolean friendly) {
    this.friendly = friendly;
    this.radius = diameter / 2;
    this.diameter = diameter;
    this.center = center;
    this.lifespan = 255;
    this.exploded = false;
  }

  //******************************************************************************
  //  Summary: Call AI and draw the explosion.
  //******************************************************************************
  public void draw() {
    ai();
    ellipseMode(CORNER);
    fill(255, lifespan);
    noStroke();
    ellipse(center.x - diameter / 2, center.y - diameter / 2, diameter, diameter);
  }

  //******************************************************************************
  //  Summary: Update explosion properties.
  //******************************************************************************
  public void ai() {
    lifespan -= 10;
  }
}

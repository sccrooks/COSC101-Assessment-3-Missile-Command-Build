//******************************************************************************
//  Authors: Andrew McKenzie, Scott Crooks
//
//  Usage: Draws the ground, defense system and creates instances of the Base class
//
//  Changes:
//    8 May -- Robert -- Moved defenceMissiles to GameController.pde
//******************************************************************************
public class Environment {

  private final float xCenter;      // Center width of screen
  private final float spacing;      // Spacing between each base
  private final float[] xLocBases;  // list of x positions to draw each Base
  private Base[] bases;             // Array of all bases
  private boolean allBasesDestroyed;// Are all of the bases destroyed?
  private int[] primaryRGB;         // Primary RGB values for game
  private int[] secondaryRGB;       // Secondary RGB values for game
  private int[] hudRGB;             // HUD RGB values for overlay

  //****************************************************************************
  //  Summary: Constructor setting the center point on x-axis and initilizing the bases
  //****************************************************************************
  public Environment() {
    xCenter = width/2;

    // Initialize RGB arrays
    primaryRGB = new int[3];
    secondaryRGB = new int[3];
    hudRGB = new int[3];
    
    // calculating the spacing for bases in relation to screen width
    spacing = (((width/2)-190)/4);

    // Array of base x locations. Bases will be drawn at these positions
    xLocBases = new float[] {(-spacing*3)-170, (-spacing*2)-130, -spacing-90,
      spacing+50, (spacing*2)+90, (spacing*3)+130};

    // Initializing the array of Bases to be defended
    bases = new Base[6];

    // Initilizing the bases to be defended
    for (int i = 0; i < bases.length; i++)
      bases[i] = new Base(xLocBases[i], false, i);

    // Reset environment
    resetEnvironment();
  }

  //****************************************************************************
  //  Summary: Resets environment on new game
  //****************************************************************************
  public void resetEnvironment() {
    allBasesDestroyed = false;

    for (int i = 0; i < bases.length; i++)
      bases[i].setDestroyed(false);
      
    setPrimaryRGB(237, 209, 139);  
    setSecondaryRGB(165, 133, 145);
    setHUDRGB(255, 255, 255);
  }

  //****************************************************************************
  //  Summary: Called every frame while game is running.
  //         This method draws the environment
  //****************************************************************************
  public void draw() {
    noStroke();
    int[] brgb = gameController.currentLevel.backgroundRGB;
    background(brgb[0], brgb[1], brgb[2]);

    drawEnvironment();   // Draws the Environment
    drawDefenseSystem(); // Draws the defense cannon tower
    cannon.drawCannon(); // Draws the defense cannon
    drawBases();         // Draws all the bases to the screen
    drawAmmo();          // Draws the remaining available ammo
  }

  //****************************************************************************
  //  Summary: Draws the environment backdrop. E.g. The ground and cliffs
  //****************************************************************************
  private void drawEnvironment() {
    // Draws base rectangle and sides
    fill(primaryRGB[0], primaryRGB[1], primaryRGB[2]);
    rect(0, height-30, width, height);
    rect(0, height-55, 20, 25);
    rect(width-20, height-55, 20, 25);
  }

  //****************************************************************************
  //  Summary: Draws the tower that the defense cannon sits on
  //****************************************************************************
  private void drawDefenseSystem() {
    fill(primaryRGB[0], primaryRGB[1], primaryRGB[2]);
    rect(xCenter-50, height-35, 100, 10);
    rect(xCenter-45, height-40, 90, 10);
    rect(xCenter-40, height-45, 80, 10);
    ellipseMode(CENTER);
    arc(xCenter, height-45, 50, 25, PI, TWO_PI);
  }

  //****************************************************************************
  //  Summary: Draws the available ammo as rectangles on the screen
  //****************************************************************************
  private void drawAmmo() {
    // Draws rectangle represent how much ammo is left
    for (int i = 0, space = 0; i<cannon.getAmmo(); i++, space += 8) {
      int start = (4*cannon.getAmmo());
      fill(secondaryRGB[0], secondaryRGB[1], secondaryRGB[2]);
      rect(width/2-start+space, height-20, 5, 10);
    }
  }

  //****************************************************************************
  //  Summary: Draws all the bases to the screen. If a base is destroyed a 
  //           ruined variation will be drawn instead.
  //****************************************************************************
  private void drawBases() {
    // Iterate over the array of bases
    for (int i = 0; i < bases.length; i++) {
      // If the base is not destroyed draw it
      if (!bases[i].destroyed)
        bases[i].drawBuilding(bases[i].getXLocation());

      // If the base is destroyed draw a ruined version
      else
        bases[i].drawCollapsedBase(bases[i].getXLocation());
    }
  }

  //****************************************************************************
  //  Summary: Returns a list of the bases that have not been destroyed
  //  Return: List<Base>
  //****************************************************************************
  public List<Base> getAliveBases() {
    List<Base> aliveBases = new ArrayList<Base>();

    for (Base base : bases) {
      if (!base.isDestroyed())
        aliveBases.add(base);
    }

    return aliveBases;
  }

  //****************************************************************************
  //  Summary: Call to destroy a specific base
  //  Params: Index - Index of base in bases array
  //****************************************************************************
  public void destroyBase(int index) {
    bases[index].setDestroyed(true);

    if (getAliveBases().size() == 0)
      this.allBasesDestroyed = true;
  }

  //****************************************************************************
  //  Summary: Getter for allBasesDestroyed
  //  Return: boolean
  //****************************************************************************
  public boolean isAllBasesDestroyed() {
    return this.allBasesDestroyed;
  }
  
  //****************************************************************************
  //  Summary: setter for primaryRGB
  //  Params: r - Red channel value
  //          g - Green channel value
  //          b - Blue channel value
  //****************************************************************************
  public void setPrimaryRGB(int r, int g, int b) {
    this.primaryRGB[0] = r;
    this.primaryRGB[1] = g;
    this.primaryRGB[2] = b;
  }
  
  //****************************************************************************
  //  Summary: setter for primaryRGB
  //  Params: rgb - Array of size 3 representing RGB values
  //****************************************************************************
  public void setPrimaryRGB(int[] rgb) {
    this.primaryRGB[0] = rgb[0];
    this.primaryRGB[1] = rgb[1];
    this.primaryRGB[2] = rgb[2];
  }
  
  //****************************************************************************
  //  Summary: setter for secondaryRGB
  //  Params: r - Red channel value
  //          g - Green channel value
  //          b - Blue channel value
  //****************************************************************************
  public void setSecondaryRGB(int r, int g, int b) {
    this.secondaryRGB[0] = r;
    this.secondaryRGB[1] = g;
    this.secondaryRGB[2] = b;
    
    // Update bases with new secondary colour
    updateBaseColours();
  }
  
  //****************************************************************************
  //  Summary: setter for secondaryRGB
  //  Params: rgb - Array of size 3 representing RGB values
  //****************************************************************************
  public void setSecondaryRGB(int[] rgb) {
    this.secondaryRGB[0] = rgb[0];
    this.secondaryRGB[1] = rgb[1];
    this.secondaryRGB[2] = rgb[2];
    
    // Update bases with new secondary colour
    updateBaseColours();
  }
  
  //****************************************************************************
  //  Summary: Getter for secondaryRGB
  //  Return: Returns an int array of rgb colour channels
  //****************************************************************************
  public int[] getSecondaryRGB() {
    return this.secondaryRGB;
  }
  
  //****************************************************************************
  //  Summary: setter for hudRGB
  //  Params: r - Red channel value
  //          g - Green channel value
  //          b - Blue channel value
  //****************************************************************************
  public void setHUDRGB(int r, int g, int b) {
    this.hudRGB[0] = r;
    this.hudRGB[1] = g;
    this.hudRGB[2] = b;
  }
  
  //****************************************************************************
  //  Summary: setter for hudRGB
  //  Params: rgb - Array of size 3 representing RGB values
  //****************************************************************************
  public void setHUDRGB(int[] rgb) {
    this.hudRGB[0] = rgb[0];
    this.hudRGB[1] = rgb[1];
    this.hudRGB[2] = rgb[2];
  }
  
  //****************************************************************************
  //  Summary: Getter for hudRGB
  //  Return: Returns an int array of rgb colour channels
  //****************************************************************************
  public int[] getHUDRGB() {
    return this.hudRGB;
  }
  
  //****************************************************************************
  //  Summary: Updates all bases with new secondary rgb colours
  //****************************************************************************
  private void updateBaseColours() {
    for (Base base : bases) {
      base.setBaseColour(secondaryRGB[0], secondaryRGB[1], secondaryRGB[2]);
    }
  }
}


//******************************************************************************
//  Authors: Andrew McKenzie
//
//  Usage: A class for creating a base object and drawing the screen
//******************************************************************************
public class Base {

  private final float xLocation;   // x location of base
  private float xCenter;           // x center of base
  private boolean destroyed;       // Is the base destroyed?
  private Transform baseTransform; // Base transform
  private final int id;            // ID of base.
  private int[] baseRGB;        // Colour of the base

  //****************************************************************************
  //  Summary: Constructor, takes a float as an argument and adds it to the centerX value
  //         also sets the isVisible boolean and xCenter variable to the center of the screens x-axis
  //  Params: xLocation - x location of base on screen
  //          destroyed - Is the base destroyed
  //****************************************************************************
  public Base(float xLocation, boolean destroyed, int id) {
    this.xCenter = width/2;
    this.xLocation = xCenter+xLocation;
    this.destroyed = destroyed;
    this.id = id;
    this.baseTransform = new Transform(new PVector(xCenter+xLocation, height-65), 40, 50);
    this.baseRGB = new int[3];
  }

  //****************************************************************************
  //  Summary: Takes a float as an input and draws a base in that location.
  //  Params: xLoc - x location of base on screen.
  //****************************************************************************
  public void drawBuilding(float xLocation) {
    noStroke();
    fill(baseRGB[0], baseRGB[1], baseRGB[2]);
    rect(xLocation, height-35, 4, 20);
    rect(xLocation+4, height-45, 4, 30);
    rect(xLocation+8, height-65, 4, 50);
    rect(xLocation+12, height-35, 4, 20);
    rect(xLocation+16, height-45, 4, 30);
    rect(xLocation+20, height-55, 4, 40);
    rect(xLocation+24, height-65, 4, 50);
    rect(xLocation+28, height-50, 4, 35);
    rect(xLocation+32, height-45, 4, 30);
    rect(xLocation+36, height-35, 4, 20);
  }

  //****************************************************************************
  //  Summary: Draws the collapsed base
  //****************************************************************************
  public void drawCollapsedBase(float xLoc) {
    noStroke();
    fill(baseRGB[0], baseRGB[1], baseRGB[2]);
    rect(xLoc, height-33, 4, 3);
    rect(xLoc+4, height-34, 4, 4);
    rect(xLoc+8, height-36, 4, 6);
    rect(xLoc+12, height-33, 4, 3);
    rect(xLoc+16, height-34, 4, 4);
    rect(xLoc+20, height-35, 4, 5);
    rect(xLoc+24, height-36, 4, 6);
    rect(xLoc+28, height-34, 4, 4);
    rect(xLoc+32, height-34, 4, 4);
    rect(xLoc+36, height-33, 4, 3);
  }

  //****************************************************************************
  //  Summary: Getter for xLocation of base.
  //  Return: float - x coordinate of base
  //****************************************************************************
  public float getXLocation() {
    return this.xLocation;
  }
  
  //****************************************************************************
  //  Summary: Getter for Pvector of base.
  //  Return: PVector - position of base
  //****************************************************************************
  public PVector getPosition() {
    return this.baseTransform.position;
  }

  //****************************************************************************
  //  Summary: Getter to return the whether the Base object is visible
  //  Return: boolean - is the base destroyed?
  //****************************************************************************
  public boolean isDestroyed() {
    return this.destroyed;
  }

  //****************************************************************************
  //  Summary: Setter to set whether the Base object is visible
  //****************************************************************************
  public void setDestroyed(boolean visible) {
    this.destroyed = visible;
  }

  //****************************************************************************
  //  Summary: Getter for base id
  //  Return: int - base id
  //****************************************************************************
  public int getID() {
    return this.id;
  }
  
  //****************************************************************************
  //  Summary: Setter for baseRGB
  //  Params: r - Red channel value
  //          g - Green channel value
  //          b - Blue channel value
  //****************************************************************************
  public void setBaseColour(int r, int g, int b) {
    this.baseRGB[0] = r;
    this.baseRGB[1] = g;
    this.baseRGB[2] = b;
  }
}

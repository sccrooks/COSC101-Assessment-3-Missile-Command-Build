//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: MissileBrain Interface, used when implementing new
//         missile logic.
//******************************************************************************
public interface IMissileBrain {
  public void initialize(Missile missile);
  public void calculate();
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Missile AI used for testing. This missile simply falls towards
//         the ground with no target.
//******************************************************************************
public class DumbBrain implements IMissileBrain {

  private Missile missile; // Reference to missile

  private final int minSpeed = 40; // Minimum speed of missile
  private final int maxSpeed = 70; // Maximum speed of missile

  //****************************************************************************
  //  Summary: Constructor
  //  Params: missile - Reference to missile
  //****************************************************************************
  public void initialize(Missile missile) {
    // Cache missile
    this.missile = missile;

    // Missile properties
    missile.speed = random(minSpeed, maxSpeed);
    missile.colour = 200;
  }

  //****************************************************************************
  //  Summary: Calculates the missiles path and position
  //****************************************************************************
  public void calculate() {
    // Missile falls to ground
    missile.transform.position.y += missile.speed * time.getDeltaTimeSeconds();
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Most common missile type in game. This missile will target
//         a building and fly in a straight line towards it.
//
//  Implements: IMissileBrain
//******************************************************************************
public class BasicBrain implements IMissileBrain {

  private Missile missile; // Reference to missile

  private Base targetBase;        // Base that missile is targetting
  private PVector targetPosition; // Position that missile is targetting
  private PVector path;           // PVector for the path between origin and base

  private final int minSpeed = 40; // Minimum speed of missile
  private final int maxSpeed = 70; // Maximum speed of missile

  //****************************************************************************
  //  Summary: Sets up missile logic
  //  Params: missile - The parent missile
  //****************************************************************************
  public void initialize(Missile missile) {
    // Create reference to missile
    this.missile = missile;

    // Missile properties
    missile.speed = random(minSpeed, maxSpeed);
    missile.colour = 200;

    // Get Missile target
    targetBase = findTargetBase();
    targetPosition = new PVector(targetBase.getXLocation() + 20, height - 45);
    path = new PVector(targetPosition.x - missile.launchPos.x,
      targetPosition.y - missile.launchPos.y);
  }

  //****************************************************************************
  //  Summary: Calculates the missiles path and position
  //****************************************************************************
  public void calculate() {
    path.normalize();
    path.mult(missile.speed);
    missile.transform.position.x += path.x * time.getDeltaTimeSeconds();
    missile.transform.position.y += path.y * time.getDeltaTimeSeconds();
  }

  //****************************************************************************
  //  Summary: Used to find a suitable base to target
  //  Return: Base - base to target
  //****************************************************************************
  private Base findTargetBase() {
    // Get list of living bases
    List<Base> aliveBases = environment.getAliveBases();
    // Choose a random target from the list
    Base target = aliveBases.get((int)random(0, aliveBases.size()));

    // Return random alive base
    return target;
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Faster version of the basic missile type.
//
//  Extends: Basic brain
//******************************************************************************
public class FastBrain extends BasicBrain {
  
  private final int minSpeed = 80;  // Minimum speed of missile
  private final int maxSpeed = 120; // Maximum speed of missile
  
  //****************************************************************************
  //  Summary: Sets up missile logic
  //  Params: missile - The parent missile
  //****************************************************************************
  public void initialize(Missile missile) {
    super.initialize(missile);
    missile.speed = random(minSpeed, maxSpeed);
  }
  
  //****************************************************************************
  //  Summary: Calculates the missiles path and position
  //****************************************************************************
  public void calculate() {
    super.calculate();
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Most common missile type in game. This missile will target
//         a building and fly in a straight line towards it.
//
//  Implements: IMissileBrain
//******************************************************************************
public class SmartBrain implements IMissileBrain {

  private Missile missile; // Reference to missile

  private Base targetBase;        // Base that missile is targetting
  private PVector targetPosition; // Position that missile is targetting
  private PVector path;           // PVector for the path between origin and base

  private final int minSpeed = 40; // Minimum speed of missile
  private final int maxSpeed = 70; // Maximum speed of missile

  //****************************************************************************
  //  Summary: Sets up missile logic
  //  Params: missile - The parent missile
  //****************************************************************************
  public void initialize(Missile missile) {
    // Cache missile
    this.missile = missile;

    // Missile properties
    missile.speed = random(minSpeed, maxSpeed);
    missile.colour = 200;

    // Get Missile target
    targetBase = findTargetBase();
    targetPosition = new PVector(targetBase.getXLocation() + 20, height - 45);
    path = calcPath();
  }

  //****************************************************************************
  //  Summary: Calculates the missiles path and position
  //****************************************************************************
  public void calculate() {

    // If the targetting base is destroyed and there are still alive bases,
    // find the next closest base to target
    if (targetBase.isDestroyed() && environment.getAliveBases().size() > 0) {
      targetBase = findTargetBase();
      targetPosition = new PVector(targetBase.getXLocation() + 20, height - 45);
      path = calcPath();
    }

    path.normalize();
    path.mult(missile.speed);
    missile.transform.position.x += path.x * time.getDeltaTimeSeconds();
    missile.transform.position.y += path.y * time.getDeltaTimeSeconds();
  }

  //****************************************************************************
  //  Summary: Calculates the missiles path
  //  Return: PVector path
  //****************************************************************************
  private PVector calcPath() {
    return path = new PVector(targetPosition.x - missile.launchPos.x,
      targetPosition.y - missile.launchPos.y);
  }

  //****************************************************************************
  //  Summary: Find the closest alive base to the target
  //  Return: Base - base to target
  //****************************************************************************
  private Base findTargetBase() {
    // Get list of living bases
    List<Base> aliveBases = environment.getAliveBases();

    // Find the closest base from the list
    Base closestBase = aliveBases.get(0);
    float distance = PVector.dist(missile.transform.getCenter(), closestBase.getPosition());

    // Loop though alive bases
    for (Base base : aliveBases) {
      float newDistance = PVector.dist(base.getPosition(), missile.transform.getCenter());
      if (newDistance < distance) {
        closestBase = base;
        distance = newDistance;
      }
    }

    // Return random alive base
    return closestBase;
  }
}


//****************************************************************
//  Authors: Scott Crooks
//
//  Usage: Missile AI used for testing. This missile does nothing.
//
//  Implements: IMissileBrain
//****************************************************************
public class TestBrain implements IMissileBrain {

  //****************************************************************************
  //  Summary: Sets up missile logic
  //  Params: missile - The parent missile
  //****************************************************************************
  public void initialize(Missile missile) {
    // Does nothing
  }

  //****************************************************************************
  //  Summary: Calculates the missiles path and position
  //****************************************************************************
  public void calculate() {
    // Does nothing
  }
}

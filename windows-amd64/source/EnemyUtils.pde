//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Handles missile spawning and spawn position
//******************************************************************************
public class MissileSpawner {
  
  private final GameController controller; 
  private PVector spawnZone = new PVector(width, -10);
  
  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public MissileSpawner(GameController controller) {
    this.controller = controller; 
  }
  
  //****************************************************************************
  //  Summary: Get a random spawn position based on spawnZone PVector
  //  Return: PVector, random location in spawnZone
  //****************************************************************************
  public PVector randomSpawnPosition() {
      return new PVector(random(0, spawnZone.x), 
                         random(0, spawnZone.y));
  }
  
  //****************************************************************************
  //  Summary: Get a random spawn position based on spawnZone PVector and
  //           specified transform. 
  //  Params: transform - Transform to base spawn position on
  //  Return: PVector, random location in spawnZone
  //****************************************************************************
  public PVector randomSpawnPosition(Transform transform) {
      return new PVector(random(0, spawnZone.x - transform.width), 
                         random(0, spawnZone.y - transform.height));
  }
  
  //****************************************************************************
  //  Summary: Spawn a missile based on entered missileType
  //  Params: missileType - MissileTypes enum for specifying missile type
  //****************************************************************************
  public void spawnMissile(MissileTypes missileType) {
    switch (missileType) {
      case DUMBMISSILE:  // Spawn dummy missile
                         controller.enemyMissiles.add(new Missile(this, new DumbBrain()));
                         break;
      case BASICMISSILE: // Spawn basic missile
                         controller.enemyMissiles.add(new Missile(this, new BasicBrain()));
                         break;
      case FASTMISSILE: // Spawn fast missile
                         controller.enemyMissiles.add(new Missile(this, new FastBrain()));
                         break;
      case SMARTMISSILE: // Spawn smart missile
                         controller.enemyMissiles.add(new Missile(this, new SmartBrain()));
                         break;
      case TESTMISSILE:  // Spawn test missile
                         controller.enemyMissiles.add(new Missile(this, new TestBrain()));
                         break;
      default: println("MissileSpawner: ERROR: Missile type does not exist or is not implemented!");
    }
  }
  
  //****************************************************************************
  //  Summary: Removes a missile from the game
  //  Params: missile - missile reference to destroy
  //****************************************************************************
  public void destroyMissile(Missile missile) {
    // This is an expensive operation, however, as long as we aren't
    // removing hundreds of missile at a time the performance impact should be negligible.
    gameController.enemyMissiles.remove(missile);
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Static class for missile utils
//******************************************************************************
public static class MissileUtils {
  
  //****************************************************************************
  //  Summary: Converts a string to a MissileTypes enum
  //  Params: missileType - missileType string to convert to enum
  //****************************************************************************
  public static MissileTypes getMissileTypeFromString(String missileType) {
    switch(missileType) {
      case "DUMBMISSILE":  return MissileTypes.DUMBMISSILE;
      case "BASICMISSILE": return MissileTypes.BASICMISSILE;
      case "FASTMISSILE":  return MissileTypes.FASTMISSILE;
      case "SMARTMISSILE": return MissileTypes.SMARTMISSILE;
      case "TESTMISSILE":  return MissileTypes.TESTMISSILE;
      default: // If missile type isn't found return basic missile
               println("Missile type \"" + missileType + "\" not recognised! Defaulting to Basic missile");
               return MissileTypes.BASICMISSILE;
    }
  }
}

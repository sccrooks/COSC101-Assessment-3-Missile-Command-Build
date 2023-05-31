//******************************************************************************
//  Authors: Scott Crooks, Robert Preston
//
//  Usage: Handles game data. E.g. Score, current level, missiles
//******************************************************************************
public class GameController {

  public final MissileSpawner missileSpawner; // Controls spawning missiles

  public int score;          // Tracks current score
  public int levelIndex;     // Tracks current level
  public Level currentLevel; // Current level
  public List<Level> levels; // List of all levels in game

  public List<Missile> enemyMissiles;              // Spawned enemy missiles
  public List<DefenceMissile> defenceMissiles;     // Spawned defence missiles
  public List<Explosion> missileExplosions; // Spawned explosions
  public List<Trail> trails;                       // Spawned trails

  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public GameController() {
    missileSpawner = new MissileSpawner(this);

    // Setup lists
    levels = new ArrayList<Level>();
    enemyMissiles = new ArrayList<Missile>();
    defenceMissiles = new ArrayList<DefenceMissile>();
    missileExplosions = new ArrayList<Explosion>();
    trails = new ArrayList<Trail>();

    // Prepare game with Reset
    reset();
  }

  //****************************************************************************
  //  Summary: Resets game controller and prepares for new game
  //****************************************************************************
  public void reset() {
    // Reset environment
    environment.resetEnvironment();

    // Reset data
    score = 0;
    levelIndex = 0;

    // Copy levels from content
    levels.clear();
    levels = content.getLevels();
    for (Level level : levels)
      println(level.levelOngoing);

    // Clean up lists
    enemyMissiles.clear();
    defenceMissiles.clear();
    missileExplosions.clear();
    trails.clear();

    // Allocate curent level;
    currentLevel = levels.get(levelIndex);

    // Reset bases
    for (int i = 0; i < environment.bases.length; i++)
      environment.bases[i].setDestroyed(false);

    // Add ammo to defence cannon
    cannon.setAmmo(currentLevel.ammoCount);
    cannon.setRGB(currentLevel.secondaryRGB);
    reticle.setRGB(currentLevel.getHUDRGB());
  }

  //****************************************************************************
  //  Summary: Called every frame while a game is ongoing
  //****************************************************************************
  public void run() {
    if (!currentLevel.levelOngoing)
      nextlevel();

    if (environment.isAllBasesDestroyed())
      gameOver();

    // Run logic for current level
    currentLevel.run();

    // Run/Draw missiles
    handleMissiles();
  }

  //****************************************************************************
  //  Summary: Handles drawing missiles and calculating missile positions
  //****************************************************************************
  public void handleMissiles() {
    // Run/Draw the trails
    // We do this first as to not overlap the missiles
    if (trails.size() > 0) {
      for (int i = 0; i < trails.size(); i++) {
        Trail trail = trails.get(i);
        trail.draw();
      }
    }

    // Draw missiles
    for (int i = 0; i < enemyMissiles.size(); i++) {
      enemyMissiles.get(i).draw();
      enemyMissiles.get(i).run();
    }

    // Run/Draw defenceMissiles
    for (int i = 0; i < defenceMissiles.size(); i++) {
      DefenceMissile missile = defenceMissiles.get(i);
      missile.draw();
      missile.run();
      if (missile.onTarget()) {
        missileExplosions.add(new Explosion(missile.transform.position, 120, true));
        content.playSound("flakExplosion");
        missile.destroy();
        defenceMissiles.remove(i);
      }
    }

    // Run/Draw missileExplosions
    for (int i = 0; i < missileExplosions.size(); i++) {
      Explosion explosion = missileExplosions.get(i);
      explosion.draw();

      // If explosion is friendly check collision with enemy missiles
      if (explosion.friendly && !explosion.exploded) {
        for (int x = 0; x < enemyMissiles.size(); x++) {
          Missile missile = enemyMissiles.get(x);
          
          // Check collision
          if (Collision.circleSquareCollision(explosion.center, explosion.radius, missile.transform)) {
            explosion.exploded = true;
            missile.setDestroyed(true);
            
            // Increase score for missile destroyed
            score += currentLevel.baseReward * currentLevel.rewardMultiplier;
          }
        }
      }

      if (explosion.lifespan < 1)
        missileExplosions.remove(explosion);
    }
  }

  //****************************************************************************
  //  Summary: Creates a new trail piece
  //****************************************************************************
  public Trail NewTrail() {
    Trail trail = new Trail();
    trails.add(trail);
    return trail;
  }

  //****************************************************************************
  //  Summary: Attempts to start the next level, if there are no levels left it
  //           ends game. If there are levels left, prepare for next level.
  //****************************************************************************
  public void nextlevel() {
    
    // If there are still missiles in scene wait for them to despawn
    // before starting the next wave.
    if (gameController.enemyMissiles.size() > 0)
      return;
    
    // Increase index to represent next level
    levelIndex++;

    // Add bonus score for remaining ammo and bases
    score += cannon.getAmmo() * (currentLevel.baseReward / 2);
    score += environment.getAliveBases().size() * (currentLevel.baseReward * currentLevel.rewardMultiplier);

    // If no more levels remain end game
    if (levelIndex >= levels.size()) {
      gameOver();
      return;
    }

    // Get the next level from levels list
    currentLevel = levels.get(levelIndex);
    cannon.setAmmo(currentLevel.ammoCount);

    // Reset bases
    for (int i = 0; i < environment.bases.length; i++) {
      environment.bases[i].setDestroyed(false);
    }

    environment.setPrimaryRGB(currentLevel.getPrimaryRGB());
    environment.setSecondaryRGB(currentLevel.getSecondaryRGB());
    environment.setHUDRGB(currentLevel.getHUDRGB());
    cannon.setRGB(currentLevel.getSecondaryRGB());
    reticle.setRGB(currentLevel.getHUDRGB());
  }
  
  //****************************************************************************
  //  Summary: Force starts the next level
  //****************************************************************************
  public void forceNextLevel() {
    // Increase index to represent next level
    levelIndex++;

    // If no more levels remain end game
    if (levelIndex >= levels.size()) {
      gameOver();
      return;
    }

    // Get the next level from levels list
    currentLevel = levels.get(levelIndex);
    cannon.setAmmo(currentLevel.ammoCount);

    // Reset bases
    for (int i = 0; i < environment.bases.length; i++) {
      environment.bases[i].setDestroyed(false);
    }

    environment.setPrimaryRGB(currentLevel.getPrimaryRGB());
    environment.setSecondaryRGB(currentLevel.getSecondaryRGB());
    environment.setHUDRGB(currentLevel.getHUDRGB());
    cannon.setRGB(currentLevel.getSecondaryRGB());
    reticle.setRGB(currentLevel.getHUDRGB());
  }
  
  //****************************************************************************
  //  Summary: Force starts the next wave
  //****************************************************************************
  public void forceNextWave() {
    currentLevel.waveCompleted();
  }

  //****************************************************************************
  //  Summary: Ends the game and performs game over tasks
  //****************************************************************************
  public void gameOver() {
    // Set the hud to white
    environment.setHUDRGB(255, 255, 255);

    // We switch to highscore state for checking highscores
    stateManager.switchState(stateManager.highscoreState);
  }
  
  //****************************************************************************
  //  Usage: Add a new missile explosion
  //  Params: explosion = MissileExplosion to add
  //****************************************************************************
  public void addMissileExplosion(Explosion explosion) {
    this.missileExplosions.add(explosion);
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Manages data and functions for levels in game.
//
//  Implements: Cloneable - Used for copying level on game start
//******************************************************************************
public class Level implements Cloneable {
  
  public final List<Wave> waves;       // List of waves in this level
  public final boolean continuousWaves;// Should waves be continuous?
  public final float rewardMultiplier; // Reward multiplier for level
  public final int baseReward;         // Base reward for this level
  public final int ammoCount;          // The amount of ammo granted for level
  private final int[] primaryRGB;      // Primary RGB values for game
  private final int[] secondaryRGB;    // Secondary RGB values for game
  private final int[] hudRGB;          // HUD RGB values for overlay
  private final int[] backgroundRGB;   // Background rgb values

  private int currentWaveIndex; // Index of the running wave
  private Wave currentWave;     // The current running wave
  private float waveTimer;      // Timer for tracking spawn delay
  private int missilesSpawned;  // Total count of missiles spawned in wave so far
  public boolean levelOngoing;  // Is the level ongoing?

  //****************************************************************************
  //  Usage: Constructor
  //  Params: waves - List of waves to spawn in this level
  //          rewardMultiplier - reward multiplier for this level
  //          baseReward - base reward value for this level
  //          ammoCount - The amount of ammo the player gets for this level
  //****************************************************************************
  public Level(List<Wave> waves, boolean continuousWaves, int baseReward, 
    float rewardMultiplier, int ammoCount, int[] primaryRGB, int[] secondaryRGB, 
    int[] hudRGB, int[] backgroundRGB) {
    this.waves = waves;
    this.continuousWaves = continuousWaves;
    this.rewardMultiplier = rewardMultiplier;
    this.baseReward = baseReward;
    this.ammoCount = ammoCount;
    this.primaryRGB = primaryRGB;
    this.secondaryRGB = secondaryRGB;
    this.hudRGB = hudRGB;
    this.backgroundRGB = backgroundRGB;

    currentWaveIndex = 0;
    waveTimer = 0;
    missilesSpawned = 0;
    currentWave = waves.get(currentWaveIndex);
    levelOngoing = true;
  }

  //****************************************************************************
  //  Usage: Called every frame, runs core functionality for this level
  //  Params: None
  //  Returns: Void
  //****************************************************************************
  public void run() {
    // Has the wave spawned all of its requested missiles?
    if (missilesSpawned > currentWave.missileCount) {
      // If waves are continuous, start the next wave without waiting for
      // missiles to despawn.
      if (!continuousWaves) {
        // If there are no missiles spawned in request next wave
        if (!(gameController.enemyMissiles.size() > 0))
          waveCompleted();
      } else {
        waveCompleted();
      }
      return;
    }

    // Increase wave timer by delta seconds
    waveTimer += time.getDeltaTimeSeconds();

    // If timer is larger then spawn delay spawn enemies
    if (waveTimer >= currentWave.spawnDelay) {
      missilesSpawned++;
      gameController.missileSpawner.spawnMissile(currentWave.missileType);
      waveTimer = 0;
    }
  }

  //****************************************************************************
  //  Summary: Called once a wave is completed. We reset wave related counters
  //         here. If we detect there are no waves left we call levelCompleted
  //****************************************************************************
  public void waveCompleted() {
    currentWaveIndex++;

    // If there are no more waves left end level
    if (currentWaveIndex >= waves.size()) {
      levelCompleted();
      return;
    }

    // Prepare next wave
    waveTimer = 0;
    missilesSpawned = 0;
    currentWave = waves.get(currentWaveIndex);
  }

  //****************************************************************************
  //  Usage: Called once this level is completed. Here we end level
  //  Params: None
  //  Returns: Void
  //****************************************************************************
  public void levelCompleted() {
    levelOngoing = false;
  }

  //****************************************************************************
  //  Summary: Getter for primaryRGB
  //  Params: None
  //  Return: Returns an int array of rgb colour channels
  //****************************************************************************
  public int[] getPrimaryRGB() {
    return primaryRGB;
  }

  //****************************************************************************
  //  Summary: Getter for secondaryRGB
  //  Params: None
  //  Return: Returns an int array of rgb colour channels
  //****************************************************************************
  public int[] getSecondaryRGB() {
    return secondaryRGB;
  }

  //****************************************************************************
  //  Summary: Getter for hudRGB
  //  Params: None
  //  Return: Returns an int array of rgb colour channels
  //****************************************************************************
  public int[] getHUDRGB() {
    return hudRGB;
  }

  //****************************************************************************
  //  Usage: Creates a clone of this level
  //  Returns: Level
  //****************************************************************************
  @Override
    public Level clone() {
    Level level = new Level(this.waves, this.continuousWaves, this.baseReward, this.rewardMultiplier,
      this.ammoCount, this.primaryRGB, this.secondaryRGB, this.hudRGB, this.backgroundRGB);
    return level;
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Stores data related to individual waves within levels
//******************************************************************************
public class Wave {
  
  public final MissileTypes missileType;  // Missile type to spawn in wave
  public final int missileCount;          // How many missiles to spawn
  public final float spawnDelay;          // Delay between spawning missiles

  //****************************************************************************
  //  Usage: Constructor
  //  Params: missileType - What type of missile to spawn
  //          missileCount - How many missiles to spawn
  //          spawnDelay - Delay between spawning missiles
  //****************************************************************************
  public Wave(MissileTypes missileType, int missileCount, float spawnDelay) {
    this.missileType = missileType;
    this.missileCount = missileCount;
    this.spawnDelay = spawnDelay;
  }

  //****************************************************************************
  //  Usage: Constructor
  //  Params: missileType - What type of missile to spawn
  //          missileCount - How many missiles to spawn
  //          spawnDelay - Delay between spawning missiles
  //****************************************************************************
  public Wave(String missileType, int missileCount, float spawnDelay) {
    // Convert string to enum with utils class
    this.missileType = MissileUtils.getMissileTypeFromString(missileType);
    this.missileCount = missileCount;
    this.spawnDelay = spawnDelay;
  }
}

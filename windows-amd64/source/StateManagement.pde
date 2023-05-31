//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameState Interface, used when implementing new game states
//******************************************************************************
public interface GameState {
  public void run();         // Core loop, called every frame
  public void enter();       // Called when state is entered
  public void exit();        // Called when state is Exited
  public void drawDisplay(); // Called when attempting to draw state to screen.
  public void handleInput(); // Called when input is detected
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Statemanager, central state controller, controls game state,
//         switching states and other core functionality.
//
//  Important: If a new state is created add it to this controller.
//
//******************************************************************************
public class StateManager implements GameState {

  // Game States
  public final GameStateMainMenu mainMenuState;         // Main Menu state
  public final GameStateRunning runningState;           // Game Running state
  public final GameStatePaused pausedState;             // Game Paused state
  public final GameStateFinished gameOverState;         // Game Over state
  public final GameStateHighscore highscoreState;       // Highscore state
  public final GameStateAddHighscore addHighscoreState; // Add Highscore state

  // Current game state
  public GameState currentState;

  //****************************************************************************
  //  Summary: Constructor
  //****************************************************************************
  public StateManager() {
    // Initialize States
    mainMenuState = new GameStateMainMenu();
    runningState = new GameStateRunning();
    pausedState = new GameStatePaused();
    gameOverState = new GameStateFinished();
    highscoreState = new GameStateHighscore();
    addHighscoreState = new GameStateAddHighscore();

    // Switch state to main menu
    switchState(mainMenuState);
  }

  //****************************************************************************
  //  Summary: Use to switch game state, will exit previous state and enter new state
  //  Params: nextState - State to switch to
  //****************************************************************************
  public void switchState(GameState nextState) {
    // Cache previous game state
    GameState prevState = currentState;

    // If state or prevState is null something has gone wrong and we will transition to the main menu state
    // This will also occur when the game is started for the first time as there will not be a previous state,
    // however, as we are attempting to display the main menu regardless this has been left as is.
    if (nextState == null || prevState == null) {
      if (!gameLaunching) // We only want to send this error when game is launching
        println("[StateManager] Looks like something went wrong! Returning to mainMenu");
      else
        println("[StateManager] Switching to Main Menu");
      currentState = mainMenuState;
      currentState.enter();
      return;
    }

    prevState.exit();          // Exit previous state
    currentState = nextState;  // Set new state
    currentState.enter();      // Enter new state
  }

  //****************************************************************************
  //  Summary: Core loop, called every frame
  //****************************************************************************
  public void run() {
    currentState.run();
  }

  //****************************************************************************
  //  Summary: Called when a state is entered
  //****************************************************************************
  public void enter() {
    currentState.enter();
  }

  //****************************************************************************
  //  Summary: Called when a state is Exited
  //****************************************************************************
  public void exit() {
    currentState.exit();
  }

  //****************************************************************************
  //  Summary: Called when attempting to draw hud to screen.
  //****************************************************************************
  public void drawDisplay() {
    // We intend to use the same colour for all hud elements
    // So we set it here
    fill(environment.getHUDRGB()[0], environment.getHUDRGB()[1], environment.getHUDRGB()[2]);
    // Draw current state dispplay
    currentState.drawDisplay();
  }

  //****************************************************************************
  //  Summary: Called when input is detected
  //****************************************************************************
  public void handleInput() {
    // If cheats are enabled use them
    if (cheatsEnabled)
      performCheats();

    // Toggle for debug mode
    if (key == '`') {
      debugMode = !debugMode;
      
      if (debugMode)
        println("Debug Mode Enabled");
      else
        println("Debug Mode Disabled");
    }
    
    // Toggle for cheats
    if (key == '~') {
      cheatsEnabled = !cheatsEnabled;
      
      if (cheatsEnabled)
        println("Cheats Enabled");
      else
        println("Cheats Disabled");
    }

    // Perform state specific input
    currentState.handleInput();
  }

  //****************************************************************************
  //  Summary: Handles global cheats
  //****************************************************************************
  private void performCheats() {
    switch(key) {
      case '[': // Slow down game
                time.decreaseSpeed(0.2);
                return;
      case ']': // Speed up game
                time.increaseSpeed(0.2);
                return;
      case '\\':// Reset Speed
                time.resetSpeedMultiplier();
                return;
     case '4':  //DEBUG: Increase score
                gameController.score += gameController.currentLevel.baseReward *
                  gameController.currentLevel.rewardMultiplier;
                return;
    }
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStateRunning, core game loop, all methods while game is running
//         are executed here.
//
//  Implements: GameState
//******************************************************************************
public class GameStateRunning implements GameState {

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
    // Set reticle position to center of screen
    reticle.resetPosition();
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void exit() {
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() {
    // Run game Controller
    gameController.run();

    // Draw reticle
    reticle.draw();
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void drawDisplay() {
    // Convert Score to String
    String scoreString = String.valueOf(gameController.score);

    // Display Score
    textSize(content.fontSizeTitle);
    text(scoreString, (width / 2) - scoreString.length() * 15, 20 + content.fontSizeTitle);
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    // "Reticle" movement controls
    switch(keyCode) {
      case UP:    reticle.moveUp();
                  break;
      case DOWN:  reticle.moveDown();
                  break;
      case LEFT:  reticle.moveLeft();
                  break;
      case RIGHT: reticle.moveRight();
                  break;
    }

    // Keybinds
    switch(key) {
      case '1': // Force end game
                gameController.gameOver();
                break;
      case '2': // Force end Level
                if (cheatsEnabled)
                  gameController.forceNextLevel();
                break;
      case '3': // Force end Wave
                if (cheatsEnabled)
                  gameController.forceNextWave();
                break;
      case 'p': // Pause Game logic
                stateManager.switchState(stateManager.pausedState);
                break;
      case ' ': // Firing cannon
                cannon.fireCannon();
    }
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStatePaused, used to Pause the game
//
//  Implements: GameState
//******************************************************************************
public class GameStatePaused implements GameState {

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() {
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void exit() {
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void drawDisplay() {
    // Convert Score to String
    String scoreString = String.valueOf(gameController.score);

    textSize(content.fontSizeTitle);

    // Display Score
    text(scoreString, (width / 2) - scoreString.length() * 15, 20 + content.fontSizeTitle);
    // Display Paused Text
    text("GAME PAUSED", (width / 2) - 165, (height / 2) - content.fontSizeTitle);
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    switch(key) {
      case '1': // Debug: Force game over
                stateManager.switchState(stateManager.highscoreState);
                break;
      case 'p': // Unpause game logic
                stateManager.currentState = stateManager.runningState;
                break;
    }
  }
}

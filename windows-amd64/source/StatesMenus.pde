//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStateMainMenu, used to display MainMenu Graphics
//
//  Implements: GameState
//******************************************************************************
public class GameStateMainMenu implements GameState {
  
  private PVector uiPosition;     // Position of UI
  private BlinkingText startText; // "Press any key to start" blinker
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() {
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
    // Setup ui positions
    uiPosition = new PVector(width /2 - 140, height /2 - 100);
    
    // Leaderboard
    highscoreLeaderboard.setPosition(new PVector(uiPosition.x - 10, uiPosition.y));
    
    // Blinking start game text
    startText = new BlinkingText(2, 1, "Press any key to start!", 
      content.fontSizeSubtitle, new PVector(uiPosition.x - 10, uiPosition.y + 300));
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
    
    // Display title
    textSize(content.fontSizeTitle);
    text("Missile Command", uiPosition.x - 70, uiPosition.y - 60);
    
    // Display leaderboard
    highscoreLeaderboard.display();
    
    // Draw blinking start game text
    startText.draw();
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    // When key is pressed start game
    stateManager.switchState(stateManager.runningState); 
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStateHighscore, used to display display menu for new highscores
//
//  Implements: GameState
//******************************************************************************
public class GameStateHighscore implements GameState {
  
  private PVector uiPosition;
  private boolean saveHighscoreSelector; // Current selection that the selector is set to
  private SaveScore saveScore;           // Selector option chosen; e.g. YES - Add new highscore, NO - don't add

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() { 
    // Check if option has been selected
    switch (saveScore) {
      case YES:     stateManager.switchState(stateManager.addHighscoreState);
                    break;
      case NO:      stateManager.switchState(stateManager.gameOverState);
                    break;
    }
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
    // If current score is not a highscore transition to game over state
    if (!highscoreLeaderboard.newHighscore(gameController.score))
      stateManager.switchState(stateManager.gameOverState);
    
    // Setup state
    uiPosition = new PVector(width / 2 - 135, height / 2 - 110);
    saveHighscoreSelector = true; // Set Selector to "YES"
    saveScore = SaveScore.UNKNOWN;// Set Selection to "UNKNOWN"
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
    // Draw "HIGHSCORE" title
    textSize(content.fontSizeTitle);
    text("HIGHSCORE!", uiPosition.x, uiPosition.y);

    // Draw subtitle
    textSize(content.fontSizeSubtitle);
    text("Do you want to add it to the list?", uiPosition.x - 90, uiPosition.y + 50);

    // Draw Yes/No Selection
    textSize(content.fontSizeSubtitle);
    text("\"Yes\" / \"No\"", uiPosition.x + 55, uiPosition.y + 80);

    // Draw the selector under selected option
    if (saveHighscoreSelector)
      rect(uiPosition.x + 66, uiPosition.y + 85, 43, 4);
    else
      rect(uiPosition.x + 160, uiPosition.y + 85, 28, 4);
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    // Control YES/NO selector
    switch(keyCode) {
      case LEFT:  saveHighscoreSelector = true; // Move selector to YES
                  break;
      case RIGHT: saveHighscoreSelector = false;// Move selector to NO
                  break;
    }

    // Select current option
    if (key == ' ') {
      if (saveHighscoreSelector) 
        saveScore = SaveScore.YES;
      else 
        saveScore = SaveScore.NO;
    }
  }
}

// Save score enum used in GameStateHighscore as a method of managing selection
enum SaveScore {
  UNKNOWN,
    YES,
    NO
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStateAddHighscore, manages data for adding a new highscore
//  Implements: GameState
//******************************************************************************
public class GameStateAddHighscore implements GameState {
  
  private String name;             // Entered name
  private int maxNameLength;       // Max length of name
  private String nameUnderline;    // Name underline
  private PVector uiPosition;      // Position of displays

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() {
  }

  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
    // Reset state on enter
    name = "";
    maxNameLength = 8;
    nameUnderline = "________";
    uiPosition = new PVector(width / 2, height / 2);
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
    // Draw "HIGHSCORE" title
    textSize(content.fontSizeTitle);
    text("HIGHSCORE!", uiPosition.x - 120, uiPosition.y - content.fontSizeTitle - 100);

    // Draw enter name subtitle
    textSize(content.fontSizeSubtitle);
    text("Enter your name", uiPosition.x - 90, uiPosition.y - content.fontSizeSubtitle - 80);

    // Display name
    textSize(content.fontSizeSubtitle);
    text(name, uiPosition.x - 45, uiPosition.y - content.fontSizeSubtitle - 50);
    
    // Display name underline
    textSize(content.fontSizeSubtitle);
    text(nameUnderline, uiPosition.x - 45, uiPosition.y - content.fontSizeSubtitle - 40);
    
    // Draw instructions text
    textSize(content.fontSizeSubtitle);
    text("Press SPACE or RETURN to continue", uiPosition.x - 210, uiPosition.y - content.fontSizeSubtitle);
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    // Save score to current name
    if (keyCode == ENTER || key == ' ') {
      saveScore(); 
      return;
    }
    
    // Allow backspacing
    if (keyCode == BACKSPACE) {
      if (name != null && !name.trim().isEmpty()) {
        name = name.substring(0, name.length() - 1);
      }
      return;
    }

    // Return here so we don't record ASCII characters
    if (key == CODED) return; 

    // Return here so we don't go over max name length
    if (name.length() >= maxNameLength) return; 
    
    // Add key to current name and format
    name += key;               
    name.trim().toUpperCase();
  }
  
  //****************************************************************************
  //  Summary: Used to save score or exit state
  //****************************************************************************
  private void saveScore() {
    if (name.trim().length() == 0)
      // Switch to game over on empty name
      stateManager.switchState(stateManager.gameOverState);
    else {
      // Save highscore and switch to game over
      highscoreLeaderboard.addHighscore(gameController.score, name);
      stateManager.switchState(stateManager.gameOverState);
    }
  }
}

//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: GameStateFinished, used to display GameOver Graphics
//  Implements: GameState
//******************************************************************************
public class GameStateFinished implements GameState {
 
  PVector uiPosition;       // Position of ui
  BlinkingText restartText; // "Press any key to restart!" blinker
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void run() {
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void enter() {
    // Reset state on enter
    uiPosition = new PVector((width / 2), (height / 2) - 120);
    
    // Set highscore leaderboard position
    highscoreLeaderboard.setPosition(new PVector(uiPosition.x - 145, uiPosition.y));
    
    // Blinking restart game text
    restartText = new BlinkingText(2, 1, "Press any key to restart!", 
      content.fontSizeSubtitle, new PVector(uiPosition.x - 170, uiPosition.y + 300)); 
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void exit() {
    // Reset game controller
    gameController.reset();
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void drawDisplay() {
    // Draw "GAMEOVER" title
    textSize(content.fontSizeTitle);
    text("GAMEOVER", uiPosition.x - 115, uiPosition.y - 90);
    
    // Setup score subtitle
    textSize(content.fontSizeSubtitle);
    String scoreString = "Score: " + String.valueOf(gameController.score);
    
    // Display Score
    text(scoreString, uiPosition.x + 5 - scoreString.length() * 7.5, uiPosition.y - 60);
    
    // Display High scores
    highscoreLeaderboard.display();
    
    // Display Restart subtitle
    restartText.draw();
  }
  
  //****************************************************************************
  //  Summary: Interface method, see GameState for details
  //****************************************************************************
  public void handleInput() {
    // On any input switch to game state
    stateManager.switchState(stateManager.runningState);
  }
}

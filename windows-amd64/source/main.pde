//******************************************************************************
//
//  COSC101 Assignment 1: Missile Command
//
//  Authors: Scott Crooks, Andrew McKenzie, Robert Preston
//  
//  Usage:
//
//  Addition Information: Check readme.md file
//
//******************************************************************************

import processing.sound.*;
import java.util.*;

// Debug settings
boolean debugMode;     // Is debug mode enabled?
boolean cheatsEnabled; // Are cheats enabled?
boolean gameLaunching; // Is the game launch in progress? Used for launch processes

// State manager
StateManager stateManager; // Global statemanagement system. Reference this when switching state/menu

// Classes
Content content;                           // Content system, use this for loading files from external directories
Time time;                                 // Time class, used for tracking time and deltaTime
Reticle reticle;                           // Reticle class, used to display player reticle
Environment environment;                   // Environment class, used as the backdrop to the game and controls displaying bases
Cannon cannon;                             // Cannon class, used to draw and control the defence cannon
HighscoreLeaderboard highscoreLeaderboard; // Highscore display, used for displaying highscores on mainmenu and Gameover menu
GameController gameController;             // Gamecontroller controls actual game functionality. E.g. Score and level

//******************************************************************************
//  Summary: In-built processing function that is called once on startup
//           We initialize the project and global classes here.
//******************************************************************************
void setup() {
  gameLaunching = true;
  
  // Resolution 16:9 @ 30fps
  size(1280,720);
  frameRate(30);
  
  // Initialize classes
  content = new Content();
  time = new Time();
  reticle = new Reticle();
  environment = new Environment();
  cannon = new Cannon();
  highscoreLeaderboard = new HighscoreLeaderboard();
  gameController = new GameController();
  
  // Initialize state manager last as  this will start the game
  stateManager = new StateManager();
  
  // Game is no longer launching so set this to false
  gameLaunching = false;
}

//******************************************************************************
//  Summary: In-built processing function that is called once every frame
//           If a system MUST be called every frame we put it in this
//           gobal method. Otherwise we call statemanager.run() to 
//           run state specific logic each frame.
//******************************************************************************
void draw() {
  // We need to calculate the delta time once every frame or else
  // our delta time will fall out of synce with actual time. Thus,
  // we have put it in global draw call.
  time.calcDeltaTime(); 
  
  // If the game is in debug mode, print the following stats to console.
  if (debugMode) {
    println("DELTA TIME: " + time.getDeltaTimeSeconds() + " (seconds)");
    println("CURRENTSTATE: " + stateManager.currentState.getClass().getSimpleName());
  }
  
  // We draw the environment every frame for every state so that we
  // have a nice backdrop for menus.
  environment.draw();
  
  // Perform state specific logic every frame
  stateManager.run();
  
  // Draw display after performing state logic
  stateManager.drawDisplay();
}

//******************************************************************************
//  Summary: In-built processing function that is called once whenever
//           a key is pressed. For us we delegate this event to our
//           state manager as inputs vary between states.
//******************************************************************************
void keyPressed() {
  stateManager.handleInput();
}

//******************************************************************************
//  Summary: Performs exit functionality
//******************************************************************************
void exit() {
  // Save user preferences in case they have veen changed
  content.saveUserPreferences();
  
  // Perform normal exit logic
  super.exit();
}

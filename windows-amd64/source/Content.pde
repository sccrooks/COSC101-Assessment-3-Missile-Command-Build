//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Manages content/data loading and saving.
//******************************************************************************
public class Content {

  // Directories
  private final String dataDir = "data/";
  private final String fontDir = "data/fonts/";
  private final String soundDir = "data/sounds/";
  private final String levelDir = "data/levels/";
  private final String savedataDir = "data/savedata/";

  // Fonts
  public final PFont upheavtt;         // Custom font
  public final float fontSizeTitle;    // Title font size
  public final float fontSizeSubtitle; // Subtitle font size

  // Sounds
  private final HashMap<String, SoundFile> sounds = new HashMap<String, SoundFile>();

  // Save data
  private List<Score> highscores = new ArrayList<Score>();
  public final int maxNumOfHighscores = 6;

  // Level data
  public List<Level> levels;

  //****************************************************************************
  //  Summary: Constructor; we load all game content when this constructor is
  //           called.
  //****************************************************************************
  public Content() {
    println("Loading content...");

    // Load font settings
    println("Loading font settings...");
    fontSizeTitle = 48;
    fontSizeSubtitle = 24;
    upheavtt = createFont(fontDir + "upheavtt.ttf", fontSizeTitle); // Import custom font
    textFont(upheavtt); // Set font to new font
    println("Loaded font settings!");

    // Load Sounds
    println("Loading sounds...");
    sounds.put("ReticleMove", new SoundFile(main.this, soundDir + "ReticleMove.mp3"));
    sounds.put("BaseCollapse", new SoundFile(main.this, soundDir + "BaseCollapse.mp3"));
    sounds.put("CannonFire", new SoundFile(main.this, soundDir + "CannonFire.mp3"));
    sounds.put("flakExplosion", new SoundFile(main.this, soundDir + "flakExplosion.mp3"));
    println("Loaded sounds!");

    // Load Data
    loadHighscores();
    loadLevelData();
    loadUserPreferences();

    println("Content loaded!");
  }

  //****************************************************************************
  //  Summary: Plays requested audio clip from sounds hashmap
  //  Params: name: Name of requested audio clip
  //****************************************************************************
  public void playSound(String name) {
    try {
      sounds.get(name).play();
    }
    catch(Exception e) {
      println("Sound not found!");
    }
  }

  //****************************************************************************
  //  Summary: Load highscores from savedata/highscores.json
  //****************************************************************************
  public void loadHighscores() {
    try {
      println("Loading highscores...");

      // Load highscore Json File
      JSONArray scores = loadJSONArray(savedataDir + "highscores.json");

      // For each JSON object in file add to highscore list
      for (int i = 0; i < scores.size(); i++) {
        JSONObject score = scores.getJSONObject(i);
        highscores.add(new Score(score.getString("name"), score.getInt("score")));
      }

      // Fill out any remaining highscore slots with empty values
      while (highscores.size() < maxNumOfHighscores) {
        highscores.add(new Score());
      }
      println("Highscores loaded!");
    }
    catch(Exception e) {
      println("Something went wrong! Failed to load highscores");
    }
  }

  //****************************************************************************
  //  Summary: Save highscores to savedata/highscores.json
  //****************************************************************************
  public void saveHighscores() {
    try {
      // Create JSONArray
      JSONArray scores = new JSONArray();

      // For each highscore in list write to JSONArray
      for (int i = 0; i < highscores.size() || i < maxNumOfHighscores; i++) {
        JSONObject score = new JSONObject();
        score.setString("name", highscores.get(i).name);  // Save Name
        score.setInt("score", highscores.get(i).score);   // Save Score

        scores.setJSONObject(i, score);
      }

      // Save to file
      saveJSONArray(scores, savedataDir + "highscores.json");
      println("Highscores saved!");
    }
    catch (Exception e) {
      println("Something went wrong! Failed to save highscores");
    }
  }

  //****************************************************************************
  //  Summary: Load level data from data/levels/levels.json and save
  //           to levels list.
  //****************************************************************************
  public void loadLevelData() {
    try {
      println("Loading levels...");

      // Load levels Json File
      JSONArray levelsJSON = loadJSONArray(levelDir + "levels.json");

      // Create Levels list
      levels = new ArrayList<Level>();

      // For each JSON object in file add to levels list
      for (int i = 0; i < levelsJSON.size(); i++) {
        // Cache current levels JSONObject
        JSONObject level = levelsJSON.getJSONObject(i);

        // Cache level modifiers
        int baseReward = level.getInt("baseReward");
        float rewardMultiplier = level.getFloat("rewardMultiplier");
        int ammoCount = level.getInt("ammo");
        boolean continuousWaves = level.getBoolean("continuousWaves");

        // Cache level RGB values
        int[] primaryRGB = level.getIntList("primaryRGB").toArray();
        int[] secondaryRGB = level.getIntList("secondaryRGB").toArray();
        int[] hudRGB = level.getIntList("hudRGB").toArray();
        int[] backgroundRGB = level.getIntList("backgroundRGB").toArray();

        // Create a list of the waves for this level
        List<Wave> waves = new ArrayList<Wave>();
        // Cache two-dimensional JSON array that we will be reading wave data from
        JSONArray wavesJSON = level.getJSONArray("waves");

        // Read through two dimensional array
        for (int x = 0; x < wavesJSON.size(); x++) {
          // Cache inner one dimensional array at x
          JSONArray wave = wavesJSON.getJSONArray(x);
          // Add new wave to waves list
          waves.add(new Wave(wave.getString(0), wave.getInt(1), wave.getFloat(2)));
        }

        // Add finalised level to levels list
        levels.add(new Level(waves, continuousWaves, baseReward, rewardMultiplier,
          ammoCount, primaryRGB, secondaryRGB, hudRGB, backgroundRGB));
      }

      // Fill out remaining highscore slots with empty values
      while (highscores.size() < maxNumOfHighscores) {
        highscores.add(new Score());
      }

      println("Levels loaded!");
    }
    catch (Exception e) {
      println("Something went wrong! Failed to load level data");
    }
  }

  //****************************************************************************
  //  Summary: Setter for highscore array list, saves highscores to
  //           highscores.json when called.
  //  Params: scores: What to set the highscores list to.
  //****************************************************************************
  public void setHighscores(List<Score> scores) {
    // Ensure that new list size is not greater than maxNumOfHighscores
    // If it is trim it to size
    if (scores.size() > maxNumOfHighscores) {
      scores = scores.subList(0, maxNumOfHighscores);
    }

    // Set highscores list to new list
    highscores = scores;
    saveHighscores(); // Make sure to save highscores when list to modified
  }

  //****************************************************************************
  //  Summary: Getter for highscore array list
  //  Return: ArrayList<Score>
  //****************************************************************************
  public List<Score> getHighscores() {
    return highscores;
  }

  //****************************************************************************
  //  Summary: "Getter" for highscore array list.
  //           Creates a deep copy of the levels list in order to
  //           prevent modification of loaded levels.
  //  Return: ArrayList<Score>
  //****************************************************************************
  public List<Level> getLevels() {
    List<Level> copyOfLevels = new ArrayList<Level>();

    for (Level level : levels)
      copyOfLevels.add(level.clone());

    return copyOfLevels;
  }

  //****************************************************************************
  //  Summary: Load user preferences from data/userPreferences.json
  //****************************************************************************
  public void loadUserPreferences() {
    try {
      println("Loading user preferences...");
      JSONArray userPrefsJSON = loadJSONArray(dataDir + "userPreferences.json");
      JSONObject userPrefs = userPrefsJSON.getJSONObject(0);

      cheatsEnabled = userPrefs.getBoolean("cheatsEnabled");
      debugMode = userPrefs.getBoolean("debugEnabled");
      println("Loaded user preferences!");
    }
    catch (Exception e) {
      println(e);
    }
  }

  //****************************************************************************
  //  Summary: Save user preferences to data/userPreferences.json
  //****************************************************************************
  public void saveUserPreferences() {
    try {
      println("Saving user preferences...");
      // Create JSONArray
      JSONArray userPreferences = new JSONArray();

      // Create prefs object
      JSONObject prefs = new JSONObject();
      prefs.setBoolean("cheatsEnabled", cheatsEnabled);
      prefs.setBoolean("debugEnabled", debugMode);

      // Add prefs to JSONArray
      userPreferences.setJSONObject(0, prefs);

      // Save to file
      saveJSONArray(userPreferences, dataDir + "userPreferences.json");
      println("User preferences saved!");
    }
    catch (Exception e) {
      println(e);
    }
  }
}


//******************************************************************************
//  Authors: Scott Crooks
//
//  Usage: Score object, used for storing score data
//******************************************************************************
public class Score {

  public String name; // user name
  public int score;   // user score

  //****************************************************************************
  //  Summary: Constructor, when called create an "empty" score
  //****************************************************************************
  public Score() {
    name = "...............";
    score = 0;
  }

  //****************************************************************************
  //  Summary: Constructor
  //  Params: name: Name of user
  //          score: Score of user
  //****************************************************************************
  public Score(String name, int score) {
    this.name = name;
    this.score = score;
  }
}

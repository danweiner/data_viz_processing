PImage mapImage;
Table locationTable;
Table nameTable;
int rowCount;

Table dataTable;
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;

float closestDist;
String closestText;
float closestTextX;
float closestTextY;

void setup() {
  size(640, 400);
  PFont font = loadFont("STIXVariants-Bold-12.vlw");
  textFont(font);
  mapImage = loadImage("map.png");
  // Make a data table from a file that contains
  // the coordinates of each state
  locationTable = new Table("locations.tsv");
  rowCount = locationTable.getRowCount();
  
  // Read the data table
  dataTable = new Table("random.tsv");
  
  nameTable = new Table("names.tsv");
  
  // Find min and max values
  for (int row = 0; row < rowCount; row++) {
    float value = dataTable.getFloat(row, 1);
    if (value > dataMax) {
      dataMax = value;
    }
    if (value < dataMin) {
      dataMin = value;
    }
  }
}

void draw() {
  background(255);
  image(mapImage, 0, 0);
  
  closestDist = MAX_FLOAT;
  
  // Drawing attributes for the ellipses
  smooth();
  fill(192, 0, 0);
  noStroke();
  
  // Loop through the rows of the locations file and draw the points
  for (int row = 0; row < rowCount; row++) {
    String abbrev = dataTable.getRowName(row);
    float x = locationTable.getFloat(abbrev, 1); // column 1
    float y = locationTable.getFloat(abbrev, 2); // column 2
    drawData(x, y, abbrev);
  }
  
  // use global vars set in drawData() to
  // draw text related to closest circle
  if (closestDist != MAX_FLOAT) {
    fill(0);
    textAlign(CENTER);
    text(closestText, closestTextX, closestTextY);
  }
}

// Map the size of the ellipse to the data value

void drawData(float x, float y, String abbrev) {
  // Get data value for state
  float value = dataTable.getFloat(abbrev, 1);
  float radius = 0;
  if (value >= 0) {
    radius = map(value, 0, dataMax, 1.5, 15);
    fill(#333366); // blue
  } else {
    radius = map(value, 0, dataMin, 1.5, 15);
    fill(#EC5166); // red
  }
  //float percent = norm(value, dataMin, dataMax);
  //color between = lerpColor(#296F34, #61E2F0, percent,HSB);
  //fill(between);
  // Re-map the value to a number between 2 and 40
  //float mapped = map(value, dataMin, dataMax, 2, 40);
  // Draw an ellipse for this item
  ellipseMode(RADIUS);
  ellipse(x, y, radius, radius);
  
  float d = dist(x, y, mouseX, mouseY);
  // Bc the following check is done each time a new
  // circle is drawn, we end up with values of the 
  // circle closest to the mouse
  
  if((d < radius + 2) && (d < closestDist)) {
    closestDist = d;
    // Show the data value and the state abbrev in parens
    String name = nameTable.getString(abbrev, 1);
    closestText = name + " " + value;
    closestTextX = x;
    closestTextY = y-radius-4;
  }
}

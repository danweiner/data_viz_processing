PImage mapImage;
Table locationTable;
float dataMin = -10;
float dataMax = 10;
Table nameTable;
int rowCount;

Integrator[] interpolators;

Table dataTable;
//float dataMin = MAX_FLOAT;
//float dataMax = MIN_FLOAT;

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
  
  // Setup: loat initial values into the integrator
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++) {
    float initialValue = dataTable.getFloat(row, 1);
    interpolators[row] = new Integrator(initialValue, 0.5, 0.01);
  }
  nameTable = new Table("names.tsv");
  
  // Find min and max values - remove bc of dynamic values added 
  //for (int row = 0; row < rowCount; row++) {
  //  float value = dataTable.getFloat(row, 1);
  //  if (value > dataMax) {
  //    dataMax = value;
  //  }
  //  if (value < dataMin) {
  //    dataMin = value;
  //  }
  //}
}

void draw() {
  background(255);
  image(mapImage, 0, 0);
  
  
  // Draw: update the Integrator with the current vals
  // which are either those from the setup() fn or 
  // those loaded by the target() fn issued in updateTable()
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].update();
  }
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
  // Get data value for state]
  int row = dataTable.getRowIndex(abbrev);
  float value = interpolators[row].value;
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
    String name = dataTable.getString(abbrev, 0);
    // Use target (not curr) value for showing data point
    String val = nfp(interpolators[row].target, 0, 2);
    closestText = name + " " + val;
    closestTextX = x;
    closestTextY = y-radius-4;
  }
}

void keyPressed() {
  if (key == ' ') {
    updateTable();
  }
}

void updateTable() {
  for (int row = 0; row < rowCount; row++) {
    float newValue = random(-10, 10);
    interpolators[row].target(newValue);
  }
  //dataTable = new Table("http://benfry.com/writing/map/random.cgi");
}

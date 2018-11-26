FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int currentColumn = 0;
int columnCount;

int yearMin, yearMax;
int[] years;

PFont plotFont;

int rowCount;

int yearInterval = 10;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

float barWidth = 4;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

PImage[] tabImageNormal;
PImage[] tabImageHighlight;

color[] fillColor;

Integrator[] interpolators;

void setup() {
  size(720, 405);
  data = new FloatTable("milk-tea-coffee.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  
  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  
  smooth();
  
  // array of colors for different charts
  fillColor = new color[columnCount];
  
  fillColor[0] = color(255, 0, 0);
  fillColor[1] = color(0, 255, 0);
  fillColor[2] = color(0, 0, 255);
  
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.1; // Set lower than the default
  }
  
  //for (int i = 0; i < columnCount; i++) {
  //  fillColor[i] = 0;
  //}
  
  //print(fillColor);
  
}

void draw() {
  background(224);
  
  // Show plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
   
  //drawTitle();
  drawAxisLabels();
  drawVolumeLabels();
  
  noStroke();
  
  // fill graphs with different colors
  drawYearLabels();
  fill(fillColor[currentColumn]);
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].update();
  }
  drawDataArea(currentColumn);
  //drawDataBars(currentColumn);
  drawTitleTabs();
  
}

void drawTitle() {
  // Draw the title of the current plot
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1 - 10);
}

void drawAxisLabels() {
  fill(0);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("Gallons\nconsumed\nper capita", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

// Draw the data as a series of points
void drawDataPoints(int col) {
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x, y);
    }
  }
}

// Draw the data as a simple line with no fill
void drawDataLine(int col) {
  beginShape();
  int rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  endShape();
}

// remove bc adding mousePressed method to move between tabs
//void keyPressed() {
//  if (key == '[') {
//    currentColumn--;
//    if (currentColumn < 0) {
//      currentColumn = columnCount - 1;
//    }
//  } else if (key == ']') {
//    currentColumn++;
//    if (currentColumn == columnCount) {
//      currentColumn = 0;
//    }
//  }
//}

void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);
  stroke(224);
  strokeWeight(1);
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawVolumeLabels() {
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);
  
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) {
    if (v % volumeIntervalMinor == 0) { // if a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % volumeInterval == 0) { // a major tick mark 
        if (v == dataMin) {
          textAlign(RIGHT);
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP);
        } else {
          textAlign(RIGHT, CENTER);
        }
        text(floor(v), plotX1 -10, y);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
      } 
    }
  }
}

void drawDataHighlight(int col) {
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      if (dist(mouseX, mouseY, x, y) < 3) {
        stroke(0);
        strokeWeight(10);
        point(x, y);
        fill(0);
        textSize(10);
        textAlign(CENTER);
        text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
      }
    }
  }
}

void drawDataCurve(int col) {
  beginShape();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      
      curveVertex(x, y);
      // Double the curve points for the start and stop
      if ((row == 0) || (row == rowCount -1)) {
        curveVertex(x, y);
      }
    }
  }
  endShape();
}

void drawDataArea(int col) {
  beginShape();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  
  // Draw lower-right and lower-left corners
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}

void drawDataBars(int col) {
  noStroke();
  rectMode(CORNERS);
  
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      rect(x-barWidth/2, y, x+barWidth/2, plotY2);
    }
  }
}

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs
  
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
    
    tabImageNormal = new PImage[columnCount];
    tabImageHighlight = new PImage[columnCount];
    for (int col = 0; col < columnCount; col++) {
      String title = data.getColumnName(col);
      tabImageNormal[col] = loadImage(title + "-unselected.png");
      tabImageHighlight[col] = loadImage(title + "-selected.png");
    }
  }
  
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  // Size based on height of the tabs by checking the
  // height of the first (all images are the same height)
  tabTop = plotY1 - tabImageNormal[0].height;
  
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = tabImageNormal[col].width;
    
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    PImage tabImage = (col == currentColumn) ? tabImageHighlight[col]
      : tabImageNormal[col];
    image(tabImage, tabLeft[col], tabTop);
    
    runningX = tabRight[col];
  }
}

void mousePressed() {
  if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setColumn(col);
        
      }
    }
  }
}

void setColumn (int col) {
  if (col != currentColumn) {
    currentColumn = col;
  }
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}

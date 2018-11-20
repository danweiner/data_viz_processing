PImage mapImage;
Table nameTable;

int currentRow = -1;
PrintWriter writer;

void setup() {
  size(640, 400);
  mapImage = loadImage("map.png");
  nameTable = new Table("names.tsv");
  writer = createWriter("locations.tsv");
  cursor(CROSS); // make easier to pinpoint a location
  println("You will be clicking the locations of all 50 states.");
  println("Click the mouse to begin");
  writer.println("States" + "\t" + "mouseX" + "\t" + "mouseY");
}

void draw() {
  image(mapImage, 0, 0);
}

void mousePressed() {
  if (currentRow != -1) {
    String name = nameTable.getString(currentRow, 0);
    writer.println(name + "\t" + mouseX + "\t" + mouseY);
  }
  currentRow++;
  if (currentRow == nameTable.getRowCount()) {
    // Close the file and finish
    writer.flush();
    writer.close();
    exit();
  } else {
    // Ask for the next coordinate
    String name = nameTable.getString(currentRow, 1);
    println("Choose location for " + name + ".");
  }
}

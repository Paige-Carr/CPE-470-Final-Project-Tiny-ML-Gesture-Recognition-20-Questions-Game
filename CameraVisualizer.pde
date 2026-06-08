import processing.serial.*;
Serial myPort;

final int cameraWidth  = 160;
final int cameraHeight = 120;
final int bytesPerFrame = cameraWidth * cameraHeight; // 1 byte per pixel (grayscale)

PImage myImage;
byte[] frameBuffer = new byte[bytesPerFrame];
int lastByte = -1;

void setup() {
  size(320, 240); // display scaled up 2x
  myPort = new Serial(this, "COM7", 115200); // bump baud rate (see note)
  myImage = createImage(cameraWidth, cameraHeight, RGB);
}

void draw() {
  // Scale image 2x to fill the window
  image(myImage, 0, 0, 320, 240);
}

void serialEvent(Serial myPort) {
  while (myPort.available() > 0) {
    int b = myPort.read();

    // Detect sync marker: 0xFF followed by 0xAA
    if (lastByte == 0xFF && b == 0xAA) {
      if (myPort.available() >= bytesPerFrame) {
        myPort.readBytes(frameBuffer);
        myImage.loadPixels();
        for (int i = 0; i < bytesPerFrame; i++) {
          int gray = frameBuffer[i] & 0xFF; // unsigned
          myImage.pixels[i] = color(gray, gray, gray);
        }
        myImage.updatePixels();
        lastByte = -1;
        return;
      }
    }
    lastByte = b;
  }
}

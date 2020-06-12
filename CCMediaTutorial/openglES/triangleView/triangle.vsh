
attribute vec4 position;
attribute vec4 sourceColor;
varying vec4 DestinationColor;
void main(void) {
    DestinationColor = sourceColor;
    gl_Position = position;
}

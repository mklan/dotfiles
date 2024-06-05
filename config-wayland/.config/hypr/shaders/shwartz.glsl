precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    // Get the screen coordinates
    vec2 screenCoords = gl_FragCoord.xy;

    // Check if the sum of x and y coordinates is even
    bool isEvenPixel = mod(screenCoords.x + screenCoords.y, 2.0) == 0.0;

    // If it's an even pixel, keep the original color; otherwise, set it to black
    vec4 originalColor = texture2D(tex, v_texcoord);
    vec4 color = isEvenPixel ? originalColor : vec4(0.0, 0.0, 0.0, 1.0);

    // Output the final color
    gl_FragColor = color;
}
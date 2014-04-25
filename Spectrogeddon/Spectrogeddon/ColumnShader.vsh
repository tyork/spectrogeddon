attribute vec4 aPosition;
attribute float aLevel;
uniform mat4 uTransform;

varying lowp vec2 vLevel;

void main(void)
{
    gl_Position = uTransform * aPosition;
    vLevel = vec2(0.0, aLevel);
}
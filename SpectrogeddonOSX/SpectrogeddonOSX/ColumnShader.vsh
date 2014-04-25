#version 150

in vec4 aPosition;
in float aLevel;
uniform mat4 uTransform;

out vec2 vLevel;

void main(void)
{
    gl_Position = uTransform * aPosition;
    vLevel = vec2(0.0, aLevel);
}
#version 150

uniform float uOffset;
in vec4 aPosition;
in vec2 aTexCoord;
out vec2 vTexCoord;

void main(void)
{
    gl_Position = aPosition + vec4(uOffset, 0.0, 0.0, 0.0);
    vTexCoord = aTexCoord;
}
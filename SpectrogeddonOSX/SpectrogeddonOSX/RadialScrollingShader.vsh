#version 150

in vec4 aPosition;
in vec2 aTexCoord;
uniform vec2 uTexOffset;

out vec2 vTexCoord;

void main(void)
{
    gl_Position = aPosition;
    vTexCoord = mod(aTexCoord + uTexOffset, 1.0);
}
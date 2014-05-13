#version 150

in vec4 aPosition;
in vec2 aTexCoord;
uniform mat4 uTransform;

out vec2 vTexCoord;

void main(void)
{
    gl_Position = uTransform * aPosition;
    vTexCoord = aTexCoord;
}
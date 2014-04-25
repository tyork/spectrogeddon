#version 150

uniform sampler2D uLevelSampler;

in vec2 vLevel;
out vec4 color;

void main(void)
{
    color = texture(uLevelSampler, vLevel);
}
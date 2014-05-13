#version 150

uniform sampler2D uTextureSampler;
in vec2 vTexCoord;
out vec4 color;

void main(void)
{
    color = texture(uTextureSampler, vTexCoord);
}
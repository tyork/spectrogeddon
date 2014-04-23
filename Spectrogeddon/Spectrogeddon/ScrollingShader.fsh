uniform sampler2D uTextureSampler;
varying lowp vec2 vTexCoord;

void main(void)
{
    gl_FragColor = texture2D(uTextureSampler, vTexCoord);
}
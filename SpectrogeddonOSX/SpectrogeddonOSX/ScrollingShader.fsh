uniform sampler2D uTextureSampler;
varying highp vec2 vTexCoord;

void main(void)
{
    gl_FragColor = texture2D(uTextureSampler, vTexCoord);
}
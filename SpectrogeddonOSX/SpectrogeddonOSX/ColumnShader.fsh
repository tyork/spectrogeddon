uniform sampler2D uLevelSampler;

varying lowp vec2 vLevel;

void main(void)
{
    gl_FragColor = texture2D(uLevelSampler, vLevel);
}
#if __VERSION__ >= 130
    in vec2 vLevel;
    out vec4 color;
#else
    #ifdef GL_ES
        varying lowp vec2 vLevel;
    #else
        varying vec2 vLevel;
    #endif
#endif

uniform sampler2D uLevelSampler;

void main(void)
{
#if __VERSION__ >= 130
    color = texture(uLevelSampler, vLevel);
#else
    gl_FragColor = texture2D(uLevelSampler, vLevel);
#endif
}

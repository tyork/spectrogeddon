#if __VERSION__ >= 130
    in vec2 vTexCoord;
    out vec4 color;
#else
    #ifdef GL_ES
        varying highp vec2 vTexCoord;
    #else
        varying vec2 vTexCoord;
    #endif
#endif

uniform sampler2D uTextureSampler;

void main(void)
{
#if __VERSION__ >= 130
    color = texture(uTextureSampler, vTexCoord);
#else
    gl_FragColor = texture2D(uTextureSampler, vTexCoord);
#endif
}

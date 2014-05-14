#if __VERSION__ >= 130
    in vec4 aPosition;
    in vec2 aTexCoord;
    out vec2 vTexCoord;
#else
    attribute vec4 aPosition;
    attribute vec2 aTexCoord;
    #ifdef GL_ES
        varying highp vec2 vTexCoord;
    #else
        varying vec2 vTexCoord;
    #endif
#endif

uniform vec2 uTexOffset;

void main(void)
{
    gl_Position = aPosition;
    vTexCoord = aTexCoord;
}

#if __VERSION__ >= 130
    in vec4 aPosition;
    in float aLevel;
    out vec2 vLevel;
#else
    attribute vec4 aPosition;
    attribute float aLevel;
    #ifdef GL_ES
        varying lowp vec2 vLevel;
    #else
        varying vec2 vLevel;
    #endif
#endif

uniform mat4 uTransform;

void main(void)
{
    gl_Position = uTransform * aPosition;
    vLevel = vec2(0.0, aLevel);
}


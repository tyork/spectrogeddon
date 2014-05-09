uniform highp float uOffset;
attribute vec4 aPosition;
attribute vec2 aTexCoord;

varying highp vec2 vTexCoord;

void main(void)
{
    gl_Position = aPosition + vec4(uOffset, 0.0, 0.0, 0.0);
    vTexCoord = aTexCoord;
}

attribute vec4 aPosition;
attribute vec2 aTexCoord;
uniform highp vec2 uTexOffset;

varying highp vec2 vTexCoord;

void main(void)
{
    gl_Position = aPosition;
    vTexCoord = aTexCoord + uTexOffset;
}
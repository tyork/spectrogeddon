attribute vec4 aPosition;
attribute vec2 aTexCoord;
uniform vec2 uTexOffset;

varying lowp vec2 vTexCoord;

void main(void)
{
    gl_Position = aPosition;
    vTexCoord = aTexCoord + uTexOffset;
}
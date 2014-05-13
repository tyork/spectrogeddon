attribute vec4 aPosition;
attribute vec2 aTexCoord;
uniform mat4 uTransform;

varying highp vec2 vTexCoord;

void main(void)
{
    gl_Position = uTransform * aPosition;
    vTexCoord = aTexCoord;
}

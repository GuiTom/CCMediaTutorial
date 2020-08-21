#version 300 es
precision mediump float;

layout(location = 0) out vec4 fragColor;
uniform sampler2D s_texture;
void main()
{
    fragColor = texture(s_texture, gl_PointCoord);
    
    
}

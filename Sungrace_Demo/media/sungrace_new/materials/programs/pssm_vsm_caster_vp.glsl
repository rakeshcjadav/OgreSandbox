#version 330

uniform mat4 matWorldViewProj;
uniform mat4 matWorldView;

// Inputs
in vec4 vertex;

// Outputs
out vec4 outVertexDepth;

void main()
{
    outVertexDepth = matWorldView * vertex;
    
    // pass the vertex position, transforming it to clip space
    gl_Position = matWorldViewProj * vertex;
}

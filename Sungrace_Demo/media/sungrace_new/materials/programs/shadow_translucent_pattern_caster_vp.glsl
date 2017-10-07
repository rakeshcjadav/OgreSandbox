#version 330

uniform mat4 matWorldViewProj;
uniform mat4 matWorldView;
uniform mat4 u_matTextureMatrix;

// Inputs
in vec4 vertex;
in vec2 uv0;

// Outputs
out vec4 outVertexDepth;
out vec2 outUV;

void main()
{
    outVertexDepth = matWorldView * vertex;
	
	outVertexDepth = outVertexDepth/vec4(outVertexDepth.w);
	
	outUV = (u_matTextureMatrix * vec4(uv0, 1.0, 1.0)).xy;
    
    // pass the vertex position, transforming it to clip space
    gl_Position = matWorldViewProj * vertex;
}

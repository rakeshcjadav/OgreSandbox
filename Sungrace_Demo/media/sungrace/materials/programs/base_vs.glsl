#version 150

uniform mat4 u_matWorldMatrix;
uniform mat4 u_matWorldViewMatrix;
uniform mat4 u_matWorldViewProjMatrix;

uniform vec4 u_camera_position;

// Light data
uniform mat4 u_texViewProjMatrix0;
uniform mat4 u_texViewProjMatrix1;
uniform mat4 u_texViewProjMatrix2;
uniform mat4 u_texViewProjMatrix3;

// Inputs 
in vec4 vertex;
in vec3 normal;
in vec2 uv0;

// Output to Fragment Shader
out vec3 outNormal;
out vec4 outVertex;
out vec2 outUV;
out vec4 outCameraPosition;
out vec4 outPositionShadowLightSpace[4];

void main()
{
	gl_Position = u_matWorldViewProjMatrix * vertex;
	
	outVertex = u_matWorldMatrix * vertex;
	
	// Calculate the position of vertex in light space for shadowing.
    outPositionShadowLightSpace[0] = u_texViewProjMatrix0 * outVertex;
    outPositionShadowLightSpace[1] = u_texViewProjMatrix1 * outVertex;
    outPositionShadowLightSpace[2] = u_texViewProjMatrix2 * outVertex;
    outPositionShadowLightSpace[3] = u_texViewProjMatrix3 * outVertex;
	
	outVertex = outVertex/vec4(outVertex.w);
	
	outNormal = normal;
	
	outUV = uv0;
	
	outCameraPosition = u_camera_position;	
}

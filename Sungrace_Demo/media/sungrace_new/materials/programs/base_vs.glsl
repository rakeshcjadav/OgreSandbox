#version 150

uniform mat4 u_matWorldMatrix;
uniform mat4 u_matWorldViewMatrix;
uniform mat4 u_matWorldViewProjMatrix;

uniform mat4 u_matTextureMatrix;

uniform vec4 u_camera_position;

// Light data
uniform mat4 u_texViewProjMatrix0;
uniform mat4 u_texViewProjMatrix1;
uniform mat4 u_texViewProjMatrix2;
uniform mat4 u_texViewProjMatrix3;
uniform mat4 u_texViewProjMatrix4;
uniform mat4 u_texViewProjMatrix5;
uniform mat4 u_texViewProjMatrix6;
uniform mat4 u_texViewProjMatrix7;

// Inputs 
in vec4 vertex;
in vec3 normal;
in vec2 uv0;

// Output to Fragment Shader
out vec3 outNormal;
out vec4 outVertex;
out vec2 outUV;
out vec4 outCameraPosition;
out vec4 outPositionShadowLightSpace[8];

void main()
{
	gl_Position = u_matWorldViewProjMatrix * vertex;
	
	outVertex = u_matWorldMatrix * vertex;
	
	// Calculate the position of vertex in light space for shadowing.
    outPositionShadowLightSpace[0] = u_texViewProjMatrix0 * outVertex;
	outPositionShadowLightSpace[1] = u_texViewProjMatrix1 * outVertex;
    outPositionShadowLightSpace[2] = u_texViewProjMatrix2 * outVertex;
    outPositionShadowLightSpace[3] = u_texViewProjMatrix3 * outVertex;
	outPositionShadowLightSpace[4] = u_texViewProjMatrix4 * outVertex;
	outPositionShadowLightSpace[5] = u_texViewProjMatrix5 * outVertex;
    outPositionShadowLightSpace[6] = u_texViewProjMatrix6 * outVertex;
    outPositionShadowLightSpace[7] = u_texViewProjMatrix7 * outVertex;
	
	outVertex = outVertex/vec4(outVertex.w);
	
	outNormal = vec3(u_matWorldMatrix * vec4(normalize(normal), 0.0));;
	
	outUV = (u_matTextureMatrix * vec4(uv0, 1.0, 1.0)).xy;
	
	outCameraPosition = u_camera_position;	
}
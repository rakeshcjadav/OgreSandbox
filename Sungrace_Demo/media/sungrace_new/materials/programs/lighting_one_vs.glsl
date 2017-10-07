#version 150

uniform mat4 u_matWorldMatrix;
uniform mat4 u_matWorldViewMatrix;
uniform mat4 u_matWorldViewProjMatrix;

uniform mat4 u_matTextureMatrix;

uniform vec4 u_camera_position;

// Light data
uniform mat4 u_texViewProjMatrix0;

// Inputs 
in vec4 vertex;
in vec3 normal;
in vec2 uv0;

// Output to Fragment Shader
out vec3 outNormal;
out vec4 outVertex;
out vec2 outUV;
out vec4 outCameraPosition;
out vec4 outPositionShadowLightSpace;

void main()
{
	gl_Position = u_matWorldViewProjMatrix * vertex;
	
	outVertex = u_matWorldMatrix * vertex;
	
	// Calculate the position of vertex in light space for shadowing.
    outPositionShadowLightSpace = u_texViewProjMatrix0 * outVertex;
	
	outVertex = outVertex/vec4(outVertex.w);
	
	outNormal = vec3(u_matWorldMatrix * vec4(normalize(normal), 0.0));;
	
	outUV = (u_matTextureMatrix * vec4(uv0, 1.0, 1.0)).xy;
	
	outCameraPosition = u_camera_position;	
}
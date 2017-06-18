#version 150

uniform vec4 posLight;
uniform vec4 posEye;
uniform mat4 matWorldViewProj;
uniform mat4 matWorld;

in vec4 vertex;
in vec3 normal;
in vec4 uv0;

out vec4 oPos;
out vec3 oNormal;
out vec4 oUv0;
out vec4 oPosLight;
out vec4 oPosEye;

void main()
{
	gl_Position = matWorldViewProj * vertex;
	
	oPos = matWorld * vertex;
	oNormal = normal;
	oUv0 = uv0;
	
	oPosLight = posLight;
	oPosEye = posEye;
}
#version 150

uniform mat4 matWorldViewProj;

in vec4 vertex;
in vec4 uv0;

out vec4 oVertex;
out vec4 oUV0;

out vec4 oPosEye;

void main()
{
	gl_Position = matWorldViewProj * vertex;
	oUV0 = uv0;
}


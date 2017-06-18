#version 150

uniform sampler2D DiffuseMap;

in vec4 oUV0;

out vec4 oColor;

void main()
{
	vec4 diffuseColor = vec4(0.0);
	vec2 texCoord_Diffuse = oUV0.st;
	diffuseColor = (texture2D(DiffuseMap, texCoord_Diffuse)).rgba;
	oColor = diffuseColor;
}
